# gerar_codigo_de_processo_penal_json.ps1
# Script dedicado exclusivamente ao Código de Processo Penal (Decreto-Lei 3.689/1941).
# Lê o arquivo TXT (fonte da verdade) e gera um codigo_de_processo_penal.json correto, completo e bem estruturado.
# Uso:  powershell -ExecutionPolicy Bypass -File gerar_codigo_de_processo_penal_json.ps1
#       powershell -File gerar_codigo_de_processo_penal_json.ps1 -MaxArticles 50   # para teste rápido

[CmdletBinding()]
param(
    [int]$MaxArticles = 0,   # 0 = processar todos (~811)
    [switch]$NoBackup
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$baseDir = $PSScriptRoot
$txtPath = Join-Path $baseDir 'codigo_de_processo_penal.txt'
$outJsonPath = Join-Path $baseDir 'codigo_de_processo_penal.json'
$bakPath = "$outJsonPath.bak"

if (-not (Test-Path $txtPath)) {
    throw "Arquivo de verdade não encontrado: $txtPath"
}

if ((Test-Path $outJsonPath) -and -not $NoBackup) {
    Copy-Item -Path $outJsonPath -Destination $bakPath -Force
    Write-Host "Backup criado: $bakPath" -ForegroundColor DarkGray
}

Write-Host "Lendo TXT (fonte da verdade)..." -ForegroundColor Cyan
$lines = [System.IO.File]::ReadAllLines($txtPath)
$totalLines = $lines.Length
Write-Host "  $totalLines linhas carregadas." -ForegroundColor DarkGray

# ============================================================
# Helpers
# ============================================================

function Clean-Text([string]$t) {
    if ([string]::IsNullOrWhiteSpace($t)) { return '' }
    $t = $t.Trim()
    # Remove o "o " / "º " residual do <sup>o</sup> do HTML se presente (ex: "o Toda pessoa")
    $t = [regex]::Replace($t, '^[oº]\s+', '')
    # Normaliza espaços múltiplos (mas preserva intencional)
    $t = [regex]::Replace($t, '\s{2,}', ' ')
    return $t.Trim()
}

function New-Division([string]$tipo, [string]$rotulo, [int]$linha) {
    return [pscustomobject]@{
        tipo     = $tipo
        rotulo   = $rotulo
        linha    = $linha
        divisoes = @()
        artigos  = @()
    }
}

function New-Artigo([string]$numero, [string]$rotulo, [int]$linha, [string]$caput) {
    $obj = [pscustomobject]@{
        numero = $numero
        rotulo = $rotulo
        linha  = $linha
        caput  = Clean-Text $caput
    }
    return $obj
}

function New-Inciso([string]$numero, [int]$linha, [string]$texto) {
    return [pscustomobject]@{
        numero = $numero
        rotulo = $numero
        linha  = $linha
        texto  = Clean-Text $texto
    }
}

function New-Paragrafo([string]$numero, [string]$rotulo, [int]$linha, [string]$texto) {
    return [pscustomobject]@{
        numero = $numero
        rotulo = $rotulo
        linha  = $linha
        texto  = Clean-Text $texto
    }
}

function New-Alinea([string]$letra, [int]$linha, [string]$texto) {
    return [pscustomobject]@{
        letra  = $letra
        rotulo = "$letra)"
        linha  = $linha
        texto  = Clean-Text $texto
    }
}

# Níveis para controle de pilha (menor = mais alto)
$LevelMap = @{
    'parte'    = 0
    'livro'    = 1
    'titulo'   = 2
    'capitulo' = 3
    'secao'    = 4
    'subsecao' = 5
}

function Get-Level([string]$tipo) {
    if ($LevelMap.ContainsKey($tipo)) { return $LevelMap[$tipo] }
    return 99
}

# ============================================================
# Parser principal
# ============================================================

$preambulo = @()
$divisoes = @()                 # raiz
$stack = [System.Collections.Generic.List[object]]::new()  # pilha de divisões abertas

$artCount = 0
$inPreambulo = $true
$fecho = $null
$i = 0

# Regexes (case sensitive onde necessário, mas a maioria upper no arquivo)
$reParte     = '^(P A R T E|PARTE ESPECIAL|PARTE GERAL)\s*(.*)$'
$reLivro     = '^(LIVRO\s+[IVXÚ]+)\s*(.*)$'
$reTitulo    = '^(TÍTULO\s+[IVXÚ]+)\s*(.*)$'
$reCapitulo  = '^(CAPÍTULO\s+[IVX]+)\s*(.*)$'
$reSecao     = '^(Seção\s+[IVX]+)\s*(.*)$'
$reSubsecao  = '^(Subseção\s+[IVX]+)\s*(.*)$'
$reArt       = '^[\s]*Art\.[\s]*([\d.]+[oº]?(?:-[A-Z])?)'

# Incisos romanos comuns (I até XII é suficiente para o CC)
$romanIncisos = '^(I{1,3}|IV|V|VI|VII|VIII|IX|X{1,2}|XI|XII)\s*[-–]\s*(.*)$'
$reParagrafo = '^(Parágrafo único|§\s*(\d+)\s*[ºo]?)\.?\s*(.*)$'
$reAlinea    = '^([a-z])\)\s*(.*)$'

function Attach-Division($node) {
    $myLevel = Get-Level $node.tipo
    while ($stack.Count -gt 0 -and (Get-Level $stack[-1].tipo) -ge $myLevel) {
        [void]$stack.RemoveAt($stack.Count - 1)
    }
    if ($stack.Count -eq 0) {
        $script:divisoes += $node
    } else {
        $stack[-1].divisoes += $node
    }
    [void]$stack.Add($node)
}

function Attach-Artigo($art) {
    if ($stack.Count -gt 0) {
        $stack[-1].artigos += $art
    } else {
        Write-Warning "Artigo $($art.numero) (linha $($art.linha)) sem divisão atual - anexando na raiz"
        if (-not $script:divisoes) { $script:divisoes = @() }
        # fallback: cria um container dummy se necessário, mas normalmente não acontece
        if ($script:divisoes.Count -eq 0) {
            $dummy = New-Division 'livro' 'LIVRO (sem título no parse)' $art.linha
            $script:divisoes += $dummy
            [void]$stack.Add($dummy)
        }
        $stack[-1].artigos += $art
    }
}

Write-Host "Iniciando parse..." -ForegroundColor Cyan

while ($i -lt $totalLines) {
    $raw = $lines[$i]
    $trim = $raw.Trim()
    $ln = $i + 1

    if ([string]::IsNullOrWhiteSpace($trim)) { $i++; continue }

    # Fecho oficial - paramos aqui para ignorar o sumário duplicado no final do arquivo
    if ($trim -like 'Brasília, 10 de janeiro de 2002*' -or $trim -like 'Rio de Janeiro, em 3 de outubro de 1941*') {
        $fecho = [ordered]@{ texto = $trim; linha = $ln }
        break
    }

    # --- DIVISÕES ESTRUTURAIS ---
    $div = $null
    if ($trim -match $reParte) {
        $div = New-Division 'parte' $trim $ln
    }
    elseif ($trim -match $reLivro) {
        $div = New-Division 'livro' $trim $ln
    }
    elseif ($trim -match $reTitulo) {
        $div = New-Division 'titulo' $trim $ln
    }
    elseif ($trim -match $reCapitulo) {
        $div = New-Division 'capitulo' $trim $ln
    }
    elseif ($trim -match $reSecao) {
        $div = New-Division 'secao' $trim $ln
    }
    elseif ($trim -match $reSubsecao) {
        $div = New-Division 'subsecao' $trim $ln
    }

    if ($div) {
        if ($inPreambulo) { $inPreambulo = $false }
        Attach-Division $div

        # Capture optional descriptive title on the line(s) immediately following the rotulo.
        # Preserves text from TXT (prevents loss or mixing into rubrica/caput).
        $titleLines = @()
        $j = $i + 1
        while ($j -lt $totalLines) {
            $p = $lines[$j].Trim()
            if ([string]::IsNullOrWhiteSpace($p)) { $j++; continue }
            if ($p -match '^[\s]*Art\.?') { break }
            if ($p -match '^(P A R T E|PARTE |LIVRO |TÍTULO |CAPÍTULO |Seção |Subseção |DISPOSIÇÕES)') { break }
            if ($p -match $reParagrafo -or $p -match $romanIncisos -or $p -match $reAlinea -or $p -match '^(Pena |Pena –|Pena -)') { break }
            if ($p -cmatch '^[A-ZÁÉÍÓÚÂÊÎÔÛÃÕÇ0-9 ,.°º-]{5,90}$') {
                $titleLines += $p
                $j++
                if ($titleLines.Count -ge 2) { break }
                continue
            }
            break
        }
        if ($titleLines.Count -gt 0) {
            $div | Add-Member -NotePropertyName titulo -NotePropertyValue ($titleLines -join ' ') -Force
            $div | Add-Member -NotePropertyName linhaTitulo -NotePropertyValue ($ln + 1) -Force
            $i = $j
            continue
        }

        $i++
        continue
    }

    # --- ARTIGOS ---
    if ($trim -match $reArt) {
        $num = $Matches[1].TrimEnd('.')
        # Normaliza "o"/"O" para "º" em números de artigo (ex: 1o → 1º, 3o-A → 3º-A)
        $num = $num -replace '([0-9]+)[oO](?=$|-)', '$1º'
        # Força º no final de TODO artigo (usuário quer em todos: 10º, 100º, 1.072º, 3º-A etc.)
        $num = $num -replace '(\d+)(º)?(-[A-Z])?$', '$1º$3'
        $rot = "Art. $num."

        # Captura caput (pode continuar em linhas seguintes que não sejam marcadores)
        $caput = $trim -replace '^[\s]*Art\.[\s]*[\d.]+[oº]?(?:-[A-Z])?[\s.]*', ''
        $artStartLine = $ln
        $i++

        while ($i -lt $totalLines) {
            $peek = $lines[$i].Trim()
            if ([string]::IsNullOrWhiteSpace($peek)) { $i++; continue }
            if ($peek -match '^[\s]*Art\.') { break }
            if ($peek -match '^(P A R T E|PARTE |LIVRO |TÍTULO |CAPÍTULO |Seção |Subseção )') { break }
            if ($peek -match $romanIncisos -or $peek -match $reParagrafo -or $peek -match $reAlinea) { break }
            if ($peek -like 'Rio de Janeiro, em 3 de outubro*' -or $peek -like 'Brasília, *') { break }

            $caput += ' ' + $peek
            $i++
        }

        $art = New-Artigo $num $rot $artStartLine $caput

        # Agora consome incisos / parágrafos / alíneas que pertencem a este artigo
        $incisos = @()
        $paragrafos = @()
        $lastListItem = $null   # último inciso ou parágrafo (para anexar alíneas ou continuação)
        $currentListParent = $art  # default: itens de lista no nível do artigo (pode ser sobrescrito por parágrafo)

        while ($i -lt $totalLines) {
            $l = $lines[$i].Trim()
            $cln = $i + 1
            if ([string]::IsNullOrWhiteSpace($l)) { $i++; continue }

            # Parar se próximo artigo ou nova divisão de alto nível
            if ($l -match '^Art\.') { break }
            if ($l -match '^(P A R T E|PARTE |LIVRO |TÍTULO |CAPÍTULO |Seção |Subseção )') { break }
            if ($l -like 'Rio de Janeiro, em 3 de outubro*' -or $l -like 'Brasília, *') { break }

            # Parágrafo único ou § N
            if ($l -match $reParagrafo) {
                $pnum = if ($Matches[2]) { $Matches[2] } else { 'único' }
                $prot = if ($pnum -eq 'único') { 'Parágrafo único' } else { "§ $pnum" }
                $ptext = if ($Matches[3]) { $Matches[3] } else { '' }
                $p = New-Paragrafo $pnum $prot $cln $ptext
                $paragrafos += $p
                $lastListItem = $p
                $currentListParent = $p
                $i++
                continue
            }

            # Inciso romano (I - , II - , etc)
            if ($l -match $romanIncisos) {
                $inum = $Matches[1]
                $itext = $Matches[2]
                $inc = New-Inciso $inum $cln $itext
                # Anexar a um parágrafo aberto (ex: o Parágrafo único do Art.5 contém os I-V) ?
                $attachedToPar = $false
                if ($currentListParent -and $currentListParent.PSObject.Properties.Name -contains 'texto' -and
                    ($currentListParent.rotulo -like 'Parágrafo*' -or $currentListParent.rotulo -like '§*')) {
                    if (-not ($currentListParent.PSObject.Properties.Name -contains 'incisos')) {
                        $currentListParent | Add-Member -NotePropertyName incisos -NotePropertyValue @() -Force
                    }
                    $currentListParent.incisos = @($currentListParent.incisos) + $inc
                    $attachedToPar = $true
                }
                if (-not $attachedToPar) {
                    $incisos += $inc
                    $currentListParent = $inc
                }
                $lastListItem = $inc
                $i++
                continue
            }

            # Alínea (a) (b) ...
            if ($l -match $reAlinea) {
                $let = $Matches[1]
                $atext = $Matches[2]
                $al = New-Alinea $let $cln $atext

                $attached = $false
                # Prefer current parent (could be a paragrafo that owns recent incisos)
                if ($currentListParent) {
                    if ($currentListParent.PSObject.Properties.Name -contains 'incisos' -and $currentListParent.incisos -and $currentListParent.incisos.Count -gt 0) {
                        $targetInc = $currentListParent.incisos[-1]
                        if (-not ($targetInc.PSObject.Properties.Name -contains 'alineas')) { $targetInc | Add-Member -NotePropertyName alineas -NotePropertyValue @() -Force }
                        $targetInc.alineas += $al
                        $attached = $true
                    }
                    elseif ($currentListParent.PSObject.Properties.Name -contains 'alineas' -or $currentListParent.PSObject.Properties.Name -contains 'texto') {
                        if (-not ($currentListParent.PSObject.Properties.Name -contains 'alineas')) { $currentListParent | Add-Member -NotePropertyName alineas -NotePropertyValue @() -Force }
                        $currentListParent.alineas += $al
                        $attached = $true
                    }
                }
                if (-not $attached -and $lastListItem) {
                    if ($lastListItem.PSObject.Properties.Name -contains 'incisos' -and $lastListItem.incisos -and $lastListItem.incisos.Count -gt 0) {
                        $targetInc = $lastListItem.incisos[-1]
                        if (-not ($targetInc.PSObject.Properties.Name -contains 'alineas')) { $targetInc | Add-Member -NotePropertyName alineas -NotePropertyValue @() -Force }
                        $targetInc.alineas += $al
                        $attached = $true
                    }
                    elseif ($lastListItem.PSObject.Properties.Name -contains 'alineas') {
                        if (-not ($lastListItem.PSObject.Properties.Name -contains 'alineas')) { $lastListItem | Add-Member -NotePropertyName alineas -NotePropertyValue @() -Force }
                        $lastListItem.alineas += $al
                        $attached = $true
                    }
                }
                if (-not $attached -and $incisos.Count -gt 0) {
                    $target = $incisos[-1]
                    if (-not ($target.PSObject.Properties.Name -contains 'alineas')) { $target | Add-Member -NotePropertyName alineas -NotePropertyValue @() -Force }
                    $target.alineas += $al
                    $attached = $true
                }
                if (-not $attached -and $paragrafos.Count -gt 0) {
                    $target = $paragrafos[-1]
                    if (-not ($target.PSObject.Properties.Name -contains 'alineas')) { $target | Add-Member -NotePropertyName alineas -NotePropertyValue @() -Force }
                    $target.alineas += $al
                    $attached = $true
                }
                if (-not $attached) {
                    if (-not ($art.PSObject.Properties.Name -contains 'alineas')) { $art | Add-Member -NotePropertyName alineas -NotePropertyValue @() -Force }
                    $art.alineas += $al
                }
                $i++
                continue
            }

            # Continuação de texto do último item (caput longo, inciso longo, etc)
            if ($lastListItem) {
                if ($lastListItem.PSObject.Properties.Name -contains 'texto') {
                    $lastListItem.texto = ($lastListItem.texto + ' ' + $l).Trim()
                }
                $i++
                continue
            }

            # Ainda no caput
            $art.caput = ($art.caput + ' ' + $l).Trim()
            $i++
        }

        # Anexar subitens ao artigo (se existirem)
        if ($incisos.Count -gt 0) { $art | Add-Member -NotePropertyName incisos -NotePropertyValue $incisos -Force }
        if ($paragrafos.Count -gt 0) { $art | Add-Member -NotePropertyName paragrafos -NotePropertyValue $paragrafos -Force }

        Attach-Artigo $art
        $artCount++

        if ($MaxArticles -gt 0 -and $artCount -ge $MaxArticles) {
            Write-Host "  Parada antecipada em $artCount artigos (MaxArticles=$MaxArticles)." -ForegroundColor Yellow
            break
        }
        continue   # o while interno já avançou $i
    }

    # Coleta preâmbulo (cabeçalho da lei)
    if ($inPreambulo) {
        # Só guarda as linhas "oficiais" do preâmbulo
        if ($trim -match '^(DECRETO-LEI|Código de Processo Penal|O PRESIDENTE|LIVRO I$)' -or $preambulo.Count -lt 6) {
            $preambulo += [ordered]@{
                texto = $trim
                linha = $ln
            }
        }
    }

    $i++
}

# Fecha pilha (não necessário para JSON, mas bom para contagem)
while ($stack.Count -gt 0) { [void]$stack.RemoveAt($stack.Count-1) }

# Remove duplicatas de topo criadas pelo sumário no final do TXT (após o fecho)
# Mantém a primeira ocorrência de cada (tipo|rotulo)
$seen = @{}
$clean = @()
foreach ($d in $divisoes) {
    $key = "$($d.tipo)|$($d.rotulo)"
    if (-not $seen.ContainsKey($key)) {
        $seen[$key] = $true
        $clean += $d
    }
}
$divisoes = $clean

# Podar divisões de topo vazias (vindas do sumário repetido após o fecho)
function HasContent($n) {
    if ($n.artigos -and $n.artigos.Count -gt 0) { return $true }
    if ($n.divisoes) {
        foreach ($c in $n.divisoes) { if (HasContent $c) { return $true } }
    }
    return $false
}
$divisoes = @($divisoes | Where-Object { HasContent $_ })

Write-Host "Parse concluído: $artCount artigos processados." -ForegroundColor Green

# ============================================================
# Monta objeto final (mantém compatibilidade com o schema anterior)
# ============================================================

$root = [ordered]@{
    id               = 'Codigo_de_Processo_Penal'
    titulo           = 'Código de Processo Penal'
    apelido          = 'Código de Processo Penal.'
    sigla            = 'CPP'
    fonte            = 'Codigo_de_Processo_Penal.txt'
    fonteHtmlLocal   = 'codigos/Codigo_de_Processo_Penal/del3689.htm'
    fonteOficial     = 'https://www.planalto.gov.br/ccivil_03/decreto-lei/del3689.htm'
    ementa           = 'Código de Processo Penal.'
    preambulo        = $preambulo
    divisoes         = $divisoes
}

if ($fecho) {
    $root.fecho = $fecho
} else {
    # fallback: procurar no final do arquivo
    for ($k = $totalLines-1; $k -ge 0; $k--) {
        if ($lines[$k] -match 'Brasília') {
            $root.fecho = [ordered]@{ texto = $lines[$k].Trim(); linha = ($k+1) }
            break
        }
    }
}

# ============================================================
# Estatísticas rápidas (recursivas)
# ============================================================

function Get-ArtigoCount($nodes) {
    $c = 0
    foreach ($n in $nodes) {
        if ($n.artigos) { $c += $n.artigos.Count }
        if ($n.divisoes) { $c += Get-ArtigoCount $n.divisoes }
    }
    return $c
}

function Get-DivisionStats($nodes, $depth = 0) {
    $stats = @{}
    foreach ($n in $nodes) {
        $t = $n.tipo
        if (-not $stats.ContainsKey($t)) { $stats[$t] = 0 }
        $stats[$t]++
        if ($n.divisoes) {
            $child = Get-DivisionStats $n.divisoes ($depth+1)
            foreach ($k in $child.Keys) {
                if (-not $stats.ContainsKey($k)) { $stats[$k] = 0 }
                $stats[$k] += $child[$k]
            }
        }
    }
    return $stats
}

$finalArtCount = Get-ArtigoCount $divisoes
$divStats = Get-DivisionStats $divisoes

Write-Host ""
Write-Host "=== ESTATÍSTICAS ===" -ForegroundColor Cyan
Write-Host "Artigos no JSON gerado: $finalArtCount" -ForegroundColor Green
Write-Host "Divisões por tipo:"
$divStats.GetEnumerator() | Sort-Object Name | ForEach-Object { "  $($_.Key): $($_.Value)" }

if ($finalArtCount -lt 700 -and $MaxArticles -eq 0) {
    Write-Warning "Contagem de artigos baixa. Verifique o parser ou o arquivo TXT."
}

# ============================================================
# Escreve o JSON (indent 4 espaços, UTF-8)
# ============================================================

Write-Host ""
Write-Host "Gerando JSON..." -ForegroundColor Cyan

# ConvertTo-Json com Depth alto + formatação manual para 4 espaços
$jsonText = $root | ConvertTo-Json -Depth 25

# Garante indentação de 4 espaços (ConvertTo-Json usa 4 por padrão em PS 6+, mas forçamos)
$jsonText = $jsonText -replace '  ', '    '   # caso venha com 2

[System.IO.File]::WriteAllText($outJsonPath, $jsonText, [System.Text.UTF8Encoding]::new($false))

Write-Host "JSON salvo em: $outJsonPath" -ForegroundColor Green

# Verificação rápida de carga
try {
    $loaded = Get-Content $outJsonPath -Raw | ConvertFrom-Json
    $loadedArts = Get-ArtigoCount $loaded.divisoes
    Write-Host "Verificação de carga: $loadedArts artigos no JSON lido de volta." -ForegroundColor DarkGray
} catch {
    Write-Warning "Falha ao recarregar o JSON gerado para verificação: $_"
}

Write-Host ""
Write-Host "Concluído." -ForegroundColor Green
if ($MaxArticles -gt 0) {
    Write-Host "(executado em modo parcial - MaxArticles=$MaxArticles)" -ForegroundColor Yellow
}
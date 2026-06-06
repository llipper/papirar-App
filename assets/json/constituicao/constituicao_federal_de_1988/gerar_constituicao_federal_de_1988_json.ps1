# gerar_constituicao_federal_de_1988_json.ps1
# Gera constituicao_federal_de_1988.json a partir do TXT e preserva audios
# no formato separado: audioId no JSON principal + *_audio.json como catalogo.
# Uso: powershell -ExecutionPolicy Bypass -File gerar_constituicao_federal_de_1988_json.ps1

[CmdletBinding()]
param(
    [int]$MaxArticles = 0,
    [switch]$NoBackup
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$baseDir = $PSScriptRoot
$txtPath = Join-Path $baseDir 'constituicao_federal_de_1988.txt'
$outJsonPath = Join-Path $baseDir 'constituicao_federal_de_1988.json'
$audioJsonPath = Join-Path $baseDir 'constituicao_federal_de_1988_audio.json'
$bakPath = "$outJsonPath.bak"

if (-not (Test-Path $txtPath)) {
    throw "Arquivo fonte nao encontrado: $txtPath"
}

if ((Test-Path $outJsonPath) -and -not $NoBackup) {
    Copy-Item -Path $outJsonPath -Destination $bakPath -Force
    Write-Host "Backup criado: $bakPath" -ForegroundColor DarkGray
}

Write-Host "Lendo TXT da Constituicao..." -ForegroundColor Cyan
$lines = [System.IO.File]::ReadAllLines($txtPath)
$totalLines = $lines.Length
Write-Host "  $totalLines linhas carregadas." -ForegroundColor DarkGray

$audioCatalog = @{}
if (Test-Path $audioJsonPath) {
    $audioRaw = Get-Content -Raw $audioJsonPath
    if (-not [string]::IsNullOrWhiteSpace($audioRaw)) {
        $audioJson = $audioRaw | ConvertFrom-Json
        foreach ($prop in $audioJson.PSObject.Properties) {
            $audioCatalog[$prop.Name] = $true
        }
    }
}

function Clean-Text([string]$text) {
    if ([string]::IsNullOrWhiteSpace($text)) { return '' }
    $value = $text.Trim()
    $value = [regex]::Replace($value, '\s{2,}', ' ')
    return $value.Trim()
}

function New-Division([string]$tipo, [string]$rotulo, [int]$linha) {
    return [pscustomobject]@{
        tipo     = $tipo
        rotulo   = $rotulo
        linha    = $linha
        divisoes = [System.Collections.ArrayList]::new()
        artigos  = [System.Collections.ArrayList]::new()
    }
}

function New-Artigo([string]$numero, [string]$rotulo, [int]$linha, [string]$caput, [bool]$isAdct) {
    $cleanCaput = Clean-Text $caput
    $artigo = [pscustomobject]@{
        numero = $numero
        rotulo = $rotulo
        linha  = $linha
        caput  = $cleanCaput
    }

    $audioId = Get-AudioId $numero $isAdct
    if ($audioId) {
        $artigo | Add-Member -NotePropertyName audioId -NotePropertyValue $audioId
    }

    return $artigo
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

function Normalize-NumeroArtigo([string]$numero, [string]$ordinal) {
    $n = $numero.Trim()
    if ($ordinal -and $ordinal.Trim()) { return "${n}º" }
    return $n
}

function Get-AudioId([string]$numero, [bool]$isAdct) {
    $slug = ($numero -replace 'º', '' -replace '\.', '' -replace '-', '_').ToLowerInvariant()
    $prefix = if ($isAdct) { 'constituicao88-adct-artigo_' } else { 'constituicao88-artigo_' }
    $candidate = "$prefix$slug"
    if ($audioCatalog.ContainsKey($candidate)) { return $candidate }
    return $null
}

$levelMap = @{
    titulo   = 1
    capitulo = 2
    secao    = 3
    subsecao = 4
}

function Get-Level([string]$tipo) {
    if ($levelMap.ContainsKey($tipo)) { return $levelMap[$tipo] }
    return 99
}

$script:preambulo = @()
$script:divisoes = @()
$script:adct = $null
$script:stack = [System.Collections.Generic.List[object]]::new()

$script:currentArticle = $null
$script:currentContainer = $null
$script:currentPart = $null
$script:pendingTitleFor = $null
$script:inMainText = $false
$script:inAdct = $false
$script:skipUntilAdct = $false
$script:contentFinished = $false
$script:artCount = 0

$reArt = '^\s*Art\.?\s*(\d+(?:-[A-Z])?)([ºo°]?)\.?\s*(.*)$'
$reTitulo = '^\s*TÍTULO\s+[IVXLC]+'
$reCapitulo = '^\s*CAPÍTULO\s+[IVXLC]+'
$reSecao = '^\s*SEÇÃO\s+[IVXLC]+'
$reSubsecao = '^\s*SUBSEÇÃO\s+[IVXLC]+'
$reInciso = '^\s*([IVXLCDM]+)\s*[-–]\s*(.*)$'
$reParagrafo = '^\s*(Parágrafo único|§\s*(\d+)\s*[ºo°]?)\.?\s*-?\s*(.*)$'
$reAlinea = '^\s*([a-z])\)\s*(.*)$'

function Add-Division($node) {
    $level = Get-Level $node.tipo
    while ($script:stack.Count -gt 0 -and (Get-Level $script:stack[-1].tipo) -ge $level) {
        [void]$script:stack.RemoveAt($script:stack.Count - 1)
    }

    if ($script:stack.Count -eq 0) {
        $script:divisoes += $node
    } else {
        $parent = $script:stack[$script:stack.Count - 1]
        [void]$parent.divisoes.Add($node)
    }

    [void]$script:stack.Add($node)
    $script:currentContainer = $node
    $script:pendingTitleFor = $node
}

function Add-Article($artigo) {
    if ($script:inAdct) {
        [void]$script:adct.artigos.Add($artigo)
        return
    }

    if ($null -eq $script:currentContainer) {
        $fallback = New-Division 'titulo' 'TEXTO CONSTITUCIONAL' $artigo.linha
        $script:divisoes += $fallback
        [void]$script:stack.Add($fallback)
        $script:currentContainer = $fallback
    }

    $parent = $script:currentContainer
    [void]$parent.artigos.Add($artigo)
}

function Append-ToTextProperty($target, [string]$property, [string]$text) {
    $clean = Clean-Text $text
    if (-not $clean) { return }

    $current = ''
    if ($target.PSObject.Properties[$property]) {
        $current = [string]$target.$property
    }

    $target.$property = (Clean-Text "$current $clean")
}

function Is-StructuralLine([string]$line) {
    return (
        $line -match $reTitulo -or
        $line -match $reCapitulo -or
        $line -match $reSecao -or
        $line -match $reSubsecao -or
        $line -match $reArt -or
        $line -ceq 'ATO DAS DISPOSIÇÕES CONSTITUCIONAIS TRANSITÓRIAS'
    )
}

Write-Host "Iniciando parse..." -ForegroundColor Cyan

for ($i = 0; $i -lt $totalLines; $i++) {
    $trim = $lines[$i].Trim()
    $ln = $i + 1
    if ([string]::IsNullOrWhiteSpace($trim)) { continue }

    if ($script:contentFinished) { continue }

    if ($trim -ceq 'TÍTULO I') {
        $script:inMainText = $true
    }

    if ($script:inMainText -and $trim -ceq 'ATO DAS DISPOSIÇÕES CONSTITUCIONAIS TRANSITÓRIAS') {
        $script:inAdct = $true
        $script:skipUntilAdct = $false
        $script:stack.Clear()
        $script:currentContainer = $null
        $script:currentArticle = $null
        $script:currentPart = $null
        $script:adct = [pscustomobject]@{
            tipo    = 'adct'
            rotulo  = $trim
            linha   = $ln
            artigos = [System.Collections.ArrayList]::new()
        }
        continue
    }

    if ($script:skipUntilAdct) { continue }

    # Preserve original "skip until ADCT marker" behavior for the Brasília line that appears
    # before the ADCT section in this particular TXT layout.
    if ($script:inMainText -and -not $script:inAdct -and $trim -like 'Brasília, 5 de outubro de 1988*') {
        $script:skipUntilAdct = $true
        continue
    }

    # Only after we have entered the ADCT do we treat a (final) Brasília line as permanent end of content.
    # This prevents the signers list from being appended to the last ADCT article(s).
    if ($script:inAdct -and ($trim -like 'Brasília, 5 de outubro de 1988*') -and ($trim.Length -lt 100)) {
        $script:contentFinished = $true
        $script:currentArticle = $null
        $script:currentPart = $null
        continue
    }

    if (-not $script:inMainText -and -not $script:inAdct) {
        if ($trim -ceq 'PREÂMBULO') {
            $script:preambulo += [pscustomobject]@{ texto = $trim; linha = $ln }
            continue
        }

        if ($script:preambulo.Count -gt 0) {
            $script:preambulo += [pscustomobject]@{ texto = Clean-Text $trim; linha = $ln }
        }
        continue
    }

    $division = $null
    if ($trim -match $reTitulo) {
        $division = New-Division 'titulo' $trim $ln
    } elseif ($trim -match $reCapitulo) {
        $division = New-Division 'capitulo' $trim $ln
    } elseif ($trim -match $reSecao) {
        $division = New-Division 'secao' $trim $ln
    } elseif ($trim -match $reSubsecao) {
        $division = New-Division 'subsecao' $trim $ln
    }

    if ($division) {
        Add-Division $division
        $script:currentArticle = $null
        $script:currentPart = $null
        continue
    }

    if ($script:pendingTitleFor -and -not (Is-StructuralLine $trim)) {
        $script:pendingTitleFor | Add-Member -NotePropertyName titulo -NotePropertyValue (Clean-Text $trim) -Force
        $script:pendingTitleFor | Add-Member -NotePropertyName linhaTitulo -NotePropertyValue $ln -Force
        $script:pendingTitleFor = $null
        continue
    }

    if ($trim -match $reArt) {
        # Capture groups immediately to avoid $Matches being overwritten by other -match calls (e.g. inside Is-StructuralLine)
        $artMatchNum   = $Matches[1]
        $artMatchOrd   = $Matches[2]
        $artMatchRest  = $Matches[3]

        $numero = Normalize-NumeroArtigo $artMatchNum $artMatchOrd
        $rotulo = if ($numero -match 'º$') { "Art. $numero" } else { "Art. $numero." }
        $script:currentArticle = New-Artigo $numero $rotulo $ln $artMatchRest $script:inAdct
        Add-Article $script:currentArticle
        $script:currentPart = $script:currentArticle
        $script:artCount++

        # Belt-and-suspenders: ensure initial caput text from the Art line is never lost for early articles / ADCT
        if (-not [string]::IsNullOrWhiteSpace($artMatchRest) -and [string]::IsNullOrWhiteSpace($script:currentArticle.caput)) {
            $script:currentArticle.caput = Clean-Text $artMatchRest
        }

        # An Art line should never be consumed as a division title
        $script:pendingTitleFor = $null

        if ($MaxArticles -gt 0 -and $script:artCount -ge $MaxArticles) {
            break
        }
        continue
    }

    if (-not $script:currentArticle) { continue }

    if ($trim -match $reParagrafo) {
        if (-not $script:currentArticle.PSObject.Properties['paragrafos']) {
            $script:currentArticle | Add-Member -NotePropertyName paragrafos -NotePropertyValue ([System.Collections.ArrayList]::new())
        }

        $rawLabel = Clean-Text $Matches[1]
        $numeroParagrafo = if ($rawLabel -match 'Parágrafo único') { 'único' } else { "$($Matches[2])º" }
        $parRest = $Matches[3]
        $paragrafo = New-Paragrafo $numeroParagrafo $rawLabel $ln $parRest
        [void]$script:currentArticle.paragrafos.Add($paragrafo)
        $script:currentPart = $paragrafo

        # Safety: ensure paragraph text from the line is captured
        if (-not [string]::IsNullOrWhiteSpace($parRest) -and [string]::IsNullOrWhiteSpace($paragrafo.texto)) {
            $paragrafo.texto = Clean-Text $parRest
        }
        continue
    }

    if ($trim -match $reInciso) {
        if (-not $script:currentArticle.PSObject.Properties['incisos']) {
            $script:currentArticle | Add-Member -NotePropertyName incisos -NotePropertyValue ([System.Collections.ArrayList]::new())
        }

        $incRest = $Matches[2]
        $inciso = New-Inciso $Matches[1] $ln $incRest
        [void]$script:currentArticle.incisos.Add($inciso)
        $script:currentPart = $inciso

        if (-not [string]::IsNullOrWhiteSpace($incRest) -and [string]::IsNullOrWhiteSpace($inciso.texto)) {
            $inciso.texto = Clean-Text $incRest
        }
        continue
    }

    if ($trim -match $reAlinea) {
        if ($script:currentPart -and -not $script:currentPart.PSObject.Properties['alineas']) {
            $script:currentPart | Add-Member -NotePropertyName alineas -NotePropertyValue ([System.Collections.ArrayList]::new())
        }

        if ($script:currentPart -and $script:currentPart.PSObject.Properties['alineas']) {
            $alRest = $Matches[2]
            $alinea = New-Alinea $Matches[1] $ln $alRest
            [void]$script:currentPart.alineas.Add($alinea)
            $script:currentPart = $alinea

            if (-not [string]::IsNullOrWhiteSpace($alRest) -and [string]::IsNullOrWhiteSpace($alinea.texto)) {
                $alinea.texto = Clean-Text $alRest
            }
        }
        continue
    }

    if ($script:currentPart -and -not $script:contentFinished) {
        if ($script:currentPart.PSObject.Properties['texto']) {
            Append-ToTextProperty $script:currentPart 'texto' $trim
        } elseif ($script:currentPart.PSObject.Properties['caput']) {
            Append-ToTextProperty $script:currentPart 'caput' $trim
        }
    }
}

# Final safety net: ensure the last ADCT article was not polluted by the signers list
# (Brasília + names appear after ADCT content in this TXT layout)
if ($script:adct -and $script:adct.artigos -and $script:adct.artigos.Count -gt 0) {
    $last = $script:adct.artigos[-1]
    if ($last.PSObject.Properties['caput']) {
        $c = [string]$last.caput
        $idx = $c.IndexOf('Brasília, 5 de outubro de 1988', [StringComparison]::OrdinalIgnoreCase)
        if ($idx -ge 0) {
            $last.caput = Clean-Text $c.Substring(0, $idx)
        }
    }
    # Also sanitize common sub-parts of the last article if they got polluted
    foreach ($propName in 'paragrafos','incisos','alineas') {
        if ($last.PSObject.Properties[$propName]) {
            $subs = $last.$propName
            if ($subs -and $subs.Count -gt 0) {
                $lastSub = $subs[-1]
                if ($lastSub.PSObject.Properties['texto']) {
                    $t = [string]$lastSub.texto
                    $idx2 = $t.IndexOf('Brasília, 5 de outubro de 1988', [StringComparison]::OrdinalIgnoreCase)
                    if ($idx2 -ge 0) {
                        $lastSub.texto = Clean-Text $t.Substring(0, $idx2)
                    }
                }
            }
        }
    }
}

$root = [ordered]@{
    id             = 'Constituição_Federal_de_1988'
    titulo         = 'Constituição Federal de 1988'
    apelido        = 'Constituição Federal de 1988.'
    sigla          = 'CF/88'
    fonte          = 'constituicao_federal_de_1988.txt'
    fonteHtmlLocal = 'constituicao.htm'
    fonteOficial   = 'https://www.planalto.gov.br/ccivil_03/constituicao/constituicao.htm'
    preambulo      = $script:preambulo
    divisoes       = $script:divisoes
}

if ($script:adct) {
    $root.adct = $script:adct
}

function Get-ArtigoCount($value) {
    if ($null -eq $value) { return 0 }
    if ($value -is [System.Array] -or $value -is [System.Collections.ArrayList]) {
        $sum = 0
        foreach ($item in $value) { $sum += Get-ArtigoCount $item }
        return $sum
    }
    if ($value -is [pscustomobject] -or $value -is [System.Collections.Specialized.OrderedDictionary]) {
        $sum = 0
        foreach ($prop in $value.PSObject.Properties) {
            if ($prop.Name -eq 'artigos' -and ($prop.Value -is [System.Array] -or $prop.Value -is [System.Collections.ArrayList])) {
                $sum += $prop.Value.Count
            }
            $sum += Get-ArtigoCount $prop.Value
        }
        return $sum
    }
    return 0
}

$mainArtCount = Get-ArtigoCount $script:divisoes
$adctArtCount = Get-ArtigoCount $script:adct
$finalArtCount = Get-ArtigoCount ([pscustomobject]$root)

Write-Host ""
Write-Host "=== ESTATISTICAS ===" -ForegroundColor Cyan
Write-Host "Linhas de artigo processadas: $script:artCount" -ForegroundColor DarkGray
Write-Host "Artigos no texto principal: $mainArtCount" -ForegroundColor DarkGray
Write-Host "Artigos no ADCT: $adctArtCount" -ForegroundColor DarkGray
Write-Host "Artigos no JSON gerado: $finalArtCount" -ForegroundColor Green
Write-Host "Audios catalogados: $($audioCatalog.Count)" -ForegroundColor DarkGray

if ($finalArtCount -lt 300 -and $MaxArticles -eq 0) {
    Write-Warning "Contagem de artigos baixa. Verifique o parser ou o TXT."
}

Write-Host ""
Write-Host "Gerando JSON..." -ForegroundColor Cyan
$jsonText = $root | ConvertTo-Json -Depth 30
$jsonText = $jsonText -replace '  ', '    '
[System.IO.File]::WriteAllText($outJsonPath, $jsonText, [System.Text.UTF8Encoding]::new($false))

Write-Host "JSON salvo em: $outJsonPath" -ForegroundColor Green
Write-Host "Concluido." -ForegroundColor Green

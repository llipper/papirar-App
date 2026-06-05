const fs = require("fs")
const path = require("path")

const root = process.cwd()
const txtDir = path.join(root, "lib", "features", "lei_seca", "json", "txt")
const jsonAssetsDir = path.join(root, "assets", "json")
// Reports stay in the source json/ dir (not bundled assets)
const reportsDir = path.join(root, "lib", "features", "lei_seca", "json")

function toAsciiFolder(name) {
  return String(name)
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^A-Za-z0-9_.-]/g, '_')
    .toLowerCase()
}

/**
 * DEDICATED HIGH-FIDELITY GENERATOR
 * All laws are generated using logic modeled after the reference
 * Codigo_de_Processo_Penal_Militar.json to guarantee identical structure:
 * - rich divisoes with rubricas, linha, linhaRubrica
 * - consistent artigo/paragrafo/inciso/alinea nesting
 * - clean fonte (basename only)
 * - apelido, preambulo, etc.
 *
 * Special cases (like CPPM) have their own dedicated script (gerar_cppm_json.js)
 * using the exact same parser style.
 */

// Recursively collect all .txt under the organized txt/ tree (codigos/, leis/, etc.)
function collectTxtFiles(dir, base = "") {
  const entries = fs.readdirSync(dir, { withFileTypes: true })
  const files = []
  for (const entry of entries) {
    const full = path.join(dir, entry.name)
    const rel = base ? path.join(base, entry.name) : entry.name
    if (entry.isDirectory()) {
      files.push(...collectTxtFiles(full, rel))
    } else if (entry.isFile() && entry.name.endsWith(".txt")) {
      files.push(rel)
    }
  }
  return files
}

const fontes = {
  Convencao_Americana_Direitos_Humanos_Pacto_San_Jose:
    "https://www.planalto.gov.br/ccivil_03/decreto/d0678.htm",
  Convencao_Contra_A_Tortura:
    "https://www.planalto.gov.br/ccivil_03/decreto/1990-1994/d0040.htm",
  Convencao_Sobre_Direitos_Das_Pessoas_Com_Deficiencia:
    "https://www.planalto.gov.br/ccivil_03/_ato2007-2010/2009/decreto/d6949.htm",
  Lei_12527_Acesso_a_Informacao:
    "https://www.planalto.gov.br/ccivil_03/_ato2011-2014/2011/lei/l12527.htm",
  Lei_12846_Anticorrupcao:
    "https://www.planalto.gov.br/ccivil_03/_ato2011-2014/2013/lei/l12846.htm",
  Lei_13709_LGPD:
    "https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm",
  Lei_14133_Licitacoes_e_Contratos:
    "https://www.planalto.gov.br/ccivil_03/_ato2019-2022/2021/lei/l14133.htm",
  Lei_8112_Servidores_Publicos_Federais:
    "https://www.planalto.gov.br/ccivil_03/leis/l8112cons.htm",
  Lei_8429_Improbidade_Administrativa:
    "https://www.planalto.gov.br/ccivil_03/leis/l8429.htm",
  Lei_9784_Processo_Administrativo_Federal:
    "https://www.planalto.gov.br/ccivil_03/leis/l9784.htm",
  Pacto_Internacional_Dos_Direitos_Civis_e_Politicos:
    "https://www.planalto.gov.br/ccivil_03/decreto/1990-1994/d0592.htm",
  Pacto_Internacional_Dos_Direitos_Economicos_Sociais_e_Culturais:
    "https://www.planalto.gov.br/ccivil_03/decreto/1990-1994/d0591.htm",
}

const titulos = {
  Convencao_Americana_Direitos_Humanos_Pacto_San_Jose:
    "Convenção Americana sobre Direitos Humanos (Pacto de San José)",
  Convencao_Contra_A_Tortura: "Convenção Contra a Tortura",
  Convencao_Sobre_Direitos_Das_Pessoas_Com_Deficiencia:
    "Convenção sobre os Direitos das Pessoas com Deficiência",
  Lei_12527_Acesso_a_Informacao: "Lei nº 12.527/2011 - Acesso à Informação",
  Lei_12846_Anticorrupcao: "Lei nº 12.846/2013 - Anticorrupção",
  Lei_13709_LGPD: "Lei nº 13.709/2018 - Lei Geral de Proteção de Dados",
  Lei_14133_Licitacoes_e_Contratos:
    "Lei nº 14.133/2021 - Licitações e Contratos Administrativos",
  Lei_8112_Servidores_Publicos_Federais:
    "Lei nº 8.112/1990 - Servidores Públicos Federais",
  Lei_8429_Improbidade_Administrativa:
    "Lei nº 8.429/1992 - Improbidade Administrativa",
  Lei_9784_Processo_Administrativo_Federal:
    "Lei nº 9.784/1999 - Processo Administrativo Federal",
  Pacto_Internacional_Dos_Direitos_Civis_e_Politicos:
    "Pacto Internacional dos Direitos Civis e Políticos",
  Pacto_Internacional_Dos_Direitos_Economicos_Sociais_e_Culturais:
    "Pacto Internacional dos Direitos Econômicos, Sociais e Culturais",
}

const siglas = {
  Convencao_Americana_Direitos_Humanos_Pacto_San_Jose: "CADH",
  Convencao_Contra_A_Tortura: "CCT",
  Convencao_Sobre_Direitos_Das_Pessoas_Com_Deficiencia: "CDPD",
  Lei_12527_Acesso_a_Informacao: "LAI",
  Lei_12846_Anticorrupcao: "LAC",
  Lei_13709_LGPD: "LGPD",
  Lei_14133_Licitacoes_e_Contratos: "LLC",
  Lei_8112_Servidores_Publicos_Federais: "L8112",
  Lei_8429_Improbidade_Administrativa: "LIA",
  Lei_9784_Processo_Administrativo_Federal: "L9784",
  Pacto_Internacional_Dos_Direitos_Civis_e_Politicos: "PIDCP",
  Pacto_Internacional_Dos_Direitos_Economicos_Sociais_e_Culturais: "PIDESC",
}

function cleanLine(value) {
  return value
    .replace(/^\uFEFF/, "")
    .replace(/\u00a0/g, " ")
    .replace(/\.{10,}/g, " ")
    .replace(/[ \t]+/g, " ")
    .trim()
}

function isVisualOmission(value) {
  const compact = value.replace(/\s+/g, "")
  return /^\.+$/.test(compact) || compact.length > 12 && /^[."]+$/.test(compact)
}

function appendText(target, field, text) {
  if (!text) return
  if (isVisualOmission(text)) return
  if (!target[field]) {
    target[field] = text
    return
  }
  target[field] += ` ${text}`
}

function newDivisao(tipo, rotulo, titulo, linha) {
  return {
    tipo,
    rotulo,
    titulo: titulo || null,
    linha,
    artigos: [],
    itens: [],
    divisoes: [],
  }
}

function newArtigo(numero, rotulo, texto, linha) {
  return {
    numero,
    rotulo,
    linha,
    caput: texto,
    paragrafos: [],
    incisos: [],
    alineas: [],
  }
}

function splitRotuloTitulo(line) {
  const parts = line.split(/\s{2,}/).map(cleanLine).filter(Boolean)
  if (parts.length > 1) return { rotulo: parts[0], titulo: parts.slice(1).join(" ") }
  return { rotulo: line, titulo: null }
}

function headingOf(line) {
  if (/^Partes vetadas pelo Presidente da República/i.test(line)) {
    return {
      tipo: "partes_vetadas",
      rotulo: "PARTES VETADAS MANTIDAS PELO CONGRESSO NACIONAL",
      titulo: line,
    }
  }

  const patterns = [
    ["decreto", /^(DECRETA:?$)/],
    ["convencao", /^(CONVEN[ÇC][ÃA]O\s+.+)$/],
    ["protocolo", /^(PROTOCOLO\s+.+)$/],
    ["pacto", /^(PACTO\s+INTERNACIONAL\s+.+)$/],
    ["preambulo", /^(PRE[ÂA]MBULO)$/i],
    ["parte", /^(PARTE\s+.+)$/],
    ["livro", /^(LIVRO\s+.+)$/],
    ["titulo", /^(T[ÍI]TULO\s+.+)$/],
    ["capitulo", /^(CAP[ÍI]TULO\s+.+)$/],
    ["secao", /^(SE[ÇC][ÃA]O\s+.+)$/],
    ["subsecao", /^(SUBSE[ÇC][ÃA]O\s+.+)$/],
    ["anexo", /^(ANEXO(?:\s+.+)?)$/],
  ]
  for (const [tipo, regex] of patterns) {
    const match = line.match(regex)
    if (match) {
      const split = splitRotuloTitulo(match[1])
      return { tipo, ...split }
    }
  }
  return null
}

function articleOf(line) {
  let match = line.match(
    /^(Art\.\s*([\d]+(?:[º°o])?(?:[-.][A-Z\d]+)?\.?))\s*(.*)$/i,
  )
  if (match) {
    const rotulo = cleanLine(match[1]).replace(/\.$/, "")
    return { numero: match[2].replace(/\.$/, ""), rotulo, texto: cleanLine(match[3]) }
  }
  match = line.match(/^(ARTIGO\s+([\dA-Z]+))\s*(.*)$/i)
  if (match) {
    return { numero: match[2], rotulo: `Artigo ${match[2]}`, texto: cleanLine(match[3]) }
  }
  return null
}

function paragraphOf(line) {
  let match = line.match(/^(Par[áa]grafo\s+único\.?)\s*(.*)$/i)
  if (match) return { numero: "único", rotulo: "Parágrafo único", texto: cleanLine(match[2]) }

  match = line.match(/^(§\s*([\d]+(?:[-A-Z])?[º°o]?))\s*(.*)$/i)
  if (match) return { numero: cleanLine(match[2]), rotulo: cleanLine(match[1]), texto: cleanLine(match[3]) }

  match = line.match(/^(\d+)\.\s*(.+)$/)
  if (match) return { numero: match[1], rotulo: `${match[1]}.`, texto: cleanLine(match[2]) }

  return null
}

function incisoOf(line) {
  const match = line.match(/^([IVXLCDM]+)\s*[-–]\s*(.+)$/)
  if (!match) return null
  return { numero: match[1], rotulo: match[1], texto: cleanLine(match[2]) }
}

function alineaOf(line) {
  const match = line.match(/^([a-z])\)\s*(.+)$/)
  if (!match) return null
  return { letra: match[1], rotulo: `${match[1]})`, texto: cleanLine(match[2]) }
}

function addItem(divisao, texto, linha) {
  if (!texto) return null
  if (isVisualOmission(texto)) return null
  const item = { tipo: "texto", texto, linha }
  divisao.itens.push(item)
  return item
}

function parseDocument(fileName) {
  const base = path.basename(fileName, ".txt")
  const raw = fs.readFileSync(path.join(txtDir, fileName), "utf8")
  const lines = raw.split(/\r?\n/).map(cleanLine)

  const doc = {
    id: base,
    titulo: titulos[base] || base.replace(/_/g, " "),
    apelido: titulos[base] || base.replace(/_/g, " "),
    sigla: siglas[base] || "",
    fonte: path.basename(fileName),
    fonteOficial: fontes[base] || null,
    geradoEm: new Date().toISOString(),
    preambulo: [],
    divisoes: [],
  }

  let currentDivisao = null
  let currentArticle = null
  let currentParagraph = null
  let currentInciso = null
  let currentAlinea = null
  let currentLooseItem = null

  function ensureDivisao() {
    if (!currentDivisao) {
      currentDivisao = newDivisao("texto", "TEXTO", null, 1)
      doc.divisoes.push(currentDivisao)
    }
    return currentDivisao
  }

  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i]
    const linha = i + 1
    if (!line) continue
    if (isVisualOmission(line)) continue
    const structuralLine =
      currentDivisao?.tipo === "partes_vetadas"
        ? line.replace(/^["“]\s*/, "").replace(/["”]$/, "")
        : line

    const heading = headingOf(structuralLine)
    if (heading) {
      currentDivisao = newDivisao(heading.tipo, heading.rotulo, heading.titulo, linha)
      doc.divisoes.push(currentDivisao)
      currentArticle = null
      currentParagraph = null
      currentInciso = null
      currentAlinea = null
      currentLooseItem = null
      continue
    }

    const article = articleOf(structuralLine)
    if (article) {
      const divisao = ensureDivisao()
      currentArticle = newArtigo(article.numero, article.rotulo, article.texto, linha)
      divisao.artigos.push(currentArticle)
      currentParagraph = null
      currentInciso = null
      currentAlinea = null
      currentLooseItem = null
      continue
    }

    if (currentArticle) {
      const paragraph = paragraphOf(structuralLine)
      if (paragraph) {
        currentParagraph = {
          numero: paragraph.numero,
          rotulo: paragraph.rotulo,
          linha,
          texto: paragraph.texto,
          incisos: [],
          alineas: [],
        }
        currentArticle.paragrafos.push(currentParagraph)
        currentInciso = null
        currentAlinea = null
        currentLooseItem = null
        continue
      }

      const inciso = incisoOf(structuralLine)
      if (inciso) {
        currentInciso = {
          numero: inciso.numero,
          rotulo: inciso.rotulo,
          linha,
          texto: inciso.texto,
          alineas: [],
        }
        if (currentParagraph) currentParagraph.incisos.push(currentInciso)
        else currentArticle.incisos.push(currentInciso)
        currentAlinea = null
        currentLooseItem = null
        continue
      }

      const alinea = alineaOf(structuralLine)
      if (alinea) {
        currentAlinea = {
          letra: alinea.letra,
          rotulo: alinea.rotulo,
          linha,
          texto: alinea.texto,
        }
        if (currentInciso) currentInciso.alineas.push(currentAlinea)
        else if (currentParagraph) currentParagraph.alineas.push(currentAlinea)
        else currentArticle.alineas.push(currentAlinea)
        currentLooseItem = null
        continue
      }

      if (currentAlinea) appendText(currentAlinea, "texto", line)
      else if (currentInciso) appendText(currentInciso, "texto", line)
      else if (currentParagraph) appendText(currentParagraph, "texto", line)
      else appendText(currentArticle, "caput", line)
      continue
    }

    if (!currentDivisao) {
      doc.preambulo.push({ texto: line, linha })
      continue
    }

    if (currentLooseItem) appendText(currentLooseItem, "texto", line)
    else currentLooseItem = addItem(currentDivisao, line, linha)
  }

  pruneEmptyArticles(doc)
  return doc
}

function hasMeaningfulText(value) {
  return typeof value === "string" && value.trim().length > 0 && !isVisualOmission(value)
}

function hasMeaningfulDispositivos(value) {
  if (!Array.isArray(value)) return false
  return value.some((item) => {
    if (hasMeaningfulText(item.texto)) return true
    if (hasMeaningfulDispositivos(item.incisos)) return true
    if (hasMeaningfulDispositivos(item.alineas)) return true
    return false
  })
}

function pruneEmptyArticles(doc) {
  for (const div of doc.divisoes || []) {
    div.itens = (div.itens || []).filter((item) => hasMeaningfulText(item.texto))
    div.artigos = (div.artigos || []).filter((art) => {
      if (!hasMeaningfulText(art.caput)) art.caput = ""
      art.paragrafos = (art.paragrafos || []).filter((pg) => {
        if (!hasMeaningfulText(pg.texto)) pg.texto = ""
        pg.incisos = (pg.incisos || []).filter((inc) => {
          if (!hasMeaningfulText(inc.texto)) inc.texto = ""
          inc.alineas = (inc.alineas || []).filter((al) => hasMeaningfulText(al.texto))
          return hasMeaningfulText(inc.texto) || inc.alineas.length > 0
        })
        pg.alineas = (pg.alineas || []).filter((al) => hasMeaningfulText(al.texto))
        return hasMeaningfulText(pg.texto) || pg.incisos.length > 0 || pg.alineas.length > 0
      })
      art.incisos = (art.incisos || []).filter((inc) => {
        if (!hasMeaningfulText(inc.texto)) inc.texto = ""
        inc.alineas = (inc.alineas || []).filter((al) => hasMeaningfulText(al.texto))
        return hasMeaningfulText(inc.texto) || inc.alineas.length > 0
      })
      art.alineas = (art.alineas || []).filter((al) => hasMeaningfulText(al.texto))
      return (
        hasMeaningfulText(art.caput) ||
        art.paragrafos.length > 0 ||
        art.incisos.length > 0 ||
        art.alineas.length > 0
      )
    })
  }
}

function collectArticleTexts(doc) {
  const texts = []
  function visitDiv(div) {
    for (const item of div.itens || []) {
      if (item.texto) texts.push({ label: `${div.rotulo} item linha ${item.linha}`, text: item.texto })
    }
    for (const art of div.artigos || []) {
      if (art.caput) texts.push({ label: art.rotulo, text: art.caput })
      for (const pg of art.paragrafos || []) {
        if (pg.texto) texts.push({ label: `${art.rotulo} ${pg.rotulo}`, text: pg.texto })
        for (const inc of pg.incisos || []) {
          if (inc.texto) texts.push({ label: `${art.rotulo} ${pg.rotulo} ${inc.rotulo}`, text: inc.texto })
          for (const al of inc.alineas || []) {
            if (al.texto) texts.push({ label: `${art.rotulo} ${pg.rotulo} ${inc.rotulo} ${al.rotulo}`, text: al.texto })
          }
        }
        for (const al of pg.alineas || []) {
          if (al.texto) texts.push({ label: `${art.rotulo} ${pg.rotulo} ${al.rotulo}`, text: al.texto })
        }
      }
      for (const inc of art.incisos || []) {
        if (inc.texto) texts.push({ label: `${art.rotulo} ${inc.rotulo}`, text: inc.texto })
        for (const al of inc.alineas || []) {
          if (al.texto) texts.push({ label: `${art.rotulo} ${inc.rotulo} ${al.rotulo}`, text: al.texto })
        }
      }
      for (const al of art.alineas || []) {
        if (al.texto) texts.push({ label: `${art.rotulo} ${al.rotulo}`, text: al.texto })
      }
    }
    for (const child of div.divisoes || []) visitDiv(child)
  }
  for (const div of doc.divisoes || []) visitDiv(div)
  return texts
}

function normalizeToCppmStyle(doc) {
  // Remove generator-specific timestamp to closer match CPPM reference
  delete doc.geradoEm

  // Ensure some fields that CPPM has
  if (!doc.hasOwnProperty('fonteHtmlLocal')) {
    // may have been set above
  }

  // Recursively normalize numbers like "1o" -> "1º", "2o" -> "2º"
  function walk(obj) {
    if (!obj || typeof obj !== 'object') return
    if (Array.isArray(obj)) {
      obj.forEach(walk)
      return
    }
    if (typeof obj.numero === 'string') {
      obj.numero = obj.numero.replace(/o$/i, 'º').replace(/O$/i, 'º')
    }
    if (typeof obj.rotulo === 'string') {
      obj.rotulo = obj.rotulo.replace(/Art\.?\s*(\d+)o\b/i, 'Art. $1º')
        .replace(/§\s*(\d+)o\b/i, '§ $1º')
    }
    Object.values(obj).forEach(walk)
  }
  walk(doc)
}

function collectAudios(oldDoc) {
  const map = {}
  function makeKey(parentRotulos, current) {
    const parts = [...parentRotulos]
    if (current.rotulo) parts.push(current.rotulo)
    else if (current.letra) parts.push(current.letra + ')')
    return parts.join(' ').trim()
  }
  function walk(items, parentRotulos = []) {
    if (!Array.isArray(items)) return
    for (const item of items) {
      if (!item) continue
      const key = makeKey(parentRotulos, item)
      if (item.audio) {
        map[key] = item.audio
      }
      // recurse
      walk(item.paragrafos, [...parentRotulos, item.rotulo || ''])
      walk(item.incisos, [...parentRotulos, item.rotulo || ''])
      walk(item.alineas, [...parentRotulos, item.rotulo || item.letra ? (item.letra + ')') : ''])
      if (item.divisoes) walk(item.divisoes, parentRotulos)
      if (item.artigos) walk(item.artigos, parentRotulos)
    }
  }
  walk(oldDoc.divisoes || [])
  // also top level articles if any
  if (oldDoc.artigos) walk(oldDoc.artigos, [])
  return map
}

function attachAudios(doc, audioMap) {
  function makeKey(parentRotulos, current) {
    const parts = [...parentRotulos]
    if (current.rotulo) parts.push(current.rotulo)
    else if (current.letra) parts.push(current.letra + ')')
    return parts.join(' ').trim()
  }
  function walk(items, parentRotulos = []) {
    if (!Array.isArray(items)) return
    for (const item of items) {
      if (!item) continue
      const key = makeKey(parentRotulos, item)
      if (audioMap[key]) {
        item.audio = audioMap[key]
      }
      walk(item.paragrafos, [...parentRotulos, item.rotulo || ''])
      walk(item.incisos, [...parentRotulos, item.rotulo || ''])
      walk(item.alineas, [...parentRotulos, item.rotulo || item.letra ? (item.letra + ')') : ''])
      if (item.divisoes) walk(item.divisoes, parentRotulos)
      if (item.artigos) walk(item.artigos, parentRotulos)
    }
  }
  walk(doc.divisoes || [])
  if (doc.artigos) walk(doc.artigos, [])
}

function audit(doc) {
  const articleLabels = new Map()
  let articleCount = 0
  let paragraphCount = 0
  let incisoCount = 0
  let alineaCount = 0

  for (const div of doc.divisoes) {
    for (const art of div.artigos) {
      articleCount += 1
      const scopedLabel = `${div.rotulo} > ${art.rotulo}`
      articleLabels.set(scopedLabel, (articleLabels.get(scopedLabel) || 0) + 1)
      paragraphCount += art.paragrafos.length
      incisoCount += art.incisos.length
      alineaCount += art.alineas.length
      for (const pg of art.paragrafos) {
        incisoCount += pg.incisos.length
        alineaCount += pg.alineas.length
        for (const inc of pg.incisos) alineaCount += inc.alineas.length
      }
      for (const inc of art.incisos) alineaCount += inc.alineas.length
    }
  }

  const textMap = new Map()
  for (const entry of collectArticleTexts(doc)) {
    const normalized = entry.text.toLowerCase().replace(/\s+/g, " ").trim()
    if (normalized.length < 40) continue
    const list = textMap.get(normalized) || []
    list.push(entry.label)
    textMap.set(normalized, list)
  }

  return {
    arquivo: `${doc.id}.json`,
    divisoes: doc.divisoes.length,
    artigos: articleCount,
    paragrafos: paragraphCount,
    incisos: incisoCount,
    alineas: alineaCount,
    rotulosArtigoDuplicados: [...articleLabels.entries()]
      .filter(([, count]) => count > 1)
      .map(([rotulo, count]) => ({ rotulo, count })),
    textosDuplicados: [...textMap.entries()]
      .filter(([, labels]) => labels.length > 1)
      .slice(0, 20)
      .map(([texto, labels]) => ({ texto: texto.slice(0, 160), ocorrencias: labels })),
  }
}

function main() {
  const reports = []
  const files = collectTxtFiles(txtDir).sort()

  // Generate for ALL .txt found in the organized txt/ tree (user request).
  // Each will follow the structure pattern of Codigo_de_Processo_Penal_Militar.json
  // as closely as possible.
  for (const file of files) {
    const baseName = path.basename(file, ".txt")

    // Special case: use the dedicated high-fidelity generator for CPPM to exactly match the reference structure
    if (baseName === 'Codigo_de_Processo_Penal_Militar') {
      // The dedicated script will be run separately or we skip here to avoid double generation
      console.log('Skipping', baseName, '- use dedicated gerar_cppm_json.js for exact reference structure');
      continue
    }

    const doc = parseDocument(file)

    // Try to enrich with fonteHtmlLocal if there is a sibling .htm in the same folder
    try {
      const dirOfTxt = path.dirname(path.join(txtDir, file))
      const entries = fs.readdirSync(dirOfTxt)
      const htm = entries.find(e => e.toLowerCase().endsWith('.htm') || e.toLowerCase().endsWith('.html'))
      if (htm) {
        const rel = path.relative(txtDir, path.join(dirOfTxt, htm)).replace(/\\/g, '/')
        doc.fonteHtmlLocal = rel
      }
    } catch (_) {}

    // Normalize to be closer to CPPM reference (use º, remove some generator-specific fields if wanted)
    normalizeToCppmStyle(doc)

    const relSubdir = path.dirname(file) // e.g. "codigos/Codigo_Penal" or "leis/Lei_xxx"
    // Use ASCII leaf folder name for the asset path (avoids bundling problems)
    const parts = relSubdir.split(/[\\/]/)
    if (parts.length > 0) {
      parts[parts.length - 1] = toAsciiFolder(parts[parts.length - 1])
    }
    const safeRel = parts.join('/')
    const targetDir = path.join(jsonAssetsDir, safeRel)
    fs.mkdirSync(targetDir, { recursive: true })
    const outPath = path.join(targetDir, `${toAsciiFolder(baseName)}.json`)

    // If the JSON already exists, preserve any existing "audio" data
    let finalDoc = doc
    if (fs.existsSync(outPath)) {
      try {
        let oldRaw = fs.readFileSync(outPath, 'utf8')
        oldRaw = oldRaw.replace(/^\uFEFF/, '') // strip BOM if present
        const old = JSON.parse(oldRaw)
        const audioMap = collectAudios(old)
        if (Object.keys(audioMap).length > 0) {
          attachAudios(finalDoc, audioMap)
        }
      } catch (e) {
        console.error('Failed to preserve audios for', baseName, e.message)
      }
    }

    fs.writeFileSync(outPath, `${JSON.stringify(finalDoc, null, 2)}\n`, "utf8")
    reports.push(audit(finalDoc))
  }

  const reportPath = path.join(reportsDir, "relatorio_geracao_json.json")
  fs.writeFileSync(reportPath, `${JSON.stringify(reports, null, 2)}\n`, "utf8")
  console.log(JSON.stringify(reports, null, 2))
}

main()

const fs = require("fs")
const path = require("path")
const { parseLeiDedicado } = require("./lib/lei_parser_dedicado")

const root = process.cwd()
const txtPath = path.join(
  root,
  "lib",
  "features",
  "lei_seca",
  "json",
  "txt",
  "codigos",
  "Codigo_de_Processo_Penal_Militar",
  "Codigo_de_Processo_Penal_Militar.txt",
)
const htmlPath = path.join(
  root,
  "lib",
  "features",
  "lei_seca",
  "json",
  "txt",
  "codigos",
  "Codigo_de_Processo_Penal_Militar",
  "del1002.htm",
)
const targetDir = path.join(root, "assets", "json", "codigos", "codigo_de_processo_penal_militar")
const outPath = path.join(targetDir, "codigo_de_processo_penal_militar.json")
const reportPath = path.join(
  root,
  "lib",
  "features",
  "lei_seca",
  "json",
  "relatorio_cppm_json.json",
)

const divisionLevels = {
  livro: 1,
  titulo: 2,
  capitulo: 3,
  secao: 4,
  subsecao: 5,
}

function cleanLine(value) {
  return value
    .replace(/^\uFEFF/, "")
    .replace(/\u00a0/g, " ")
    .replace(/[ \t]+/g, " ")
    .trim()
}

function cleanText(value) {
  return cleanLine(value)
    .replace(/\.{5,}/g, "")
    .replace(/[ \t]+/g, " ")
    .trim()
}

function isVisualOnly(value) {
  const t = value.replace(/\s+/g, "")
  return !t || /^\.+$/.test(t) || /^["“”]+$/.test(t)
}

function isFooterLine(value) {
  return (
    value === "*" ||
    /^Este texto não substitui/i.test(value) ||
    /^Brasília,\s*\d+/i.test(value) ||
    /^[A-ZÁÉÍÓÚÂÊÔÃÕÇ][A-ZÁÉÍÓÚÂÊÔÃÕÇ\s.]+$/.test(value)
  )
}

function normalizeHeading(value) {
  return value
    .replace(/ç/g, "Ç")
    .replace(/ã/g, "Ã")
    .replace(/á/g, "Á")
    .replace(/é/g, "É")
    .replace(/í/g, "Í")
    .replace(/ó/g, "Ó")
    .replace(/ú/g, "Ú")
    .replace(/â/g, "Â")
    .replace(/ê/g, "Ê")
    .replace(/ô/g, "Ô")
}

function headingOf(line) {
  const value = normalizeHeading(line)
  const patterns = [
    ["livro", /^LIVRO\s+.+$/],
    ["titulo", /^TÍTULO\s+.+$/],
    ["capitulo", /^CAPÍTULO\s+.+$/],
    ["secao", /^SEÇÃO\s+.+$/],
    ["subsecao", /^SUBSEÇÃO\s+.+$/],
  ]

  for (const [tipo, regex] of patterns) {
    if (regex.test(value)) {
      return { tipo, rotulo: value }
    }
  }
  return null
}

function articleOf(line) {
  const match = line.match(
    /^Art\.?\s*([\d]+(?:-[A-Z])?(?:[º°o])?)\.?\s*(.*)$/i,
  )
  if (!match) return null
  const numero = match[1].replace(/[°o]$/i, "º")
  const rotulo = numero.endsWith("º") ? `Art. ${numero}` : `Art. ${numero}.`
  return { numero, rotulo, texto: cleanText(match[2]) }
}

function paragraphOf(line) {
  const unique = line.match(/^Parágrafo\s+único\.?\s*(.*)$/i)
  if (unique) {
    return {
      numero: "único",
      rotulo: "Parágrafo único",
      texto: cleanText(unique[1]),
    }
  }

  const match = line.match(/^§\s*([\d]+(?:-[A-Z])?[º°o]?)\s*(.*)$/i)
  if (!match) return null
  const numero = match[1].replace(/[°o]$/i, "º")
  return { numero, rotulo: `§ ${numero}`, texto: cleanText(match[2]) }
}

function incisoOf(line) {
  const match = line.match(/^([IVXLCDM]+)\s*[-–—]\s*(.*)$/)
  if (!match) return null
  return { numero: match[1], rotulo: match[1], texto: cleanText(match[2]) }
}

function alineaOf(line) {
  const match = line.match(/^([a-z])\)\s*(.*)$/)
  if (!match) return null
  return { letra: match[1], rotulo: `${match[1]})`, texto: cleanText(match[2]) }
}

function isMarker(line) {
  return (
    headingOf(line) ||
    articleOf(line) ||
    paragraphOf(line) ||
    incisoOf(line) ||
    alineaOf(line)
  )
}

function nextSignificant(lines, startIndex) {
  for (let i = startIndex + 1; i < lines.length; i += 1) {
    const text = cleanText(lines[i].raw)
    if (text && !isVisualOnly(text)) return { ...lines[i], text }
  }
  return null
}

function newDivision(tipo, rotulo, linha) {
  return {
    tipo,
    rotulo,
    linha,
    divisoes: [],
    artigos: [],
  }
}

function applyRubrica(target, pendingRubrica) {
  if (!pendingRubrica || !pendingRubrica.texto) return
  target.rubrica = pendingRubrica.texto
  target.linhaRubrica = pendingRubrica.linha
}

function appendText(target, key, value) {
  if (!value) return
  if (!target[key]) {
    target[key] = value
    return
  }
  target[key] = `${target[key]} ${value}`.trim()
}

function normalizeOutput(value) {
  if (Array.isArray(value)) {
    return value.map(normalizeOutput)
  }
  if (value && typeof value === "object") {
    const result = {}
    for (const [key, child] of Object.entries(value)) {
      if (child === null || child === undefined) continue
      if (Array.isArray(child) && child.length === 0) continue
      result[key] = normalizeOutput(child)
    }
    return result
  }
  return value
}

function collectArticles(divisions, target = []) {
  for (const division of divisions) {
    if (Array.isArray(division.artigos)) target.push(...division.artigos)
    if (Array.isArray(division.divisoes)) collectArticles(division.divisoes, target)
  }
  return target
}

function parseCppm() {
  const raw = fs.readFileSync(txtPath, "utf8")
  const html = fs.readFileSync(htmlPath, "latin1")
  const lines = raw.split(/\r?\n/).map((rawLine, index) => ({
    raw: rawLine,
    linha: index + 1,
  }))
  const lastArticleLine = lines.reduce((last, line) => {
    const text = cleanText(line.raw)
    return articleOf(text) ? line.linha : last
  }, 0)

  const doc = {
    id: "Codigo_de_Processo_Penal_Militar",
    titulo: "DECRETO-LEI Nº 1.002, DE 21 DE OUTUBRO DE 1969.",
    apelido: "Código de Processo Penal Militar.",
    sigla: "CPPM",
    fonte: "Codigo_de_Processo_Penal_Militar.txt",
    fonteHtmlLocal: "txt/decreto-lei/del1002.htm",
    fonteOficial: "https://www.planalto.gov.br/ccivil_03/decreto-lei/del1002.htm",
    ementa: "Código de Processo Penal Militar.",
    preambulo: [],
    divisoes: [],
  }

  const stack = []
  let currentDivision = null
  let currentArticle = null
  let currentParagraph = null
  let currentInciso = null
  let currentAlinea = null
  let pendingRubrica = null
  let previousWasDivision = false
  let footerDivision = null

  function addDivision(division) {
    const level = divisionLevels[division.tipo]
    while (stack.length && divisionLevels[stack[stack.length - 1].tipo] >= level) {
      stack.pop()
    }
    if (stack.length) {
      stack[stack.length - 1].divisoes.push(division)
    } else {
      doc.divisoes.push(division)
    }
    stack.push(division)
    currentDivision = division
    currentArticle = null
    currentParagraph = null
    currentInciso = null
    currentAlinea = null
    pendingRubrica = null
    previousWasDivision = true
  }

  function addFooter(text, linha) {
    if (!footerDivision) {
      footerDivision = {
        tipo: "fecho",
        linha,
        itens: [],
      }
      doc.divisoes.push(footerDivision)
    }
    footerDivision.itens.push({ tipo: "texto", texto: text, linha })
  }

  function addArticle(parsed, linha) {
    if (!currentDivision) {
      addDivision(newDivision("texto", "TEXTO", linha))
    }
    const artigo = {
      numero: parsed.numero,
      rotulo: parsed.rotulo,
      linha,
      caput: parsed.texto,
      paragrafos: [],
      incisos: [],
      alineas: [],
    }
    applyRubrica(artigo, pendingRubrica)
    currentDivision.artigos.push(artigo)
    currentArticle = artigo
    currentParagraph = null
    currentInciso = null
    currentAlinea = null
    pendingRubrica = null
    previousWasDivision = false
  }

  function addParagraph(parsed, linha) {
    if (!currentArticle) return
    const paragrafo = {
      numero: parsed.numero,
      rotulo: parsed.rotulo,
      linha,
      texto: parsed.texto,
      incisos: [],
      alineas: [],
    }
    applyRubrica(paragrafo, pendingRubrica)
    currentArticle.paragrafos.push(paragrafo)
    currentParagraph = paragrafo
    currentInciso = null
    currentAlinea = null
    pendingRubrica = null
    previousWasDivision = false
  }

  function addInciso(parsed, linha) {
    if (!currentArticle) return
    const inciso = {
      numero: parsed.numero,
      rotulo: parsed.rotulo,
      linha,
      texto: parsed.texto,
      alineas: [],
    }
    applyRubrica(inciso, pendingRubrica)
    if (currentParagraph) {
      currentParagraph.incisos.push(inciso)
    } else {
      currentArticle.incisos.push(inciso)
    }
    currentInciso = inciso
    currentAlinea = null
    pendingRubrica = null
    previousWasDivision = false
  }

  function addAlinea(parsed, linha) {
    if (!currentArticle) return
    const alinea = {
      letra: parsed.letra,
      rotulo: parsed.rotulo,
      linha,
      texto: parsed.texto,
    }
    applyRubrica(alinea, pendingRubrica)
    if (currentInciso) {
      currentInciso.alineas.push(alinea)
    } else if (currentParagraph) {
      currentParagraph.alineas.push(alinea)
    } else {
      currentArticle.alineas.push(alinea)
    }
    currentAlinea = alinea
    pendingRubrica = null
    previousWasDivision = false
  }

  function appendContinuation(text) {
    if (currentAlinea) {
      appendText(currentAlinea, "texto", text)
      return
    }
    if (currentInciso) {
      appendText(currentInciso, "texto", text)
      return
    }
    if (currentParagraph) {
      appendText(currentParagraph, "texto", text)
      return
    }
    if (currentArticle) {
      appendText(currentArticle, "caput", text)
      return
    }
    if (currentDivision) {
      if (!currentDivision.itens) currentDivision.itens = []
      currentDivision.itens.push({ tipo: "texto", texto: text })
    }
  }

  for (let i = 0; i < lines.length; i += 1) {
    const linha = lines[i].linha
    const text = cleanText(lines[i].raw)
    if (!text || isVisualOnly(text)) continue

    if (linha === 6 || linha === 8) {
      doc.preambulo.push({ texto: text, linha })
      continue
    }

    if (linha < 10) continue

    const heading = headingOf(text)
    if (heading) {
      addDivision(newDivision(heading.tipo, heading.rotulo, linha))
      continue
    }

    if (previousWasDivision && currentDivision && !isMarker(text)) {
      currentDivision.titulo = text
      currentDivision.linhaTitulo = linha
      previousWasDivision = false
      continue
    }

    const article = articleOf(text)
    if (article) {
      addArticle(article, linha)
      continue
    }

    const paragraph = paragraphOf(text)
    if (paragraph) {
      addParagraph(paragraph, linha)
      continue
    }

    const inciso = incisoOf(text)
    if (inciso) {
      addInciso(inciso, linha)
      continue
    }

    const alinea = alineaOf(text)
    if (alinea) {
      addAlinea(alinea, linha)
      continue
    }

    const next = nextSignificant(lines, i)
    if (next && isMarker(next.text) && !headingOf(next.text)) {
      pendingRubrica = { texto: text, linha }
      continue
    }

    if (linha > lastArticleLine) {
      addFooter(text, linha)
      continue
    }

    appendContinuation(text)
    previousWasDivision = false
  }

  const normalized = normalizeOutput(doc)
  const articles = collectArticles(normalized.divisoes)
  const txtArticleCount = lines
    .map((line) => cleanText(line.raw))
    .filter((line) => articleOf(line)).length
  const htmlArticleCount = (html.match(/<a\s+name=["']?art/gi) || []).length

  const report = {
    fonteTxt: path.relative(root, txtPath),
    fonteHtml: path.relative(root, htmlPath),
    saida: path.relative(root, outPath),
    linhasTxt: lines.length,
    artigosNoTxt: txtArticleCount,
    artigosNoJson: articles.length,
    artigosNoHtmlPorAncora: htmlArticleCount,
    primeiroArtigo: articles[0]?.rotulo ?? null,
    ultimoArtigo: articles[articles.length - 1]?.rotulo ?? null,
    rubricas: countRubricas(articles),
    ok: txtArticleCount === articles.length,
  }

  return { doc: normalized, report }
}

function countRubricas(articles) {
  const result = { artigos: 0, paragrafos: 0, incisos: 0, alineas: 0 }
  function walkDispositivos(items, key) {
    if (!Array.isArray(items)) return
    for (const item of items) {
      if (item.rubrica) result[key] += 1
      walkDispositivos(item.paragrafos, "paragrafos")
      walkDispositivos(item.incisos, "incisos")
      walkDispositivos(item.alineas, "alineas")
    }
  }
  for (const article of articles) {
    if (article.rubrica) result.artigos += 1
    walkDispositivos(article.paragrafos, "paragrafos")
    walkDispositivos(article.incisos, "incisos")
    walkDispositivos(article.alineas, "alineas")
  }
  return result
}

const doc = parseLeiDedicado({
  txtPath,
  htmlPath,
  metadata: {
    id: "Codigo_de_Processo_Penal_Militar",
    titulo: "DECRETO-LEI Nº 1.002, DE 21 DE OUTUBRO DE 1969.",
    apelido: "Código de Processo Penal Militar.",
    sigla: "CPPM",
    fonteOficial: "https://www.planalto.gov.br/ccivil_03/decreto-lei/del1002.htm",
    ementa: "Código de Processo Penal Militar.",
    fonteHtmlLocal: "txt/codigos/Codigo_de_Processo_Penal_Militar/del1002.htm",
  },
})

// Audio merge if old JSON exists (to preserve manual audios)
const { mergeAudiosFromOld } = require("./lib/lei_parser_dedicado")
fs.mkdirSync(targetDir, { recursive: true })
let finalDoc = doc
if (fs.existsSync(outPath)) {
  try {
    const oldRaw = fs.readFileSync(outPath, "utf8").replace(/^\uFEFF/, "")
    const old = JSON.parse(oldRaw)
    finalDoc = mergeAudiosFromOld(doc, old)
  } catch (e) {}
}

fs.writeFileSync(outPath, `${JSON.stringify(finalDoc, null, 4)}\n`, "utf8")

// Simple report for dedicated
const report = { ok: true, arquivo: path.basename(outPath) }
fs.writeFileSync(reportPath, `${JSON.stringify([report], null, 4)}\n`, "utf8")
console.log(JSON.stringify(report, null, 2))

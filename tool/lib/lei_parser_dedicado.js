const fs = require("fs")
const path = require("path")

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

function decodeHtmlEntities(value) {
  return value
    .replace(/&nbsp;|&#160;/gi, " ")
    .replace(/&ordm;|&#186;/gi, "º")
    .replace(/&ordf;|&#170;/gi, "ª")
    .replace(/&sect;|&#167;/gi, "§")
    .replace(/&amp;/gi, "&")
    .replace(/&quot;/gi, '"')
    .replace(/&#39;/gi, "'")
    .replace(/&lt;/gi, "<")
    .replace(/&gt;/gi, ">")
}

function htmlToText(value) {
  return cleanText(
    decodeHtmlEntities(
      value
        .replace(/<script[\s\S]*?<\/script>/gi, " ")
        .replace(/<style[\s\S]*?<\/style>/gi, " ")
        .replace(/<[^>]+>/g, " "),
    ),
  )
}

function extractHtmlLinks(html) {
  if (!html) return []

  const links = []
  const seen = new Set()
  const regex = /<a\b([^>]*)>([\s\S]*?)<\/a>/gi
  let match

  while ((match = regex.exec(html))) {
    const attrs = match[1] || ""
    const hrefMatch = attrs.match(/\bhref\s*=\s*(["'])(.*?)\1/i)
    if (!hrefMatch) continue

    const href = decodeHtmlEntities(hrefMatch[2]).trim()
    const texto = htmlToText(match[2])
    if (!href || !texto) continue

    const key = `${texto}::${href}`
    if (seen.has(key)) continue
    seen.add(key)
    links.push({ texto, href })
  }

  return links
}

function hasTokenBoundary(value, start, end) {
  const before = start > 0 ? value[start - 1] : ""
  const after = end < value.length ? value[end] : ""
  return !/[A-Za-zÀ-ÿ0-9]/.test(before) && !/[A-Za-zÀ-ÿ0-9]/.test(after)
}

function findLinkOccurrences(value, linkText) {
  const occurrences = []
  if (!value || !linkText) return occurrences

  let cursor = 0
  while (cursor < value.length) {
    const start = value.indexOf(linkText, cursor)
    if (start < 0) break

    const end = start + linkText.length
    if (linkText.length >= 4 || hasTokenBoundary(value, start, end)) {
      occurrences.push({ start, end })
    }
    cursor = end
  }

  return occurrences
}

function annotateFieldLinks(node, field, htmlLinks) {
  const value = typeof node[field] === "string" ? node[field] : ""
  if (!value) return

  const links = []
  const seen = new Set()

  for (const link of htmlLinks) {
    for (const occurrence of findLinkOccurrences(value, link.texto)) {
      const key = `${field}:${occurrence.start}:${occurrence.end}:${link.href}`
      if (seen.has(key)) continue
      seen.add(key)
      links.push({
        campo: field,
        texto: link.texto,
        href: link.href,
        inicio: occurrence.start,
        fim: occurrence.end,
      })
    }
  }

  if (!links.length) return
  node.links = [...(Array.isArray(node.links) ? node.links : []), ...links]
}

function annotateHtmlLinks(node, htmlLinks) {
  if (!node || typeof node !== "object" || !htmlLinks.length) return

  if (Array.isArray(node)) {
    node.forEach((item) => annotateHtmlLinks(item, htmlLinks))
    return
  }

  for (const field of ["texto", "caput", "rubrica", "titulo", "ementa"]) {
    annotateFieldLinks(node, field, htmlLinks)
  }

  for (const [key, child] of Object.entries(node)) {
    if (key === "links") continue
    if (child && typeof child === "object") annotateHtmlLinks(child, htmlLinks)
  }
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
  const normalized = value
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
  const compact = normalized.replace(/\s+/g, "")
  if (/^PARTE[A-ZÁÉÍÓÚÂÊÔÃÕÇ]+$/.test(compact)) {
    return compact.replace(/^PARTE/, "PARTE ")
  }
  return normalized
}

function headingOf(line) {
  const value = normalizeHeading(line)
  const patterns = [
    ["livro", /^LIVRO\s+.+$/],
    ["titulo", /^TÍTULO\s+.+$/],
    ["capitulo", /^CAPÍTULO\s+.+$/],
    ["secao", /^SEÇÃO\s+.+$/],
    ["subsecao", /^SUBSEÇÃO\s+.+$/],
    ["parte", /^PARTE\s+.+$/],
    ["anexo", /^ANEXO(?:\s+.+)?$/],
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
    /^Art\.?\s*(\d+)\s*(?:[º°o])?\s*(?:-([A-Z]))?\.?\s*(.*)$/i,
  )
  if (!match) return null
  const numeroBase = match[1]
  const sufixo = match[2] ? `-${match[2].toUpperCase()}` : ""
  const numero = `${numeroBase}º${sufixo}`
  return { numero, rotulo: `Art. ${numero}.`, texto: cleanText(match[3]) }
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

  const match = line.match(/^§\s*(\d+)\s*(?:[º°o])?\s*(?:-([A-Z]))?\.?\s*(.*)$/i)
  if (!match) return null
  const numero = `${match[1]}º${match[2] ? `-${match[2].toUpperCase()}` : ""}`
  return { numero, rotulo: `§ ${numero}`, texto: cleanText(match[3]) }
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
    itens: [],
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

function audioKeyPart(item) {
  return String(item.rotulo || item.letra || "")
    .replace(/^(Art\.?\s*[\wº°-]+)\.$/i, "$1")
    .trim()
}

/**
 * High-fidelity dedicated parser.
 * Produces output that matches the structure of Codigo_de_Processo_Penal_Militar.json
 */
function parseLeiDedicado({ txtPath, htmlPath = null, metadata = {} }) {
  const raw = fs.readFileSync(txtPath, "utf8")
  const html = htmlPath ? fs.readFileSync(htmlPath, "latin1") : ""
  const htmlLinks = extractHtmlLinks(html)
  const lines = raw.split(/\r?\n/).map((rawLine, index) => ({
    raw: rawLine,
    linha: index + 1,
  }))

  const lastArticleLine = lines.reduce((last, line) => {
    const text = cleanText(line.raw)
    return articleOf(text) ? line.linha : last
  }, 0)

  const base = path.basename(txtPath, ".txt")

  const doc = {
    id: metadata.id || base,
    titulo: metadata.titulo || base.replace(/_/g, " "),
    apelido: metadata.apelido || metadata.titulo || base.replace(/_/g, " "),
    sigla: metadata.sigla || "",
    fonte: path.basename(txtPath),
    fonteHtmlLocal: metadata.fonteHtmlLocal || (htmlPath ? path.relative(path.dirname(txtPath), htmlPath).replace(/\\/g, "/") : null),
    fonteOficial: metadata.fonteOficial || null,
    ementa: metadata.ementa || null,
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
    const level = divisionLevels[division.tipo] || 99
    while (stack.length && (divisionLevels[stack[stack.length - 1].tipo] || 99) >= level) {
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

  const divisionLevels = {
    livro: 1,
    titulo: 2,
    capitulo: 3,
    secao: 4,
    subsecao: 5,
  }

  for (let i = 0; i < lines.length; i += 1) {
    const linha = lines[i].linha
    const text = cleanText(lines[i].raw)
    if (!text || isVisualOnly(text)) continue

    // Preâmbulo for early lines (like CPPM)
    if (linha < 10 && !currentDivision) {
      doc.preambulo.push({ texto: text, linha })
      continue
    }

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

  if (htmlLinks.length) annotateHtmlLinks(doc, htmlLinks)
  const normalized = normalizeOutput(doc)
  return normalized
}

function mergeAudiosFromOld(newDoc, oldDoc) {
  if (!oldDoc) return newDoc
  const audioMap = {}
  function collect(items, prefix = "") {
    (items || []).forEach(item => {
      const key = prefix + audioKeyPart(item)
      if (item.audio) audioMap[key] = item.audio
      if (item.paragrafos) collect(item.paragrafos, key + " ")
      if (item.incisos) collect(item.incisos, key + " ")
      if (item.alineas) collect(item.alineas, key + " ")
      if (item.divisoes) collect(item.divisoes, prefix)
      if (item.artigos) collect(item.artigos, prefix)
    })
  }
  collect(oldDoc.divisoes || [])
  collect(oldDoc.artigos || [])

  function attach(items, prefix = "") {
    (items || []).forEach(item => {
      const key = prefix + audioKeyPart(item)
      if (audioMap[key]) item.audio = audioMap[key]
      if (item.paragrafos) attach(item.paragrafos, key + " ")
      if (item.incisos) attach(item.incisos, key + " ")
      if (item.alineas) attach(item.alineas, key + " ")
      if (item.divisoes) attach(item.divisoes, prefix)
      if (item.artigos) attach(item.artigos, prefix)
    })
  }
  attach(newDoc.divisoes || [])
  attach(newDoc.artigos || [])
  return newDoc
}

module.exports = { parseLeiDedicado, mergeAudiosFromOld }

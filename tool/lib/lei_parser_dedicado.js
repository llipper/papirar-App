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

/**
 * High-fidelity dedicated parser.
 * Produces output that matches the structure of Codigo_de_Processo_Penal_Militar.json
 */
function parseLeiDedicado({ txtPath, htmlPath = null, metadata = {} }) {
  const raw = fs.readFileSync(txtPath, "utf8")
  const html = htmlPath ? fs.readFileSync(htmlPath, "latin1") : ""
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

  const normalized = normalizeOutput(doc)
  return normalized
}

function mergeAudiosFromOld(newDoc, oldDoc) {
  if (!oldDoc) return newDoc
  const audioMap = {}
  function collect(items, prefix = "") {
    (items || []).forEach(item => {
      const key = prefix + (item.rotulo || item.letra || "")
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
      const key = prefix + (item.rotulo || item.letra || "")
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

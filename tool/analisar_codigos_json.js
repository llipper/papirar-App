const fs = require("fs")
const path = require("path")

const baseDir = path.join(process.cwd(), "assets", "json", "codigos")

function decodeHtml(value) {
  return value
    .replace(/&nbsp;/gi, " ")
    .replace(/&ordm;/gi, "º")
    .replace(/&sect;/gi, "§")
    .replace(/&ccedil;/gi, "ç")
    .replace(/&atilde;/gi, "ã")
    .replace(/&otilde;/gi, "õ")
    .replace(/&aacute;/gi, "á")
    .replace(/&eacute;/gi, "é")
    .replace(/&iacute;/gi, "í")
    .replace(/&oacute;/gi, "ó")
    .replace(/&uacute;/gi, "ú")
    .replace(/&agrave;/gi, "à")
    .replace(/&Aacute;/gi, "Á")
    .replace(/&Eacute;/gi, "É")
    .replace(/&Iacute;/gi, "Í")
    .replace(/&Oacute;/gi, "Ó")
    .replace(/&Uacute;/gi, "Ú")
    .replace(/&quot;/gi, '"')
    .replace(/&amp;/gi, "&")
}

function clean(value) {
  return decodeHtml(String(value || ""))
    .replace(/^\uFEFF/, "")
    .replace(/\u00a0/g, " ")
    .replace(/<script[\s\S]*?<\/script>/gi, " ")
    .replace(/<style[\s\S]*?<\/style>/gi, " ")
    .replace(/<[^>]*>/g, " ")
    .replace(/[ \t]+/g, " ")
    .trim()
}

function readTextLines(file) {
  return fs
    .readFileSync(file, "utf8")
    .split(/\r?\n/)
    .map((raw, index) => ({ raw, text: clean(raw), line: index + 1 }))
    .filter((entry) => entry.text && !/^\.+$/.test(entry.text))
}

function readHtmlLines(file) {
  const html = fs.readFileSync(file).toString("latin1")
  return html
    .replace(/<br\s*\/?\s*>/gi, "\n")
    .replace(/<\/p>/gi, "\n")
    .replace(/<\/div>/gi, "\n")
    .split(/\r?\n/)
    .map((raw, index) => ({ raw, text: clean(raw), line: index + 1 }))
    .filter((entry) => entry.text && !/^\.+$/.test(entry.text))
}

function artigoOf(text) {
  const match = text.match(
    /^Art\.?\s*(\d+)\s*(?:[º°o])?\s*(?:-([A-Z]))?\.?\s*(.*)$/i,
  )
  if (!match) return null
  const numero = `${match[1]}º${match[2] ? `-${match[2].toUpperCase()}` : ""}`
  return `Art. ${numero}.`
}

function artigoKey(rotulo) {
  const match = String(rotulo || "").match(
    /^Art\.?\s*(\d+)(?:[º°o])?(?:-([A-Z]))?/i,
  )
  return match ? `${match[1]}${match[2] ? `-${match[2]}` : ""}` : String(rotulo || "")
}

function paragrafoKey(rotulo) {
  if (/^Parágrafo\s+único/i.test(String(rotulo || ""))) return "unico"
  const match = String(rotulo || "").match(/^§\s*(\d+(?:-[A-Z])?)/i)
  return match ? match[1] : String(rotulo || "")
}

function paragrafoOf(text) {
  if (/^Parágrafo\s+único\.?/i.test(text)) return "Parágrafo único"
  const match = text.match(/^§\s*(\d+(?:-[A-Z])?[º°o]?)\.?/i)
  if (!match) return null
  return `§ ${match[1].replace(/[°o]$/i, "º")}`
}

function incisoOf(text) {
  const match = text.match(/^([IVXLCDM]+)\s*[-–—]\s+/)
  return match ? match[1] : null
}

function alineaOf(text) {
  const match = text.match(/^([a-z])\)\s+/)
  return match ? `${match[1]})` : null
}

function markerOf(text) {
  return artigoOf(text) || paragrafoOf(text) || incisoOf(text) || alineaOf(text)
}

function isDivision(text) {
  return /^(LIVRO|T[ÍI]TULO|CAP[ÍI]TULO|SE[ÇC][ÃA]O|SUBSE[ÇC][ÃA]O)\b/i.test(text)
}

function sourceStats(lines) {
  const stats = {
    artigos: [],
    paragrafos: [],
    incisos: [],
    alineas: [],
    rubricaCandidates: [],
  }

  for (let index = 0; index < lines.length; index += 1) {
    const { text } = lines[index]
    const artigo = artigoOf(text)
    const paragrafo = paragrafoOf(text)
    const inciso = incisoOf(text)
    const alinea = alineaOf(text)
    const marker = artigo || paragrafo || inciso || alinea

    if (artigo) stats.artigos.push(artigo)
    if (paragrafo) stats.paragrafos.push(paragrafo)
    if (inciso) stats.incisos.push(inciso)
    if (alinea) stats.alineas.push(alinea)

    if (!marker || index === 0) continue

    const previous = lines[index - 1]
    if (
      previous.text.length <= 100 &&
      !markerOf(previous.text) &&
      !isDivision(previous.text) &&
      !/[.;:]$/.test(previous.text)
    ) {
      stats.rubricaCandidates.push({
        target: marker,
        rubrica: previous.text,
        line: previous.line,
      })
    }
  }

  return stats
}

function walkJson(node, out) {
  if (!node || typeof node !== "object") return out
  if (Array.isArray(node)) {
    for (const child of node) walkJson(child, out)
    return out
  }

  if (typeof node.rotulo === "string") {
    if (/^Art\./.test(node.rotulo)) out.artigos.push(node)
    else if (/^(§|Parágrafo)/.test(node.rotulo)) out.paragrafos.push(node)
    else if (/^[IVXLCDM]+$/.test(node.rotulo)) out.incisos.push(node)
    else if (/^[a-z]\)$/.test(node.rotulo)) out.alineas.push(node)
  }

  if (node.rubrica) out.rubricas.push(node)

  const text = node.caput || node.texto || ""
  if (
    typeof text === "string" &&
    /^([A-ZÁÉÍÓÚÂÊÔÃÕÇ][\wÁÉÍÓÚÂÊÔÃÕÇáéíóúâêôãõç, ]{2,80})\s+(Art\.|§|Parágrafo|[IVXLCDM]+\s*[-–—]|[a-z]\))/.test(
      text,
    )
  ) {
    out.possivelRubricaNoTexto.push({
      rotulo: node.rotulo || null,
      inicio: text.slice(0, 180),
    })
  }

  for (const child of Object.values(node)) {
    if (child && typeof child === "object") walkJson(child, out)
  }
  return out
}

function unique(values) {
  return [...new Set(values)]
}

function fileByExtension(dir, regex) {
  return fs.readdirSync(dir).find((file) => regex.test(file))
}

function analyzeDir(dir) {
  const jsonFile = fileByExtension(dir, /^(?!.*\.bak$).*\.json$/i)
  const htmlFile = fileByExtension(dir, /\.(html?|htm)$/i)
  const txtFile = fileByExtension(dir, /\.txt$/i)
  const name = path.basename(dir)

  let json = null
  let jsonError = null
  try {
    json = JSON.parse(fs.readFileSync(path.join(dir, jsonFile), "utf8"))
  } catch (error) {
    jsonError = error.message
  }

  const sourceLines = txtFile
    ? readTextLines(path.join(dir, txtFile))
    : htmlFile
      ? readHtmlLines(path.join(dir, htmlFile))
      : []
  const source = sourceStats(sourceLines)
  const jsonStats = json
    ? walkJson(json, {
        artigos: [],
        paragrafos: [],
        incisos: [],
        alineas: [],
        rubricas: [],
        possivelRubricaNoTexto: [],
      })
    : {
        artigos: [],
        paragrafos: [],
        incisos: [],
        alineas: [],
        rubricas: [],
        possivelRubricaNoTexto: [],
      }

  const sourceArticles = unique(source.artigos.map(artigoKey))
  const jsonArticles = unique(jsonStats.artigos.map((artigo) => artigoKey(artigo.rotulo)))
  const missingArticles = sourceArticles.filter(
    (artigo) => !jsonArticles.includes(artigo),
  )
  const extraArticles = jsonArticles.filter(
    (artigo) => !sourceArticles.includes(artigo),
  )

  const jsonObjects = [
    ...jsonStats.artigos,
    ...jsonStats.paragrafos,
    ...jsonStats.incisos,
    ...jsonStats.alineas,
  ]
  const rubricasMisturadas = []
  for (const candidate of source.rubricaCandidates) {
    const target = jsonObjects.find((entry) => {
      if (!entry.rotulo) return false
      if (/^Art\./.test(candidate.target)) {
        return artigoKey(entry.rotulo) === artigoKey(candidate.target)
      }
      if (/^(§|Parágrafo)/.test(candidate.target)) {
        return paragrafoKey(entry.rotulo) === paragrafoKey(candidate.target)
      }
      return entry.rotulo === candidate.target
    })
    if (!target) continue
    const text = target.caput || target.texto || ""
    if (!target.rubrica && text.startsWith(candidate.rubrica)) {
      rubricasMisturadas.push({
        rotulo: candidate.target,
        rubrica: candidate.rubrica,
        linhaFonte: candidate.line,
        inicioTextoJson: text.slice(0, 180),
      })
    }
  }

  return {
    codigo: name,
    arquivos: {
      json: jsonFile || null,
      html: htmlFile || null,
      txt: txtFile || null,
    },
    jsonValido: !jsonError,
    jsonError,
    fonte: {
      linhas: sourceLines.length,
      artigos: source.artigos.length,
      paragrafos: source.paragrafos.length,
      incisos: source.incisos.length,
      alineas: source.alineas.length,
      candidatasRubrica: source.rubricaCandidates.length,
    },
    json: {
      artigos: jsonStats.artigos.length,
      paragrafos: jsonStats.paragrafos.length,
      incisos: jsonStats.incisos.length,
      alineas: jsonStats.alineas.length,
      rubricas: jsonStats.rubricas.length,
    },
    problemas: {
      artigosFaltando: missingArticles.slice(0, 50),
      artigosExtras: extraArticles.slice(0, 50),
      rubricasMisturadas: rubricasMisturadas.slice(0, 50),
      possivelRubricaNoTexto: jsonStats.possivelRubricaNoTexto.slice(0, 20),
    },
  }
}

function main() {
  const reports = fs
    .readdirSync(baseDir, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => analyzeDir(path.join(baseDir, entry.name)))

  const outputPath = path.join(baseDir, "_relatorio_analise_codigos.json")
  fs.writeFileSync(outputPath, `${JSON.stringify(reports, null, 2)}\n`, "utf8")
  console.log(JSON.stringify(reports, null, 2))
}

main()

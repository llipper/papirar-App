const fs = require("fs")
const path = require("path")
const { execFileSync } = require("child_process")
const { parseLeiDedicado, mergeAudiosFromOld } = require("./lib/lei_parser_dedicado")

const root = process.cwd()
const baseDir = path.join(root, "assets", "json", "codigos")
const reportPath = path.join(baseDir, "_relatorio_correcao_codigos.json")

const metadata = {
  codigo_civil: {
    id: "Codigo_Civil",
    titulo: "LEI Nº 10.406, DE 10 DE JANEIRO DE 2002.",
    apelido: "Código Civil.",
    sigla: "CC",
    fonteOficial: "https://www.planalto.gov.br/ccivil_03/leis/l10406compilada.htm",
    ementa: "Institui o Código Civil.",
  },
  codigo_de_processo_civil: {
    id: "Codigo_de_Processo_Civil",
    titulo: "LEI Nº 13.105, DE 16 DE MARÇO DE 2015.",
    apelido: "Código de Processo Civil.",
    sigla: "CPC",
    fonteOficial: "https://www.planalto.gov.br/ccivil_03/leis/l13105.htm",
    ementa: "Código de Processo Civil.",
  },
  codigo_de_processo_penal: {
    id: "Codigo_de_Processo_Penal",
    titulo: "DECRETO-LEI Nº 3.689, DE 3 DE OUTUBRO DE 1941.",
    apelido: "Código de Processo Penal.",
    sigla: "CPP",
    fonteOficial: "https://www.planalto.gov.br/ccivil_03/decreto-lei/del3689.htm",
    ementa: "Código de Processo Penal.",
  },
  codigo_de_processo_penal_militar: {
    id: "Codigo_de_Processo_Penal_Militar",
    titulo: "DECRETO-LEI Nº 1.002, DE 21 DE OUTUBRO DE 1969.",
    apelido: "Código de Processo Penal Militar.",
    sigla: "CPPM",
    fonteOficial: "https://www.planalto.gov.br/ccivil_03/decreto-lei/del1002.htm",
    ementa: "Código de Processo Penal Militar.",
  },
  codigo_de_transito_brasileiro: {
    id: "Codigo_de_Transito_Brasileiro",
    titulo: "LEI Nº 9.503, DE 23 DE SETEMBRO DE 1997.",
    apelido: "Código de Trânsito Brasileiro.",
    sigla: "CTB",
    fonteOficial: "https://www.planalto.gov.br/ccivil_03/leis/l9503compilado.htm",
    ementa: "Institui o Código de Trânsito Brasileiro.",
  },
  codigo_penal: {
    id: "Codigo_Penal",
    titulo: "DECRETO-LEI Nº 2.848, DE 7 DE DEZEMBRO DE 1940.",
    apelido: "Código Penal.",
    sigla: "CP",
    fonteOficial: "https://www.planalto.gov.br/ccivil_03/decreto-lei/del2848compilado.htm",
    ementa: "Código Penal.",
  },
  codigo_penal_militar: {
    id: "Codigo_Penal_Militar",
    titulo: "DECRETO-LEI Nº 1.001, DE 21 DE OUTUBRO DE 1969.",
    apelido: "Código Penal Militar.",
    sigla: "CPM",
    fonteOficial: "https://www.planalto.gov.br/ccivil_03/decreto-lei/del1001.htm",
    ementa: "Código Penal Militar.",
  },
}

function articleOf(line) {
  return /^Art\.?\s*\d+\s*(?:[º°o])?\s*(?:-[A-Z])?\.?/i.test(line)
}

function countSourceArticles(txtPath) {
  return fs
    .readFileSync(txtPath, "utf8")
    .split(/\r?\n/)
    .map((line) =>
      line
        .replace(/^\uFEFF/, "")
        .replace(/\u00a0/g, " ")
        .replace(/[ \t]+/g, " ")
        .trim(),
    )
    .filter(articleOf).length
}

function collectArticles(divisions, target = []) {
  for (const division of divisions || []) {
    if (Array.isArray(division.artigos)) target.push(...division.artigos)
    if (Array.isArray(division.divisoes)) collectArticles(division.divisoes, target)
  }
  return target
}

function countRubricas(articles) {
  const totals = { artigos: 0, paragrafos: 0, incisos: 0, alineas: 0 }
  for (const artigo of articles) {
    if (artigo.rubrica) totals.artigos += 1
    for (const paragrafo of artigo.paragrafos || []) {
      if (paragrafo.rubrica) totals.paragrafos += 1
      for (const inciso of paragrafo.incisos || []) {
        if (inciso.rubrica) totals.incisos += 1
        for (const alinea of inciso.alineas || []) {
          if (alinea.rubrica) totals.alineas += 1
        }
      }
      for (const alinea of paragrafo.alineas || []) {
        if (alinea.rubrica) totals.alineas += 1
      }
    }
    for (const inciso of artigo.incisos || []) {
      if (inciso.rubrica) totals.incisos += 1
      for (const alinea of inciso.alineas || []) {
        if (alinea.rubrica) totals.alineas += 1
      }
    }
    for (const alinea of artigo.alineas || []) {
      if (alinea.rubrica) totals.alineas += 1
    }
  }
  return totals
}

function findFile(dir, regex) {
  return fs.readdirSync(dir).find((file) => regex.test(file))
}

function readJsonFromHead(relativePath) {
  try {
    const raw = execFileSync("git", ["show", `HEAD:${relativePath.replace(/\\/g, "/")}`], {
      cwd: root,
      encoding: "utf8",
      maxBuffer: 50 * 1024 * 1024,
      stdio: ["ignore", "pipe", "ignore"],
    })
    return JSON.parse(raw.replace(/^\uFEFF/, ""))
  } catch (_) {
    return null
  }
}

function main() {
  const reports = []
  for (const entry of fs.readdirSync(baseDir, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue

    const dir = path.join(baseDir, entry.name)
    const txtFile = findFile(dir, /\.txt$/i)
    const htmlFile = findFile(dir, /\.(html?|htm)$/i)
    const jsonFile = findFile(dir, /^(?!.*\.bak$).*\.json$/i)
    if (!txtFile || !jsonFile) continue

    const txtPath = path.join(dir, txtFile)
    const htmlPath = htmlFile ? path.join(dir, htmlFile) : null
    const outPath = path.join(dir, jsonFile)
    const relativeJsonPath = path.relative(root, outPath)
    const oldDoc = JSON.parse(fs.readFileSync(outPath, "utf8").replace(/^\uFEFF/, ""))
    const headDoc = readJsonFromHead(relativeJsonPath)
    const meta = metadata[entry.name] || {}
    const doc = parseLeiDedicado({
      txtPath,
      htmlPath,
      metadata: {
        ...meta,
        fonteHtmlLocal: htmlFile || null,
      },
    })
    const finalDoc = mergeAudiosFromOld(mergeAudiosFromOld(doc, oldDoc), headDoc)
    fs.writeFileSync(outPath, `${JSON.stringify(finalDoc, null, 4)}\n`, "utf8")

    const articles = collectArticles(finalDoc.divisoes)
    reports.push({
      codigo: entry.name,
      json: path.relative(root, outPath),
      txt: path.relative(root, txtPath),
      html: htmlPath ? path.relative(root, htmlPath) : null,
      artigosFonte: countSourceArticles(txtPath),
      artigosJson: articles.length,
      primeiroArtigo: articles[0]?.rotulo || null,
      ultimoArtigo: articles[articles.length - 1]?.rotulo || null,
      rubricas: countRubricas(articles),
      ok: countSourceArticles(txtPath) === articles.length,
    })
  }

  fs.writeFileSync(reportPath, `${JSON.stringify(reports, null, 4)}\n`, "utf8")
  console.log(JSON.stringify(reports, null, 2))
}

main()

const fs = require("fs")
const path = require("path")
const { parseLeiDedicado, mergeAudiosFromOld } = require("./lib/lei_parser_dedicado")

const root = process.cwd()
const dir = path.join(root, "assets", "json", "codigos", "codigo_penal")
const txtPath = path.join(dir, "codigo_penal.txt")
const htmlPath = path.join(dir, "del2848.htm")
const outPath = path.join(dir, "codigo_penal.json")
const reportPath = path.join(dir, "_relatorio_codigo_penal.json")

function collectArticles(divisions, target = []) {
  for (const division of divisions || []) {
    if (Array.isArray(division.artigos)) target.push(...division.artigos)
    if (Array.isArray(division.divisoes)) collectArticles(division.divisoes, target)
  }
  return target
}

function countSourceArticles() {
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
    .filter((line) => /^Art\.?\s*\d+\s*(?:[º°o])?\s*(?:-[A-Z])?\.?/i.test(line))
    .length
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

const oldDoc = JSON.parse(fs.readFileSync(outPath, "utf8").replace(/^\uFEFF/, ""))
const doc = parseLeiDedicado({
  txtPath,
  htmlPath,
  metadata: {
    id: "Codigo_Penal",
    titulo: "DECRETO-LEI Nº 2.848, DE 7 DE DEZEMBRO DE 1940.",
    apelido: "Código Penal.",
    sigla: "CP",
    fonteHtmlLocal: "del2848.htm",
    fonteOficial: "https://www.planalto.gov.br/ccivil_03/decreto-lei/del2848compilado.htm",
    ementa: "Código Penal.",
  },
})

const finalDoc = mergeAudiosFromOld(doc, oldDoc)
fs.writeFileSync(outPath, `${JSON.stringify(finalDoc, null, 4)}\n`, "utf8")

const articles = collectArticles(finalDoc.divisoes)
const report = {
  json: path.relative(root, outPath),
  txt: path.relative(root, txtPath),
  html: path.relative(root, htmlPath),
  artigosFonte: countSourceArticles(),
  artigosJson: articles.length,
  primeiroArtigo: articles[0]?.rotulo || null,
  ultimoArtigo: articles[articles.length - 1]?.rotulo || null,
  rubricas: countRubricas(articles),
  ok: countSourceArticles() === articles.length,
}

fs.writeFileSync(reportPath, `${JSON.stringify(report, null, 4)}\n`, "utf8")
console.log(JSON.stringify(report, null, 2))

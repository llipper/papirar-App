const fs = require("fs")
const path = require("path")
const { parseLeiDedicado, mergeAudiosFromOld } = require("../lib/lei_parser_dedicado")

const root = process.cwd()
const txtPath = path.join(root, "lib/features/lei_seca/json/txt/codigos/Codigo_Penal/Codigo_Penal.txt")
const htmlPath = path.join(root, "lib/features/lei_seca/json/txt/codigos/Codigo_Penal/del2848.htm")
const targetDir = path.join(root, "assets", "json", "codigos", "codigo_penal")
const outPath = path.join(targetDir, "codigo_penal.json")

const doc = parseLeiDedicado({
  txtPath,
  htmlPath,
  metadata: {
    id: "Codigo_Penal",
    titulo: "DECRETO-LEI No 2.848, DE 7 DE DEZEMBRO DE 1940.",
    apelido: "Código Penal.",
    sigla: "CP",
    fonteOficial: "https://www.planalto.gov.br/ccivil_03/decreto-lei/del2848.htm",
    ementa: "Código Penal.",
    fonteHtmlLocal: "txt/codigos/Codigo_Penal/del2848.htm",
  },
})

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
console.log("Generated dedicated: Codigo_Penal.json")
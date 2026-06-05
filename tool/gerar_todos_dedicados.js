/**
 * Master DEDICATED generator for all laws.
 * Uses the high-fidelity parser (same as CPPM reference) for every law.
 * This ensures all JSONs strictly follow the standard structure.
 *
 * Run: node tool/gerar_todos_dedicados.js
 */

const fs = require("fs")
const path = require("path")
const { parseLeiDedicado, mergeAudiosFromOld } = require("./lib/lei_parser_dedicado")

const root = process.cwd()
const txtDir = path.join(root, "lib/features/lei_seca/json/txt")
const jsonAssetsDir = path.join(root, "assets", "json")
// Reports and generation logs stay outside assets
const reportsDir = path.join(root, "lib", "features", "lei_seca", "json")

// Normalize folder names to ASCII to avoid Flutter asset bundling issues on Windows
// (accents in folder names like "Constituição", "Trânsito" can cause "asset does not exist")
function toAsciiFolder(name) {
  return String(name)
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '') // strip diacritics
    .replace(/[^A-Za-z0-9_.-]/g, '_')
    .toLowerCase()
}

function discoverLaws() {
  const laws = []
  function walk(dir, category = "") {
    const items = fs.readdirSync(dir, { withFileTypes: true })
    for (const item of items) {
      const full = path.join(dir, item.name)
      if (item.isDirectory()) {
        const subItems = fs.readdirSync(full)
        const hasTxt = subItems.some(f => f.endsWith(".txt"))
        if (hasTxt) {
          const lawName = item.name
          const txtFile = subItems.find(f => f.endsWith(".txt"))
          const htmFile = subItems.find(f => f.endsWith(".htm") || f.endsWith(".html"))
          laws.push({
            id: lawName,
            txt: path.relative(txtDir, path.join(full, txtFile)).replace(/\\/g, "/"),
            htm: htmFile ? path.relative(txtDir, path.join(full, htmFile)).replace(/\\/g, "/") : null,
            category
          })
        } else {
          walk(full, item.name)
        }
      }
    }
  }
  walk(txtDir)
  return laws
}

const laws = discoverLaws()

// Basic metadata map for better titles etc. (expand as needed)
const metadataMap = {
  "Codigo_Civil": { titulo: "Código Civil", sigla: "CC", fonteOficial: "https://www.planalto.gov.br/ccivil_03/leis/l10406compilada.htm", ementa: "Institui o Código Civil." },
  "Codigo_Penal": { titulo: "Código Penal", sigla: "CP", fonteOficial: "https://www.planalto.gov.br/ccivil_03/decreto-lei/del2848.htm", ementa: "Código Penal." },
  // ... add more if you have specific data
}

laws.forEach(law => {
  const txtPath = path.join(txtDir, law.txt)
  const htmlPath = law.htm ? path.join(txtDir, law.htm) : null
  const safeId = toAsciiFolder(law.id)
  const targetDir = path.join(jsonAssetsDir, law.category || "", safeId)
  fs.mkdirSync(targetDir, { recursive: true })
  const outPath = path.join(targetDir, `${safeId}.json`)

  if (!fs.existsSync(txtPath)) {
    console.log("Skipping (no txt):", law.id)
    return
  }

  const meta = metadataMap[law.id] || {}
  const doc = parseLeiDedicado({
    txtPath,
    htmlPath,
    metadata: {
      id: law.id,
      titulo: meta.titulo || law.id.replace(/_/g, " "),
      apelido: meta.apelido || (meta.titulo || law.id.replace(/_/g, " ")) + ".",
      sigla: meta.sigla || "",
      fonteOficial: meta.fonteOficial || null,
      ementa: meta.ementa || null,
      fonteHtmlLocal: law.htm || null,
    },
  })

  let finalDoc = doc
  if (fs.existsSync(outPath)) {
    try {
      const oldRaw = fs.readFileSync(outPath, "utf8").replace(/^\uFEFF/, "")
      const old = JSON.parse(oldRaw)
      finalDoc = mergeAudiosFromOld(doc, old)
    } catch (e) {}
  }

  fs.writeFileSync(outPath, `${JSON.stringify(finalDoc, null, 4)}\n`, "utf8")
  console.log("Generated dedicated:", law.id + ".json")
})

console.log(`\nAll dedicated generations complete. Total laws processed: ${laws.length}`)
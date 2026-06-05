/**
 * Validation for all dedicated-generated JSONs.
 * Ensures they strictly follow the structure of Codigo_de_Processo_Penal_Militar.json
 */

const fs = require("fs")
const path = require("path")

const jsonDir = "assets/json"
const refPath = path.join(jsonDir, "codigos", "Codigo_de_Processo_Penal_Militar", "Codigo_de_Processo_Penal_Militar.json")
const ref = JSON.parse(fs.readFileSync(refPath, "utf8"))
const refCoreKeys = ["id", "titulo", "apelido", "sigla", "fonte", "preambulo", "divisoes"]

// Recursively collect all .json under assets/json (skip relatorios if any sneak in)
function collectJsonFiles(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true })
  const files = []
  for (const entry of entries) {
    const full = path.join(dir, entry.name)
    if (entry.isDirectory()) {
      files.push(...collectJsonFiles(full))
    } else if (entry.isFile() && entry.name.endsWith(".json") && !entry.name.startsWith("relatorio_")) {
      files.push(full)
    }
  }
  return files
}

const files = collectJsonFiles(jsonDir).sort()

console.log("=== Validação de JSONs (Padrão: Codigo_de_Processo_Penal_Militar.json) ===\n")

let errors = 0
const knownWithAudio = ["Codigo_Penal", "Constituição_Federal_de_1988"] // from history/tests

files.forEach(fullPath => {
  const fileLabel = path.relative(jsonDir, fullPath) // e.g. codigos/Codigo_Penal/Codigo_Penal.json for nice log
  let j
  try {
    j = JSON.parse(fs.readFileSync(fullPath, "utf8"))
  } catch (e) {
    console.log(`[ERRO] ${fileLabel}: JSON inválido - ${e.message}`)
    errors++
    return
  }

  const problems = []

  // Core keys
  refCoreKeys.forEach(k => {
    if (!j.hasOwnProperty(k)) problems.push(`falta campo core "${k}"`)
  })

  // No geradoEm
  if (j.hasOwnProperty("geradoEm")) problems.push("tem 'geradoEm' (remover)")

  // Fonte limpo (basename)
  if (j.fonte && (j.fonte.includes("/") || j.fonte.includes("\\"))) {
    problems.push(`"fonte" sujo com caminho: ${j.fonte}`)
  }

  // Estrutura básica
  if (j.divisoes && Array.isArray(j.divisoes)) {
    if (j.divisoes.length === 0) problems.push("divisoes vazio")
  } else {
    problems.push("divisoes não é array")
  }

  // Audio check for known
  if (knownWithAudio.includes(j.id)) {
    let hasAudio = false
    function walk(o) {
      if (!o) return
      if (Array.isArray(o)) { o.forEach(walk); return }
      if (typeof o === "object") {
        if (o.audio) hasAudio = true
        Object.values(o).forEach(walk)
      }
    }
    walk(j)
    if (!hasAudio) problems.push("esperado audio mas não encontrado")
  }

  if (problems.length > 0) {
    console.log(`[PROBLEMAS] ${fileLabel}:`)
    problems.forEach(p => console.log("  - " + p))
    errors++
  } else {
    console.log(`[OK] ${fileLabel}`)
  }
})

console.log(`\nTotal verificados: ${files.length}`)
console.log(`Com problemas: ${errors}`)
if (errors === 0) {
  console.log("Todos os JSONs estão no padrão do reference!")
} else {
  console.log("Corrija os problemas acima.")
}

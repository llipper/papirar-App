const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..', 'assets', 'json');

function cleanAnnotation(str) {
  if (typeof str !== 'string') return str;
  let s = str;

  // Remove common out-of-pattern annotations (amendment notes, vide, vigencia etc.)
  // ONLY from rubrica/titulo/apelido. Do NOT touch "texto", "caput" etc. ("nao pode remover do texto")
  const notePatterns = [
    /\s*\(Inclu[íi]do pela Lei nº .*?\)/gi,
    /\s*\(Redação dada pela Lei nº .*?\)/gi,
    /\s*\(Redação dada pela Lei Complementar nº .*?\)/gi,
    /\s*\(Vide Lei nº .*?\)/gi,
    /\s*\(Vide ADI .*?\)/gi,
    /\s*\(Vide Decreto .*?\)/gi,
    /\s*\(Vide Medida Provisória .*?\)/gi,
    /\s*\(Vide Resolução .*?\)/gi,
    /\s*\(Vide .*?\)/gi,
    /\s*\(Vigência\)/gi,
    /\s*Vigência encerrada\s*/gi,
    /\s*Vigência\s*/gi,
    /\s*\(revogado\);?/gi,
    /\s*\(revogada\);?/gi,
    /\s*\(VETADO\)\s*/gi,
    /\s*\(Incluído pela Lei nº .*?\)/gi,
    /\s*\(Incluido pela Lei nº .*?\)/gi,
    /\s*\(Incluído dada pela Lei nº .*?\)/gi,
    /\s*\(Expressão substituída pela Lei nº .*?\)\s*Vigência/gi,
  ];

  for (const re of notePatterns) {
    s = s.replace(re, '');
  }

  // Clean up trailing punctuation/spaces left behind, e.g. "; " or " ."
  s = s.replace(/\s*;\s*$/, '').replace(/\s*\.\s*$/, '.').trim();
  s = s.replace(/\s{2,}/g, ' ');

  // If after stripping the rubrica becomes empty (e.g. pure note like "(Revogado...)"), leave as empty so UI can decide (or set "Revogado" if wanted)
  if (s === '' || s === ';' || s === '.') {
    s = '';
  }

  return s;
}

function shouldCleanKey(key) {
  // Only clean meta fields like rubrica, titulo, apelido. 
  // NEVER touch "texto", "caput", "paragrafos.*.texto" etc. as per "nao pode remover do texto"
  const cleanKeys = ['rubrica', 'titulo', 'apelido'];
  return cleanKeys.includes(key);
}

function cleanObject(obj) {
  if (Array.isArray(obj)) {
    return obj.map(cleanObject);
  }
  if (obj && typeof obj === 'object') {
    const newObj = {};
    for (const [key, value] of Object.entries(obj)) {
      if (shouldCleanKey(key) && typeof value === 'string') {
        newObj[key] = cleanAnnotation(value);
      } else {
        newObj[key] = cleanObject(value);
      }
    }
    return newObj;
  }
  return obj;
}

function processDir(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      processDir(full);
    } else if (entry.isFile() && entry.name.endsWith('.json')) {
      console.log('Processing:', full);
      const data = JSON.parse(fs.readFileSync(full, 'utf8'));
      const cleaned = cleanObject(data);
      fs.writeFileSync(full, JSON.stringify(cleaned, null, 2) + '\n', 'utf8');
    }
  }
}

console.log('Cleaning annotation notes from rubrica/titulo/apelido in JSONs (leaving texto/caput untouched)...');
processDir(root);
console.log('Done. All JSONs updated in place.');

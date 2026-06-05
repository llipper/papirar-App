const fs = require('fs');
const path = require('path');

const root = 'C:\\Users\\dev\\Documents\\documentos\\papirar\\assets\\json';

function toLowerAscii(name) {
  return String(name)
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^A-Za-z0-9_.-]/g, '_')
    .toLowerCase();
}

function processDir(baseDir) {
  if (!fs.existsSync(baseDir)) return;
  const items = fs.readdirSync(baseDir, { withFileTypes: true });
  for (const item of items) {
    if (item.isDirectory()) {
      const oldPath = path.join(baseDir, item.name);
      const newName = toLowerAscii(item.name);
      const newPath = path.join(baseDir, newName);
      if (item.name !== newName) {
        console.log('Renaming dir:', item.name, '->', newName);
        fs.renameSync(oldPath, newPath);
      }
      // Process inside
      processDir(newPath);
      // Rename any .json inside that matches old casing
      const jsonFiles = fs.readdirSync(newPath).filter(f => f.endsWith('.json'));
      for (const jf of jsonFiles) {
        const oldJson = path.join(newPath, jf);
        const base = path.basename(jf, '.json');
        const newBase = toLowerAscii(base);
        const newJson = path.join(newPath, newBase + '.json');
        if (jf !== newBase + '.json') {
          console.log('  Renaming json:', jf, '->', newBase + '.json');
          fs.renameSync(oldJson, newJson);
        }
      }
    }
  }
}

console.log('Starting normalization of assets/json to lowercase ASCII...');
processDir(root);
console.log('Normalization complete.');
console.log('You can now delete this temp script.');

// Scan only the explicit release manifest. Never print matched sensitive values.
const fs = require("node:fs");
const path = require("node:path");
const assert = require("node:assert/strict");
const { Script } = require("node:vm");
const manifest = require("./release-files.json");
const files = [...manifest.runtime, ...manifest.development];
assert.equal(new Set(files).size, files.length, "Duplicate release entry");
const patterns = [
  ["private key", /-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/],
  ["credential", /\b(?:gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{30,}|AKIA[A-Z0-9]{16})\b/],
  ["bearer credential", /Bearer\s+[A-Za-z0-9._-]{20,}/i],
  ["personal home path", /(?:[A-Z]:[\\/](?:Users|Documents and Settings)[\\/]|\/(?:Users|home)\/)[^\s'"<>]+/i],
  ["email address", /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i],
  ["private deployment link", /https?:\/\/[^\s"<>]*(?:claim[-_/]|[?&](?:token|password|secret|key)=)/i],
  ["embedded secret", /\b(?:api[_-]?key|access[_-]?token|client[_-]?secret|password)\s*[:=]\s*["'][^"'\r\n]{8,}["']/i]
];
let failures = 0;
for (const file of files) {
  assert(!file.includes("/") && !file.includes("\\") && file !== "..", "Release files must be in the project root");
  const filePath = path.join(__dirname, file);
  assert(fs.lstatSync(filePath).isFile() && !fs.lstatSync(filePath).isSymbolicLink(), `Not a regular file: ${file}`);
  const text = fs.readFileSync(filePath, "utf8");
  for (const [label, pattern] of patterns) {
    if (pattern.test(text)) { console.error(`${file}: possible ${label}`); failures++; }
  }
  if (file.endsWith(".js")) {
    try { new Script(text, { filename: file }); }
    catch { console.error(`${file}: JavaScript syntax check failed`); failures++; }
  }
}
const html = fs.readFileSync(path.join(__dirname, "index.html"), "utf8");
for (const match of html.matchAll(/(?:src|href)="([^"]+)"/g)) {
  assert(manifest.runtime.includes(match[1].replace(/^\.\//, "")), `Unexpected or missing page dependency: ${match[1]}`);
}
if (failures) process.exitCode = 1;
else console.log(`Release check passed: ${files.length} allowlisted files, syntax and common sensitive-data patterns.`);

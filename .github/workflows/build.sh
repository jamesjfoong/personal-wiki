#!/bin/bash
set -e
USER_HASH=$(echo -n "$WIKI_USER" | sha256sum | cut -d' ' -f1)
PASS_HASH=$(echo -n "$WIKI_PASS" | sha256sum | cut -d' ' -f1)

# Build manifest of all markdown files
MANIFEST=$(find . -name "*.md" -not -path "./.git/*" -not -path "./.github/*" | sort | jq -R -s 'split("\n") | map(select(length > 0))')

cat > index.html << 'TEMPLATE'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Personal LLM Wiki</title>
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/dompurify@3.0.5/dist/purify.min.js"></script>
<style>
:root {
  --bg: #0d1117;
  --surface: #161b22;
  --surface-hover: #21262d;
  --border: #30363d;
  --text: #c9d1d9;
  --text-secondary: #8b949e;
  --accent: #58a6ff;
  --accent-hover: #79b8ff;
  --danger: #f85149;
  --success: #3fb950;
  --font-mono: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, monospace;
  --font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
}
* { box-sizing: border-box; margin: 0; padding: 0; }
html, body { height: 100%; }
body {
  font-family: var(--font-sans);
  background: var(--bg);
  color: var(--text);
  line-height: 1.6;
  overflow: hidden;
}

/* Login */
#login-screen {
  display: flex; align-items: center; justify-content: center;
  height: 100vh; width: 100vw;
}
#login-box {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 40px;
  width: 360px;
  max-width: 90vw;
}
#login-box h1 {
  font-size: 22px; margin-bottom: 8px; font-weight: 600;
}
#login-box p {
  color: var(--text-secondary); font-size: 14px; margin-bottom: 24px;
}
#login-box input {
  width: 100%; padding: 10px 12px; margin-bottom: 12px;
  background: var(--bg); border: 1px solid var(--border); border-radius: 6px;
  color: var(--text); font-size: 14px; outline: none;
}
#login-box input:focus { border-color: var(--accent); }
#login-box button {
  width: 100%; padding: 10px; background: var(--accent); border: none;
  border-radius: 6px; color: #fff; font-weight: 600; cursor: pointer; font-size: 14px;
}
#login-box button:hover { background: var(--accent-hover); }
#login-error {
  color: var(--danger); font-size: 13px; margin-top: 10px; display: none;
}

/* Layout */
#app { display: none; height: 100vh; }
#sidebar {
  width: 280px; min-width: 280px;
  background: var(--surface);
  border-right: 1px solid var(--border);
  display: flex; flex-direction: column;
}
#sidebar-header {
  padding: 16px 20px; border-bottom: 1px solid var(--border);
}
#sidebar-header h1 {
  font-size: 16px; font-weight: 600;
}
#sidebar-header p {
  font-size: 12px; color: var(--text-secondary); margin-top: 4px;
}
#sidebar-search {
  padding: 12px 16px; border-bottom: 1px solid var(--border);
}
#sidebar-search input {
  width: 100%; padding: 8px 12px;
  background: var(--bg); border: 1px solid var(--border); border-radius: 6px;
  color: var(--text); font-size: 13px; outline: none;
}
#sidebar-search input:focus { border-color: var(--accent); }
#file-list {
  flex: 1; overflow-y: auto; padding: 8px 0;
}
#file-list a {
  display: block; padding: 7px 20px;
  color: var(--text-secondary); text-decoration: none; font-size: 13px;
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
  cursor: pointer;
}
#file-list a:hover, #file-list a.active {
  background: var(--surface-hover); color: var(--text);
}
#file-list a::before {
  content: "📝 "; font-size: 11px; opacity: 0.5;
}
#main {
  flex: 1; overflow-y: auto; padding: 40px 48px;
  max-width: 900px; margin: 0 auto;
}
#main h1 { font-size: 32px; font-weight: 600; margin-bottom: 16px; padding-bottom: 12px; border-bottom: 1px solid var(--border); }
#main h2 { font-size: 24px; font-weight: 600; margin: 32px 0 12px; padding-bottom: 8px; border-bottom: 1px solid var(--border); }
#main h3 { font-size: 18px; font-weight: 600; margin: 24px 0 8px; }
#main p { margin-bottom: 16px; }
#main a { color: var(--accent); text-decoration: none; }
#main a:hover { text-decoration: underline; }
#main code {
  background: rgba(110,118,129,0.15); padding: 3px 6px; border-radius: 4px;
  font-family: var(--font-mono); font-size: 85%;
}
#main pre {
  background: var(--surface); border: 1px solid var(--border); border-radius: 8px;
  padding: 16px; overflow-x: auto; margin-bottom: 16px;
}
#main pre code { background: none; padding: 0; }
#main ul, #main ol { padding-left: 24px; margin-bottom: 16px; }
#main li { margin: 6px 0; }
#main table {
  width: 100%; border-collapse: collapse; margin-bottom: 16px;
}
#main th, #main td {
  padding: 8px 12px; border: 1px solid var(--border); text-align: left;
}
#main th { background: var(--surface); font-weight: 600; }
#main blockquote {
  border-left: 3px solid var(--accent); padding-left: 16px; margin: 16px 0;
  color: var(--text-secondary);
}
#main img { max-width: 100%; border-radius: 6px; }
.wiki-link { color: var(--accent); cursor: pointer; }
.wiki-link:hover { text-decoration: underline; }
#breadcrumb {
  font-size: 12px; color: var(--text-secondary); margin-bottom: 16px;
}
#breadcrumb a { color: var(--text-secondary); text-decoration: none; }
#breadcrumb a:hover { color: var(--text); }
</style>
</head>
<body>

<!-- Login Screen -->
<div id="login-screen">
  <div id="login-box">
    <h1>🧠 Personal Wiki</h1>
    <p>Karpathy LLM Wiki pattern · Hermes Agent</p>
    <input type="text" id="login-user" placeholder="Username" autocomplete="off">
    <input type="password" id="login-pass" placeholder="Password">
    <button onclick="doLogin()">Enter</button>
    <p id="login-error">Invalid credentials.</p>
  </div>
</div>

<!-- App -->
<div id="app">
  <div id="sidebar">
    <div id="sidebar-header">
      <h1>📚 Wiki</h1>
      <p id="file-count">Loading...</p>
    </div>
    <div id="sidebar-search">
      <input type="text" id="search" placeholder="Search pages..." oninput="filterFiles(this.value)">
    </div>
    <div id="file-list"></div>
  </div>
  <div id="main">
    <div id="breadcrumb"><a onclick="loadPage('wiki/index.md')">Home</a></div>
    <div id="content">Select a page from the sidebar.</div>
  </div>
</div>

<script>
const EXPECTED_USER = '{{USER_HASH}}';
const EXPECTED_PASS = '{{PASS_HASH}}';
const REPO_RAW = 'https://raw.githubusercontent.com/jamesjfoong/personal-wiki/master';
const MANIFEST = {{MANIFEST}};

async function sha256(text) {
  const buf = new TextEncoder().encode(text);
  const hash = await crypto.subtle.digest('SHA-256', buf);
  return Array.from(new Uint8Array(hash)).map(b => b.toString(16).padStart(2, '0')).join('');
}
async function doLogin() {
  const u = document.getElementById('login-user').value;
  const p = document.getElementById('login-pass').value;
  const uh = await sha256(u), ph = await sha256(p);
  if (uh === EXPECTED_USER && ph === EXPECTED_PASS) {
    document.getElementById('login-screen').style.display = 'none';
    document.getElementById('app').style.display = 'flex';
    localStorage.setItem('wiki_auth', EXPECTED_USER + ':' + EXPECTED_PASS);
    initApp();
  } else {
    document.getElementById('login-error').style.display = 'block';
  }
}
(async function() {
  const stored = localStorage.getItem('wiki_auth');
  if (stored && stored === EXPECTED_USER + ':' + EXPECTED_PASS) {
    document.getElementById('login-screen').style.display = 'none';
    document.getElementById('app').style.display = 'flex';
    initApp();
  }
})();

function initApp() {
  renderSidebar(MANIFEST);
  document.getElementById('file-count').textContent = MANIFEST.length + ' pages';
  const hash = location.hash.slice(1);
  if (hash) loadPage(decodeURIComponent(hash));
  else if (MANIFEST.length > 0) loadPage(MANIFEST[0]);
}
function renderSidebar(files) {
  const list = document.getElementById('file-list');
  list.innerHTML = '';
  files.forEach(f => {
    const a = document.createElement('a');
    a.textContent = f.replace(/\.md$/, '').replace(/^(wiki|schema|raw)\//, '');
    a.dataset.file = f;
    a.onclick = () => loadPage(f);
    list.appendChild(a);
  });
}
function filterFiles(q) {
  const lowered = q.toLowerCase();
  renderSidebar(MANIFEST.filter(f => f.toLowerCase().includes(lowered)));
}
async function loadPage(file) {
  try {
    const res = await fetch(REPO_RAW + '/' + file);
    const md = await res.text();
    const linked = md.replace(/\[\[([^\]]+)\]\]/g, (m, name) => {
      return `<span class="wiki-link" onclick="findAndLoad('${name}')">${name}</span>`;
    });
    const html = DOMPurify.sanitize(marked.parse(linked));
    document.getElementById('content').innerHTML = html;
    document.getElementById('breadcrumb').innerHTML = `<a onclick="loadPage('${file}')">${file}</a>`;
    location.hash = encodeURIComponent(file);
    document.querySelectorAll('#file-list a').forEach(a => {
      a.classList.toggle('active', a.dataset.file === file);
    });
  } catch (e) {
    document.getElementById('content').innerHTML = '<p style="color:var(--danger)">Failed to load: ' + file + '</p>';
  }
}
function findAndLoad(name) {
  const exact = MANIFEST.find(f => f.toLowerCase().endsWith(name.toLowerCase() + '.md'));
  if (exact) { loadPage(exact); return; }
  const partial = MANIFEST.find(f => f.toLowerCase().includes(name.toLowerCase()));
  if (partial) loadPage(partial);
}
document.getElementById('login-pass').addEventListener('keypress', e => { if (e.key === 'Enter') doLogin(); });
</script>

</body>
</html>
TEMPLATE

# Use python3 for safe multi-pattern replacement (sed chokes on JSON slashes)
python3 - "$USER_HASH" "$PASS_HASH" "$MANIFEST" << 'PYEOF'
import sys

with open('index.html', 'r') as f:
    text = f.read()

text = text.replace('{{USER_HASH}}', sys.argv[1])
text = text.replace('{{PASS_HASH}}', sys.argv[2])
text = text.replace('{{MANIFEST}}', sys.argv[3])

with open('index.html', 'w') as f:
    f.write(text)
PYEOF

#!/bin/bash
set -e
USER_HASH=$(echo -n "$WIKI_USER" | sha256sum | cut -d' ' -f1)
PASS_HASH=$(echo -n "$WIKI_PASS" | sha256sum | cut -d' ' -f1)

cat > index.html << 'TEMPLATE'
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Personal LLM Wiki</title>
<style>
body { font-family: system-ui, sans-serif; max-width: 800px; margin: 40px auto; padding: 0 20px; line-height: 1.6; color: #333; }
h1 { border-bottom: 2px solid #333; padding-bottom: 8px; }
a { color: #0366d6; text-decoration: none; }
a:hover { text-decoration: underline; }
code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; }
pre { background: #f4f4f4; padding: 12px; border-radius: 6px; overflow-x: auto; }
ul { padding-left: 20px; }
li { margin: 6px 0; }
#login-form { max-width: 300px; margin: 80px auto; padding: 20px; border: 1px solid #ddd; border-radius: 8px; }
#login-form input { width: 100%; padding: 8px; margin: 8px 0; box-sizing: border-box; border: 1px solid #ccc; border-radius: 4px; }
#login-form button { width: 100%; padding: 10px; background: #0366d6; color: white; border: none; border-radius: 4px; cursor: pointer; }
#login-form button:hover { background: #024ea2; }
#error { color: #d73a49; display: none; margin-top: 8px; }
#content { display: none; }
</style>
</head>
<body>

<div id="login-form">
  <h2>Wiki Login</h2>
  <input type="text" id="user" placeholder="Username" autocomplete="off">
  <input type="password" id="pass" placeholder="Password">
  <button onclick="check()">Enter</button>
  <p id="error">Invalid credentials.</p>
</div>

<div id="content">
<h1>Personal LLM Wiki</h1>
<p>Pattern: <a href="https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f">Karpathy LLM Wiki</a></p>

<h2>Schema</h2>
<ul>
<li><a href="schema/AGENTS.md">AGENTS.md</a> — agent instructions</li>
</ul>

<h2>Wiki Pages</h2>
<ul>
<li><a href="wiki/index.md">index.md</a> — catalog</li>
<li><a href="wiki/log.md">log.md</a> — operation log</li>
</ul>

<h2>Raw Sources</h2>
<ul>
<li><a href="raw/">raw/</a> — immutable sources</li>
</ul>

<h2>Agent Access</h2>
<pre><code>https://raw.githubusercontent.com/jamesjfoong/personal-wiki/master/schema/AGENTS.md
https://raw.githubusercontent.com/jamesjfoong/personal-wiki/master/wiki/index.md
https://raw.githubusercontent.com/jamesjfoong/personal-wiki/master/wiki/log.md</code></pre>

<p><em>Maintained by Hermes Agent. Last updated: 2026-06-24</em></p>
</div>

<script>
async function sha256(text) {
  const buf = new TextEncoder().encode(text);
  const hash = await crypto.subtle.digest('SHA-256', buf);
  return Array.from(new Uint8Array(hash)).map(b => b.toString(16).padStart(2, '0')).join('');
}
const EXPECTED_USER = '{{USER_HASH}}';
const EXPECTED_PASS = '{{PASS_HASH}}';

async function check() {
  const u = document.getElementById('user').value;
  const p = document.getElementById('pass').value;
  const uh = await sha256(u);
  const ph = await sha256(p);
  if (uh === EXPECTED_USER && ph === EXPECTED_PASS) {
    document.getElementById('login-form').style.display = 'none';
    document.getElementById('content').style.display = 'block';
    localStorage.setItem('wiki_auth', EXPECTED_USER + ':' + EXPECTED_PASS);
  } else {
    document.getElementById('error').style.display = 'block';
  }
}

(async function() {
  const stored = localStorage.getItem('wiki_auth');
  if (stored && stored === EXPECTED_USER + ':' + EXPECTED_PASS) {
    document.getElementById('login-form').style.display = 'none';
    document.getElementById('content').style.display = 'block';
  }
})();
</script>

</body>
</html>
TEMPLATE

sed -i "s/{{USER_HASH}}/$USER_HASH/g" index.html
sed -i "s/{{PASS_HASH}}/$PASS_HASH/g" index.html

const express = require('express');
const store = require('./store');
const { log } = require('./logger');
const { register, appRequestsTotal, appErrorsTotal } = require('./metrics');

const app = express();

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

app.use((req, res, next) => {
  const start = Date.now();

  res.on('finish', () => {
    const route = req.route?.path || req.path;
    const labels = {
      method: req.method,
      route,
      status: String(res.statusCode)
    };

    appRequestsTotal.inc(labels);

    if (res.statusCode >= 400) {
      appErrorsTotal.inc(labels);
    }

    log('info', 'request handled', {
      method: req.method,
      path: req.originalUrl,
      route,
      status: res.statusCode,
      durationMs: Date.now() - start
    });
  });

  next();
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.get('/health', (req, res) => {
  res.json({
    ok: true,
    version: process.env.APP_VERSION || '1',
    slot: process.env.DEPLOY_SLOT || 'local'
  });
});

function renderPage(todoList) {
  const items = todoList
    .map(
      (t) =>
        `<li><a href="/todos/${t.id}">#${t.id}</a> — ${escapeHtml(t.title)}${
          t.done ? ' (done)' : ''
        } — <form method="post" action="/todos/${t.id}/toggle" style="display:inline"><button type="submit">Toggle</button></form></li>`
    )
    .join('');

  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Todo list</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 720px; margin: 2rem auto; padding: 0 1rem; }
    code { background: #f4f4f4; padding: 0.1rem 0.3rem; border-radius: 4px; }
  </style>
</head>
<body>
  <h1>Todo list</h1>
  <p>Add an item below. Open a todo via the dynamic route <code>/todos/:id</code>.</p>
  <form method="post" action="/todos">
    <label>New todo <input name="title" type="text" required /></label>
    <button type="submit">Add</button>
  </form>
  <h2>Items</h2>
  <ul>${items || '<li>No todos yet.</li>'}</ul>
</body>
</html>`;
}

function escapeHtml(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}

app.get('/', (req, res) => {
  res.type('html').send(renderPage(store.listTodos()));
});

app.get('/api/todos', (req, res) => {
  res.json({ todos: store.listTodos() });
});

app.get('/todos/:id', (req, res) => {
  const todo = store.getById(req.params.id);
  if (!todo) {
    return res.status(404).json({ error: 'Not found' });
  }
  res.json({ todo });
});

app.post('/todos', (req, res) => {
  const title = req.body?.title ?? req.body?.text;
  const todo = store.addTodo(title);
  if (!todo) {
    return res.status(400).json({ error: 'Title is required' });
  }

  const wantsJson =
    req.get('accept')?.includes('application/json') ||
    req.is('application/json');

  if (wantsJson) {
    return res.status(201).json({ todo });
  }

  res.redirect('/');
});

app.post('/todos/:id/toggle', (req, res) => {
  const todo = store.toggleTodo(req.params.id);
  if (!todo) {
    return res.status(404).json({ error: 'Not found' });
  }
  res.redirect('/');
});

app.get('/debug/error', (req, res) => {
  res.status(500).json({ error: 'Simulated error for observability testing' });
});

module.exports = app;

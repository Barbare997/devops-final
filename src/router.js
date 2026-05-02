const http = require('http');
const fs = require('fs');
const path = require('path');

const PROXY_PORT = Number(process.env.PROXY_PORT) || 8080;
const TARGET_HOST = process.env.TARGET_HOST || '127.0.0.1';

const stateFile = path.join(__dirname, '..', 'data', 'active-target.json');

function readTargetPort() {
  const raw = fs.readFileSync(stateFile, 'utf8');
  const cleaned = raw.replace(/^\uFEFF/, '').trimStart();
  const match = cleaned.match(/\{[\s\S]*\}/);
  if (!match) {
    throw new Error('No JSON object found in active-target.json');
  }
  const parsed = JSON.parse(match[0]);
  const port = Number(parsed.port);
  if (!Number.isInteger(port) || port <= 0) {
    throw new Error('Invalid port in active-target.json');
  }
  return port;
}

const server = http.createServer((clientReq, clientRes) => {
  let port;
  try {
    port = readTargetPort();
  } catch (err) {
    clientRes.statusCode = 502;
    clientRes.setHeader('content-type', 'text/plain; charset=utf-8');
    clientRes.end(`Router misconfigured: ${err.message}`);
    return;
  }

  const headers = { ...clientReq.headers, host: `${TARGET_HOST}:${port}` };

  const upstream = http.request(
    {
      hostname: TARGET_HOST,
      port,
      path: clientReq.url,
      method: clientReq.method,
      headers
    },
    (upRes) => {
      clientRes.writeHead(upRes.statusCode || 502, upRes.headers);
      upRes.pipe(clientRes);
    }
  );

  upstream.on('error', (err) => {
    clientRes.statusCode = 502;
    clientRes.setHeader('content-type', 'text/plain; charset=utf-8');
    clientRes.end(`Upstream error: ${err.message}`);
  });

  clientReq.pipe(upstream);
});

server.listen(PROXY_PORT, () => {
  // eslint-disable-next-line no-console
  console.log(
    `Blue-green router listening on http://localhost:${PROXY_PORT} (proxying via ${stateFile})`
  );
});

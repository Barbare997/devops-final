const client = require('prom-client');

const register = new client.Registry();
client.collectDefaultMetrics({ register });

const appRequestsTotal = new client.Counter({
  name: 'app_requests_total',
  help: 'Total HTTP requests handled by the application',
  labelNames: ['method', 'route', 'status'],
  registers: [register]
});

const appErrorsTotal = new client.Counter({
  name: 'app_errors_total',
  help: 'Total HTTP responses with status >= 400',
  labelNames: ['method', 'route', 'status'],
  registers: [register]
});

module.exports = {
  register,
  appRequestsTotal,
  appErrorsTotal
};

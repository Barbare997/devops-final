function log(level, message, fields = {}) {
  const entry = {
    timestamp: new Date().toISOString(),
    level,
    message,
    ...fields
  };
  // eslint-disable-next-line no-console
  console.log(JSON.stringify(entry));
}

module.exports = { log };

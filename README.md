# Midterm Project

Todo list web application with CI, infrastructure automation, blue-green deployment simulation, rollback scripts, and periodic health monitoring.

## Tech stack

- Node.js 18+
- Express
- Jest + Supertest
- ESLint
- GitHub Actions
- Ansible

## Application

- Dynamic route: `GET /todos/:id`
- Input endpoint: `POST /todos`
- Form UI: `GET /`
- Health endpoint: `GET /health`

## Local setup

```bash
npm ci
npm run lint
npm test
npm start
```

App URL: `http://localhost:3000/`

## Blue-green deployment simulation

Run two app instances:

- Blue: port `3001`
- Green: port `3002`

Run router:

```bash
npm run start:router
```

Router URL: `http://localhost:8080/`

Switch active traffic:

- Windows: `.\scripts\switch-traffic.ps1`
- Linux/macOS: `bash scripts/switch-traffic.sh`

Rollback:

- Windows: `.\scripts\rollback.ps1`
- Linux/macOS: `bash scripts/rollback.sh`

## Monitoring

Periodic health checks are logged to `logs/health.log`.

- Windows: `.\scripts\health-monitor.ps1`
- Linux/macOS: `bash scripts/health-monitor.sh`

## Infrastructure automation

```bash
ansible-playbook ansible/site.yml
```

## CI pipeline

Workflow file: `.github/workflows/ci.yml`

Runs on push and pull request:

- `npm ci`
- `npm run lint`
- `npm test`

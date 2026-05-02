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

On Windows, run this from **WSL (Ubuntu)**. Install Ansible inside WSL (`sudo apt install ansible`), `cd` to the project path under `/mnt/c/...`, then run the command above. The playbook still targets the same repo files on your Windows drive.

## CI pipeline

Workflow file: `.github/workflows/ci.yml`

Runs on push and pull request:

- `npm ci`
- `npm run lint`
- `npm test`

## Screenshots

### CI — workflow runs (`main` and `dev`)

![CI runs on main and dev](docs/readme/ci-runs-main-dev.png)

### CI — job summary (green run)

![CI job summary](docs/readme/ci-job-summary.png)

### CI — lint and test steps (expanded log)

![CI lint and test](docs/readme/ci-lint-test.png)

### Ansible

![Ansible playbook run](docs/readme/ansible-run.png)

### Deployment — app through router (`http://localhost:8080`)

![Running app via router](docs/readme/deploy-router-8080.png)

### Blue-green — switch and rollback (terminal output)

![Switch and rollback](docs/readme/deploy-switch-rollback.png)

### Monitoring — health log (`logs/health.log`)

![Health monitor log](docs/readme/monitoring-health-log.png)

### CI/CD workflow diagram

![CI/CD workflow diagram](docs/readme/cicd-diagram.png)

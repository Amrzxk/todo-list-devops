# 📝 Todo‑List (Node + DevOps)

A production‑ready version of the classic Todo application.
Beyond the Node/Express code you now get:

* **Multi‑stage Docker image** (non‑root, Alpine, built via CI)
* **GitHub Actions pipeline** – build, cache & push to a private Docker Hub repo
* **Ansible provisioning** – brings up Docker Engine + Compose on an Ubuntu EC2 free‑tier VM
* **Docker Compose deployment** – health‑checked service + **Watchtower** for automatic image updates

---

## 📑 Table of Contents

1. [Architecture](#architecture)
2. [Quick Start (Local)](#quick-start-local)
3. [CI / CD Pipeline](#ci--cd-pipeline)
4. [Infrastructure as Code (Ansible)](#infrastructure-as-code-ansible)
5. [Runtime (Stack on EC2)](#runtime-stack-on-ec2)
6. [Demo Video](#demo-video)
7. [Contributing & Authors](#contributing--authors)

---

## Architecture
<img width="621" height="372" alt="Workflow" src="https://github.com/user-attachments/assets/12ec9fa5-8556-44f2-999e-ddaf0ccc8bd4" />

* **Part 1** – container image is built & pushed by GitHub Actions.
* **Part 2** – Ansible playbook installs Docker/Compose on the VM.
* **Part 3** – Compose runs the app (`todo-web`) + `watchtower` which polls Docker Hub every 60 s and hot‑restarts when a new digest is available.


## Quick Start (Local)

```bash
# 1  Clone
$ git clone https://github.com/Amrzzk/todo-list-devops.git
$ cd todo-list-devops

# 2  Install deps & run
$ npm ci
$ npm start            # http://localhost:4000/
```

---

## CI / CD Pipeline

File: `.github/workflows/ci.yml`

* **Trigger** – every push to `main`.
* **BuildX** – layer‑cached BuildKit build.
* **Secrets** – `DOCKERHUB_USERNAME / DOCKERHUB_TOKEN` for private push.
* **Tag** – `docker.io/<user>/todo-list:latest`.


---

## Infrastructure as Code (Ansible)

* **Inventory** – `inventory.ini` lists the EC2 under `[todo_vm]` with its SSH key.
* **Playbook** – `provision.yml` performs: apt update → prereqs → Docker GPG key & repo → Docker Engine + Compose v2 → adds `ubuntu` to `docker` group.

Run from your **local WSL**:

```bash
ansible -i inventory.ini todo_vm -m ping          # expect pong
ansible-playbook -i inventory.ini provision.yml   # idempotent
```

---

## Runtime (Stack on EC2)

File: `docker-compose.yml`

### Services

| Service      | Purpose     | Highlights                                                       |
| ------------ | ----------- | ---------------------------------------------------------------- |
| `todo-web`   | Main API    | Health‑check via `wget`, non‑root UID, mapped `4000:4000`        |
| `watchtower` | Auto‑update | Polls every 60 s for newer `latest` tag and redeploys `todo-web` |

### Deploy / Update

```bash
# on the VM
cd ~/todo-list-devops
cp .env.example .env          # fill in Mongo URI + Docker Hub creds

docker compose up -d          # first run

docker compose ps             # todo-web -> healthy
```

Push a new tag and watch **watchtower** pull & restart within a minute.

---

## Contributing & Authors

*Original Node app* – [@Ankit6098](https://github.com/Ankit6098)
*DevOps extension* – **Amrzzk**

PRs & issues welcome!

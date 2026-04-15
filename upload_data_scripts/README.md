# Data Setup

Uploads initial data (groups, problems, solvers) to a running cluster via the solver-director API.

## Prerequisites

- [`psp-cli`](../psp-cli) installed and configured (`psp config show`)
- Cluster running with solver-director reachable at the configured `base_url`

## Usage

Log in as the admin app, then run the setup script from the repo root:

```bash
psp config set client_id admin-app
psp auth login              # prompts for secret securely
bash post-data-setup.sh
```

For local dev the secret is `admin`. You can also pass it via env var: `PSP_CLIENT_SECRET=admin psp auth login`.

To override the minizinc-solvers image (e.g. a locally built image):

```bash
MINIZINC_SOLVERS_IMAGE=ghcr.io/portfolio-solver-platform/minizinc-solvers:latest python setup.py
```

After setup, switch back to the user client:

```bash
psp config set client_id third-party-app
psp auth login
```

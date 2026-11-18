#!/usr/bin/env bash
# -----------------------------------------------------------
# post-create.sh
#
# Runs once after the dev container is created.
# Called from devcontainer.json postCreateCommand.
# -----------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
VENV_DIR="${REPO_ROOT}/.venv"

echo "==> [1/4] direnv: hook + whitelist"
grep -q 'direnv hook bash' ~/.bashrc \
    || echo "eval \"\$(direnv hook bash)\"" >> ~/.bashrc
# Trust all .envrc files under /workspaces/ automatically (no direnv allow needed)
mkdir -p ~/.config/direnv
cat > ~/.config/direnv/direnv.toml << 'EOF'
[whitelist]
prefix = ["/workspaces/"]
EOF

echo "==> [2/4] Python virtual environment + pre-commit"
python -m venv "${VENV_DIR}"
"${VENV_DIR}/bin/python" -m pip install --upgrade pip
"${VENV_DIR}/bin/python" -m pip install --require-hashes \
    -r "${REPO_ROOT}/.devcontainer/requirements-dev.txt"

echo "==> [3/4] Pre-commit install hooks"
cd "${REPO_ROOT}"
"${VENV_DIR}/bin/pre-commit" install --install-hooks

echo "==> [4/4] Tool versions"
terraform version
az bicep upgrade
az version

echo "==> post-create complete"

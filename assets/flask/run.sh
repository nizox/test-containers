#!/bin/sh

set -eu

export PYTHON_BIN="${PYTHON_BIN:-python}"
export PORT="${PORT:-8080}"
export WSGI_APP="stub:app"
export FLASK_APP=${WSGI_APP}

exec ${SQREEN_START} ${PYTHON_BIN} -m flask run --host 0.0.0.0 --port ${PORT}

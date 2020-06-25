#!/bin/sh

exec gunicorn -p ${PORT:-8080} ${WSGI_APP:-stub:app}

#!/bin/bash
set -euo pipefail

docker rm -f samplerunning 2>/dev/null || true
rm -rf tempdir
mkdir -p tempdir/templates tempdir/static

cp sample_app.py tempdir/
cp -r templates/* tempdir/templates/ 2>/dev/null || true
cp -r static/* tempdir/static/ 2>/dev/null || true

# Overwrite Dockerfile (note single > not >>)
cat > tempdir/Dockerfile <<'EOF'
FROM python:3.11-slim

ENV PIP_PROGRESS_BAR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /home/myapp
COPY ./static /home/myapp/static/
COPY ./templates /home/myapp/templates/
COPY sample_app.py /home/myapp/

RUN pip install --no-cache-dir flask==3.1.2

EXPOSE 5050
CMD ["python","/home/myapp/sample_app.py"]
EOF

cd tempdir
docker build -t sampleapp .
docker run -d --name samplerunning -p 5050:5050 sampleapp
docker ps -a


#!/bin/bash
set -euo pipefail

# --- Preconditions: ensure Docker is usable inside Jenkins ---
if ! command -v docker >/dev/null 2>&1 || [ ! -S /var/run/docker.sock ]; then
  echo "ERROR: Docker CLI or /var/run/docker.sock not available inside Jenkins."
  echo "Ask the VM admin to run Jenkins with Docker mounted, e.g.:"
  echo "docker run --rm --name jenkins_server -p 8080:8080 \\"
  echo "  -v jenkins-data:/var/jenkins_home -v /usr/bin/docker:/usr/bin/docker \\"
  echo "  -v /var/run/docker.sock:/var/run/docker.sock --security-opt seccomp=unconfined jenkins/jenkins:lts"
  exit 1
fi

# --- Clean & stage build context ---
docker rm -f samplerunning >/dev/null 2>&1 || true
rm -rf tempdir
mkdir -p tempdir/templates tempdir/static

cp sample_app.py tempdir/
cp -r templates/* tempdir/templates/ 2>/dev/null || true
cp -r static/*    tempdir/static/    2>/dev/null || true

# --- Dockerfile (overwrite each run) ---
cat > tempdir/Dockerfile <<'EOF'
FROM python:3.11-slim
ENV PIP_PROGRESS_BAR=off PIP_DISABLE_PIP_VERSION_CHECK=1
WORKDIR /home/myapp
COPY ./static     /home/myapp/static/
COPY ./templates  /home/myapp/templates/
COPY sample_app.py /home/myapp/
RUN pip install --no-cache-dir flask==3.1.2
EXPOSE 5050
CMD ["python","/home/myapp/sample_app.py"]
EOF

# --- Build & run ---
cd tempdir
docker build -t sampleapp .
docker run -d --name samplerunning -p 5050:5050 sampleapp
docker ps -a

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

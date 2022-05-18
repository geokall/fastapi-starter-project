FROM python:3.9.10-alpine3.15

RUN apk update && apk add gcc  libc-dev
WORKDIR /usr/data
COPY ./requirements.txt .

COPY ./app app
COPY ./tests tests

RUN pip install -r requirements.txt
EXPOSE 8000/tcp
CMD ["uvicorn","app.main:app","--host", "0.0.0.0", "--port", "8000"]
FROM debian:buster

MAINTAINER petr.messner@gmail.com

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get install -y --no-install-recommends \
        curl \
        gnupg \
        apt-transport-https \
        python3 \
        python3-venv \
        python3-dev \
        build-essential \
        nginx-full

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

RUN curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN echo "deb https://deb.nodesource.com/node_6.x stretch main" > /etc/apt/sources.list.d/nodesource.list

RUN apt-get update
RUN apt-get install -y nodejs
RUN apt-get install -y yarn

RUN python3 -m venv /venv-hub
RUN python3 -m venv /venv-agents

RUN /venv-hub/bin/pip install -U pip wheel
RUN /venv-hub/bin/pip install pyyaml aiohttp simplejson

RUN /venv-agents/bin/pip install -U pip wheel
RUN /venv-agents/bin/pip install pyyaml requests psutil

COPY overwatch-web/package.json /overwatch-web/
COPY overwatch-web/yarn.lock /overwatch-web/

RUN cd /overwatch-web && yarn install

COPY overwatch-basic-agents /overwatch-basic-agents/
COPY overwatch-hub /overwatch-hub/
COPY overwatch-web /overwatch-web/

RUN /venv-hub/bin/pip install /overwatch-hub
RUN /venv-agents/bin/pip install /overwatch-basic-agents
RUN cd /overwatch-web && yarn build

COPY runner.py /runner.py
COPY nginx.conf /nginx.conf

EXPOSE 8000

CMD ["python3", "/runner.py"]

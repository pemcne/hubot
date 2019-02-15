FROM node:alpine

MAINTAINER Peter McNeill

ENV PATH="/home/node/node_modules/.bin/:${PATH}"
RUN apk update && apk upgrade && apk add git make && rm -rf /var/cache/apk/*
USER node
WORKDIR /home/node

ADD package.json /home/node/package.json
ADD external-scripts.json /home/node/external-scripts.json

RUN npm install

CMD ["-a", "slack"]
ENTRYPOINT ["hubot", "-n", "hubot"]

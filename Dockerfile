FROM node:alpine

MAINTAINER Peter McNeill

RUN apk update && apk upgrade && apk add git make && rm -rf /var/cache/apk/*
RUN npm install -g yo generator-hubot && adduser -s /bin/bash -S user
USER user
WORKDIR /home/user

RUN yo hubot --adapter=slack --owner="Peter McNeill" --name="slackbot" --description="Hubot" --defaults && rm -f hubot-scripts.json
RUN npm install --save hubot-redis-brain cheerio fuzzy-matching

CMD ["-a", "slack"]
ENTRYPOINT ["./bin/hubot", "-n", "hubot"]

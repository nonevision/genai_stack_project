FROM node:alpine

WORKDIR /app

COPY front-end/ .

COPY .npmrc .
RUN npm ci

EXPOSE 8505

ENTRYPOINT [ "npm", "run", "dev" ]

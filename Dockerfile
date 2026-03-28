# Stage 1: Build the React app
FROM node:16.20.0-alpine3.18 AS builder

RUN mkdir /home/node/app/ && chown -R node:node /home/node/app
WORKDIR /home/node/app

COPY --chown=node:node package.json ./
COPY --chown=node:node yarn.lock ./

USER node
RUN yarn install --non-interactive --frozen-lockfile && yarn cache clean

COPY --chown=node:node tsconfig.json ./
COPY --chown=node:node ./src/ ./src
COPY --chown=node:node ./public/ ./public

ARG REACT_APP_BROKER_URL
ARG REACT_APP_VERSION
ARG REACT_APP_MAINTENANCE=false
ENV REACT_APP_BROKER_URL=$REACT_APP_BROKER_URL
ENV REACT_APP_VERSION=$REACT_APP_VERSION
ENV REACT_APP_MAINTENANCE=$REACT_APP_MAINTENANCE

RUN yarn build

# Stage 2: Serve the built app with Express + CSP headers
FROM node:16.20.0-alpine3.18
USER node
WORKDIR /home/node/app

COPY --chown=node:node --from=builder /home/node/app/build ./build
COPY --chown=node:node server.js ./

RUN npm install --prefix . express@4.18.2 express-rate-limit@7.1.5

CMD ["node", "server.js"]
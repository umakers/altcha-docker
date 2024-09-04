# syntax=docker/dockerfile:1

ARG NODE_VERSION=20.17.0
FROM node:${NODE_VERSION}-alpine as base

WORKDIR /usr/src/app
RUN corepack enable

FROM base as deps

RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=yarn.lock,target=yarn.lock \
    --mount=type=bind,source=.yarnrc.yml,target=.yarnrc.yml \
    --mount=type=cache,target=/root/.yarn \
    yarn workspaces focus --production --immutable

FROM deps as build

RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=yarn.lock,target=yarn.lock \
    --mount=type=bind,source=.yarnrc.yml,target=.yarnrc.yml \
    --mount=type=cache,target=/root/.yarn \
    yarn workspaces focus --immutable

COPY . .
RUN yarn run build

FROM base as final

ENV NODE_ENV production
USER node
COPY package.json .
COPY .env .
COPY src/demo/index.html ./build/demo/index.html
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/build ./build

EXPOSE 3000

CMD yarn start

# syntax=docker/dockerfile:1

FROM node:20-bullseye AS base

WORKDIR /usr/src/app


# Install dependencies needed for pnpm
RUN apt-get update && apt-get install -y curl

# Install pnpm manually (bypassing Corepack)
RUN npm install -g pnpm

# Ensure pnpm is accessible in the PATH
ENV PATH="/root/.npm-global/bin:$PATH"

# Verify pnpm installation
RUN pnpm --version

# Copy package files and install dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm i --frozen-lockfile



FROM base as build
COPY package.json pnpm-lock.yaml ./
RUN pnpm i --frozen-lockfile


COPY . .
RUN pnpm run build

FROM base as final

ENV NODE_ENV production
USER node
COPY package.json .
COPY .env .
COPY src/demo/index.html ./build/demo/index.html
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/build ./build

EXPOSE 3000

CMD npm start

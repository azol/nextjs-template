# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/go/dockerfile-reference/
#
# docker build -f Dockerfile -t app:latest .
#
# docker run --rm -p 3000:3000 app:latest

ARG NODE_VERSION=24.21.0

FROM node:${NODE_VERSION}-slim AS deps
WORKDIR /app

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.npm to speed up subsequent builds.
# Leverage a bind mounts to package.json and package-lock.json to avoid having to copy them into
# into this layer.
RUN --mount=type=bind,source=package.json,target=package.json,readonly \
    --mount=type=bind,source=package-lock.json,target=package-lock.json,readonly \
    --mount=type=cache,target=/root/.npm,sharing=locked \
    npm_config_update_notifier=false \
    npm_config_ignore_scripts=true \
    npm_config_audit=false \
    npm_config_fund=false \
    npm ci --ignore-scripts --no-audit --no-fund

FROM deps AS builder
WORKDIR /app

# https://nextjs.org/telemetry
ENV NEXT_TELEMETRY_DISABLED=1

COPY --link . .

RUN --mount=type=cache,target=/app/.next/cache,sharing=locked \
    npm run build

FROM node:${NODE_VERSION}-slim AS runner
WORKDIR /app

# Override Docker's automatic HOSTNAME so the Next.js standalone server binds to all interfaces.
ENV HOSTNAME="0.0.0.0" \
    NEXT_TELEMETRY_DISABLED=1

# standalone output: https://nextjs.org/docs/pages/api-reference/config/next-config-js/output
COPY --link --from=builder --chown=node:node /app/.next/standalone ./
COPY --link --from=builder --chown=node:node /app/.next/static ./.next/static
COPY --link --from=builder --chown=node:node /app/public ./public

# Expose the port that the application listens on.
EXPOSE 3000

# Run the application as a non-root user.
USER node

# standalone output: https://nextjs.org/docs/pages/api-reference/config/next-config-js/output
CMD ["node", "server.js"]

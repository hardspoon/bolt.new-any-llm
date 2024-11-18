FROM node:20.18.0 AS builder
RUN corepack enable pnpm
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm run build

FROM node:20.18.0-slim AS runner
WORKDIR /app
COPY --from=builder /app/build ./build
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/pnpm-lock.yaml ./pnpm-lock.yaml
RUN corepack enable pnpm && \
    pnpm install --prod --frozen-lockfile && \
    rm -rf /root/.npm /root/.pnpm-store /usr/local/share/.cache

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT}/health || exit 1

EXPOSE ${PORT}
CMD ["sh", "-c", "node ./build/server/index.js --host 0.0.0.0 --port ${PORT}"]

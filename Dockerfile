FROM node:20.18.0 AS builder

# Install pnpm
RUN corepack enable pnpm

WORKDIR /app

# Install dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy application code
COPY . .

# Build the application
RUN pnpm run build

# Production image
FROM node:20.18.0-slim AS runner

WORKDIR /app

# Copy built application
COPY --from=builder /app/build ./build
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/pnpm-lock.yaml ./pnpm-lock.yaml

# Install production dependencies only
RUN corepack enable pnpm && pnpm install --prod --frozen-lockfile

# Set production environment
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000

# Expose the port
EXPOSE ${PORT}

# Start the server, binding to all interfaces
CMD ["sh", "-c", "node ./build/server/index.js --host 0.0.0.0 --port ${PORT}"]

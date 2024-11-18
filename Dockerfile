FROM node:20.18.0 AS base

# Install pnpm
RUN corepack enable pnpm

WORKDIR /app

# Install dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm install

# Copy application code
COPY . .

# Build the application
RUN pnpm run build

# Set production environment
ENV NODE_ENV=production
ENV PORT=3000

# Define API key environment variables
ENV GROQ_API_KEY=""
ENV OPENAI_API_KEY=""
ENV ANTHROPIC_API_KEY=""
ENV OPEN_ROUTER_API_KEY=""
ENV GOOGLE_GENERATIVE_AI_API_KEY=""
ENV OLLAMA_API_BASE_URL=""
ENV VITE_LOG_LEVEL=info

# Expose the port
EXPOSE ${PORT}

# Start the server
CMD ["node", "./build/server/index.js"]

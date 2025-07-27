# ------- Builder stage -------
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .

# ------- Runtime stage -------
FROM node:20-alpine
ENV NODE_ENV=production

# Create a non-root user
RUN addgroup -S nodegrp && adduser -S nodeusr -G nodegrp

# Set the working directory
WORKDIR /app
COPY --from=builder /app .
USER nodeusr
EXPOSE 4000
HEALTHCHECK --interval=30s --timeout=30s --retries=3 \
    CMD wget -qO- http://localhost:4000/ || exit 1
CMD ["node", "index.js"]

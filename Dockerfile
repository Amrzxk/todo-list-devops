# ------- Runtime stage -------
FROM node:20-apline
ENV NODE_ENV=production

# Create a non-root user
RUN addgroup -S nodegrp && adduser -S nodeusr -G nodegrp

# Set the working directory
WORKDIR /app
COPY --from=builder /app .
USER nodeusr
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=30s --retries=3 \
    CMD wget -qO- http:localhost:3000/ || exit 1
CMD ["node", "server.js"]

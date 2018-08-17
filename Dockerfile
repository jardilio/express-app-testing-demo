FROM node:6-alpine

ENV NODE_ENV=production
ENV PORT=8080
EXPOSE 8080

WORKDIR /workspace
COPY . /workspace/
RUN npm prune --production

ENTRYPOINT [ "node", "." ]
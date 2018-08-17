FROM node:6

WORKDIR /workspace
COPY . /workspace/

ENV PORT=8080
EXPOSE 8080

ENTRYPOINT [ "node", "." ]
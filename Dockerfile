FROM golang:1.15 as build-be
ADD . /quickshare
WORKDIR /quickshare
RUN /quickshare/scripts/build_exec.sh

FROM node:lts as build-fe
COPY --from=build-be /quickshare /quickshare
WORKDIR /quickshare
RUN yarn run build:fe \
    && cp -R /quickshare/public /quickshare/dist/quickshare

FROM debian:stable-slim
RUN groupadd -g 8686 quickshare
RUN useradd quickshare -u 8686 -g 8686 -m -s /bin/bash
RUN usermod -a -G quickshare root
COPY --from=build-fe /quickshare/dist/quickshare /quickshare
ADD configs/demo.yml /quickshare
RUN mkdir -p /quickshare/root
RUN chgrp -R quickshare /quickshare
RUN chmod -R 0770 /quickshare
CMD ["/quickshare/start", "-c", "/quickshare/demo.yml"]

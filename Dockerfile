ARG version=3.1.0
ARG file=zcash-${version}-linux64-debian-stretch.tar.gz
ARG folder=zcash-${version}

FROM debian:stable as stage1
ARG version
ARG file
ARG folder
WORKDIR /the/workdir
RUN apt update
RUN apt install -y wget
RUN wget https://z.cash/downloads/${file}
RUN tar -vxf ${file}
RUN chmod +x /the/workdir/${folder}/bin/zcashd

FROM photon
ARG folder
ARG entry=/app/entrypoint.sh
COPY --from=stage1 /the/workdir/${folder}/bin/zcashd /app/zcashd
COPY --from=stage1 /the/workdir/${folder}/bin/zcash-fetch-params /app/zcash-fetch-params
RUN tdnf install -y libstdc++
RUN echo '#!/usr/bin/env bash' > ${entry}
RUN echo 'set -e' >> ${entry}
RUN echo '/app/zcash-fetch-params' >> ${entry}
RUN echo 'touch /data/zcash.conf' >> ${entry}
RUN echo '/app/zcashd -datadir=/data -printtoconsole -server -rpcbind=0.0.0.0 -rpcallowip=127.0.0.1 -rpcport=8232 -rpcuser=zcash -rpcpassword=password -prune=$PRUNE' >> ${entry}
RUN chmod +x ${entry}
ENV PRUNE 10000
VOLUME /data
EXPOSE 8232
ENTRYPOINT [ "/app/entrypoint.sh" ]

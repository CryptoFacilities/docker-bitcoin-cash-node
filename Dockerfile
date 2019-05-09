FROM debian:stretch as builder

RUN apt-get update && apt-get install -y curl

ENV BABC_VERSION=0.19.5
ENV BABC_CHECKSUM="6b95bc75dd0f40eb86076bae002a87a1878b4f12614dfeeefa888ea4fdaebf8a bitcoin-abc-${BABC_VERSION}-x86_64-linux-gnu.tar.gz"

RUN curl -SLO "https://download.bitcoinabc.org/${BABC_VERSION}/linux/bitcoin-abc-${BABC_VERSION}-x86_64-linux-gnu.tar.gz" \
  && echo "${BABC_CHECKSUM}" | sha256sum -c - | grep OK \
  && tar -xzf bitcoin-abc-${BABC_VERSION}-x86_64-linux-gnu.tar.gz

FROM bitnami/minideb:stretch
ENV BABC_VERSION=0.19.5
RUN useradd -m bitcoin
RUN apt-get remove -y --allow-remove-essential --purge adduser gpgv mount hostname gzip login sed
USER bitcoin
COPY --from=builder /bitcoin-abc-${BABC_VERSION}/bin/bitcoind /bin/bitcoind
RUN mkdir -p /home/bitcoin/.bitcoin
ENTRYPOINT ["bitcoind"]
CMD ["-printtoconsole"]

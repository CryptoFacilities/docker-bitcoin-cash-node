FROM debian:stretch as builder

RUN apt-get update && apt-get install -y curl

ENV BABC_VERSION=0.21.6
ENV BABC_CHECKSUM="94880665d1a0dd6586311fe650ee422665061bc1c644c23789a58b6b83eb2bf9 bitcoin-abc-${BABC_VERSION}-x86_64-linux-gnu.tar.gz"

RUN curl -SLO "https://download.bitcoinabc.org/${BABC_VERSION}/linux/bitcoin-abc-${BABC_VERSION}-x86_64-linux-gnu.tar.gz" \
  && echo "${BABC_CHECKSUM}" | sha256sum -c - | grep OK \
  && tar -xzf bitcoin-abc-${BABC_VERSION}-x86_64-linux-gnu.tar.gz

FROM bitnami/minideb:stretch
ENV BABC_VERSION=0.21.6
RUN useradd -m bitcoin
RUN apt-get remove -y --allow-remove-essential --purge adduser gpgv mount hostname gzip login sed
USER bitcoin
COPY --from=builder /bitcoin-abc-${BABC_VERSION}/bin/bitcoind /bin/bitcoind
RUN mkdir -p /home/bitcoin/.bitcoin
ENTRYPOINT ["bitcoind"]
CMD ["-printtoconsole"]

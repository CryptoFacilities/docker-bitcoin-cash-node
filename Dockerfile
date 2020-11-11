FROM debian:stretch as builder

RUN apt-get update && apt-get install -y curl

ENV BCN_VERSION=22.1.0
# from e.g. https://gitlab.com/bitcoin-cash-node/announcements/-/raw/master/release-sigs/22.1.0/SHA256SUMS.22.1.0.asc.freetrader
ENV BCN_CHECKSUM="aa1002d51833b0de44084bde09951223be4f9c455427aef277f91dacd2f0f657  bitcoin-cash-node-22.1.0-x86_64-linux-gnu.tar.gz"

RUN curl -SLO "https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v${BCN_VERSION}/bitcoin-cash-node-${BCN_VERSION}-x86_64-linux-gnu.tar.gz" \
  && echo "${BCN_CHECKSUM}" | sha256sum -c - | grep OK \
  && tar -xzf bitcoin-cash-node-${BCN_VERSION}-x86_64-linux-gnu.tar.gz

FROM bitnami/minideb:stretch
ENV BCN_VERSION=22.1.0
RUN useradd -m bitcoin
RUN apt-get remove -y --allow-remove-essential --purge adduser gpgv mount hostname gzip login sed
USER bitcoin
COPY --from=builder /bitcoin-cash-node-${BCN_VERSION}/bin/bitcoind /bin/bitcoind
RUN mkdir -p /home/bitcoin/.bitcoin
ENTRYPOINT ["bitcoind"]
CMD ["-printtoconsole"]

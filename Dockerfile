################################################################################
# Build a dockerfile for Prosody XMPP server
# Based on ubuntu
################################################################################

FROM ubuntu:14.04

MAINTAINER Lloyd Watkin <lloyd@evilprofessor.co.uk>

# Install dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libidn11 \
        liblua5.1-expat0 \
        libssl1.0.0 \
        lua-dbi-mysql \
        lua-dbi-postgresql \
        lua-dbi-sqlite3 \
        lua-event \
        lua-expat \
        lua-filesystem \
        lua-sec \
        lua-socket \
        lua-zlib \
        lua-zlib \
        lua-bitop \
        lua5.1 \
        openssl \
    && rm -rf /var/lib/apt/lists/*

# Install and configure prosody
COPY ./prosody.deb /tmp/prosody.deb
RUN dpkg -i /tmp/prosody.deb \
    && sed -i '1s/^/daemonize = false;\n/' /etc/prosody/prosody.cfg.lua \
    && perl -i -pe 'BEGIN{undef $/;} s/^log = {.*?^}$/log = {\n    {levels = {min = "info"}, to = "console"};\n}/smg' /etc/prosody/prosody.cfg.lua

COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

RUN mkdir -p /var/lib/prosody
RUN chown -R prosody:prosody /var/lib/prosody
RUN chmod -R 750 /var/lib/prosody

EXPOSE 80 443 5222 5269 5347 5280 5281
CMD ["prosodyctl", "start"]

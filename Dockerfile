FROM alpine AS builder

ARG SC_VER TARGETOS TARGETARCH TARGETVARIANT

RUN <<EOF
apk --cache=no upgrade
apk --cache=no add gcc git musl-dev
git clone -b "$SC_VER" --depth=1 --single-branch \
  https://github.com/gotoh/ssh-connect /tmp/ssh-connect
cd /tmp/ssh-connect
gcc -O2 -DNDEBUG -Wall connect.c -s -o connect
gcc -O2 -DNDEBUG -Wall connect.c -s -static -o connect-static
ldd connect | sort -f
ldd connect-static | sort -f
tar c -zvf "/opt/connect-$TARGETOS-$TARGETARCH$TARGETVARIANT.tar.gz" connect
tar c -zvf "/opt/connect-$TARGETOS-$TARGETARCH$TARGETVARIANT-static.tar.gz" connect-static
EOF

FROM scratch
COPY --from=builder --link /opt/connect-*.tar.gz /

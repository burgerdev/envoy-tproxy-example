#!/bin/sh

set -eu

echo "### TEST SETUP ###"
podman network create --ignore tproxy-test
podman rm -f aproxy
podman rm -f aserver
podman rm -f bserver
podman run --replace -d --name=aserver --network=tproxy-test docker.io/kennethreitz/httpbin:latest
podman run --replace -d --name=aproxy --cap-add=NET_ADMIN --network=container:aserver -v "$PWD/envoy.yaml:/envoy.yaml:ro" --entrypoint /usr/local/bin/envoy docker.io/envoyproxy/envoy:v1.29-latest -c /envoy.yaml --log-level debug
podman run --replace -d --name=bserver --network=tproxy-test docker.io/kennethreitz/httpbin:latest

# TODO: wait until ready
sleep 1

ipt() {
    podman run --rm --network=container:aproxy --cap-add=NET_ADMIN docker.io/nicolaka/netshoot iptables-nft "$@"
}
ipt -t mangle -A PREROUTING -p tcp -i lo -j ACCEPT
ipt -t mangle -A PREROUTING -p tcp -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ipt -t mangle -A PREROUTING -p tcp -j TPROXY --on-port 4999

podman run --rm --network=tproxy-test -v "$PWD/test_ingress.sh:/test.sh:ro" docker.io/nicolaka/netshoot bash /test.sh

podman run --rm --network=container:aserver -v "$PWD/test_egress.sh:/test.sh:ro" docker.io/nicolaka/netshoot bash /test.sh

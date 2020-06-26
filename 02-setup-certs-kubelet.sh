#!/bin/bash

set -ex

WORKER_INTERNAL_IPS=("10.3.156.5" "10.3.156.6" "10.3.156.7")
WORKER_EXTERNAL_IPS=("212.34.83.23" "212.34.83.24" "212.34.83.25") # to be filled

for i in {0..2}; do
instance="worker-${i}"
cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

EXTERNAL_IP=${WORKER_EXTERNAL_IPS[$i]}
INTERNAL_IP=${WORKER_INTERNAL_IPS[$i]}

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
  -profile=kubernetes \
  ${instance}-csr.json | cfssljson -bare ${instance}
done
for instance in worker-1 worker-2 worker-3; do
etcd_ip=$(ssh $instance "hostname -i"| cut -d ' ' -f1)
loadbalancer=$(ssh $instance "hostname -i"| cut -d ' ' -f1)
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

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${etcd_ip},${loadbalancer} \
  -profile=kubernetes \
  ${instance}-csr.json | cfssljson -bare ${instance}
  mv ${instance}-key.pem ${instance}.key
  mv ${instance}.pem ${instance}.crt
done

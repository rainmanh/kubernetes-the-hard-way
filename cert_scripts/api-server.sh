services="kube-apiserver"
KUBERNETES_HOSTNAMES="kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local,master-1,master-2"
etcd_ips="127.0.0.1,10.96.0.1"
for etcd_host in master-1 master-2; do
  etcd_ip=$(ssh $etcd_host "hostname -i"| cut -d ' ' -f1)
  etcd_ips="$etcd_ips,${etcd_ip}"
done
for service in $services; do
cat > ${service}-csr.json <<EOF
{
  "CN": "system:${service}",
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
    -ca=ca.crt \
    -ca-key=ca.key \
    -config=ca-config.json \
    -hostname=${etcd_ips[@]},${KUBERNETES_HOSTNAMES} \
    -profile=kubernetes \
    ${service}-csr.json | cfssljson -bare ${service}
    mv ${service}-key.pem ${service}.key
    mv ${service}.pem ${service}.crt
done

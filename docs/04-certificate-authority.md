# Provisioning a CA and Generating TLS Certificates

In this lab you will provision a [PKI Infrastructure](https://en.wikipedia.org/wiki/Public_key_infrastructure) using the popular openssl tool, then use it to bootstrap a Certificate Authority, and generate TLS certificates for the following components: etcd, kube-apiserver, kube-controller-manager, kube-scheduler, kubelet, and kube-proxy.

# Where to do these?

You can do these on any machine with `cfssl` on it. But you should be able to copy the generated files to the provisioned VMs. Or just do these from one of the master nodes.

To install the tool in Ubuntu:

```
sudo apt-get install -y golang-cfssl
```

In our case we do it on the master-1 node, as we have set it up to be the administrative client.


## Certificate Authority

In this section you will provision a Certificate Authority that can be used to generate additional TLS certificates.

Create a CA certificate, then generate a Certificate Signing Request and use it to create a private key:


```
{

cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca
mv ca-key.pem ca.key
mv ca.pem ca.crt
}
```
Results:

```
ca.crt
ca.key
```

Reference : https://kubernetes.io/docs/concepts/cluster-administration/certificates/#cfssl

The ca.crt is the Kubernetes Certificate Authority certificate and ca.key is the Kubernetes Certificate Authority private key.
You will use the ca.crt file in many places, so it will be copied to many places.
The ca.key is used by the CA for signing certificates. And it should be securely stored. In this case our master node(s) is our CA server as well, so we will store it on master node(s). There is not need to copy this file to elsewhere.

## Client and Server Certificates

In this section you will generate client and server certificates for each Kubernetes component and a client certificate for the Kubernetes `admin` user.

### The Admin Client Certificate

Generate the `admin` client certificate and private key:

```
{

cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:masters",
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
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin
  mv admin-key.pem mv admin.key
  mv admin.pem admin.crt
```

Note that the admin user is part of the **system:masters** group. This is how we are able to perform any administrative operations on Kubernetes cluster using kubectl utility.

Results:

```
admin.key
admin.crt
```

The admin.crt and admin.key file gives you administrative access. We will configure these to be used with the kubectl tool to perform administrative functions on kubernetes.

### The Kubelet Client Certificates

We are going to skip certificate configuration for Worker Nodes for now. We will deal with them when we configure the workers.
For now let's just focus on the control plane components.

### The Controller Manager , kube-proxy, kube-scheduler and service-accounts Client Certificate

Generate the `kube-controller-manager` `kube-proxy` `kube-scheduler` `service-accounts` client certificates and private key:

```
services="kube-controller-manager kube-proxy kube-scheduler service-accounts"
etcd_ips="127.0.0.1"
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
    -hostname=${etcd_ips[@]} \
    -profile=kubernetes \
    ${service}-csr.json | cfssljson -bare ${service}
    mv ${service}-key.pem ${service}.key
    mv ${service}.pem ${service}.crt
done
```

Results:

```
kube-controller-manager.key
kube-controller-manager.crt
kube-proxy.key
kube-proxy.crt
kube-scheduler.key
kube-scheduler.crt
service-accounts.key
service-accounts.crt
```

### The Kubernetes API Server Certificate

The kube-apiserver certificate requires all names that various components may reach it to be part of the alternate names. These include the different DNS names, and IP addresses such as the master servers IP address, the load balancers IP address, the kube-api service IP address etc.

The `openssl` command cannot take alternate names as command line parameter. So we must create a `conf` file for it:

```
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

```
Results:

```
kube-apiserver.crt
kube-apiserver.key
```

### The ETCD Server Certificate

Similarly ETCD server certificate must have addresses of all the servers part of the ETCD cluster


```
services="etcd-server"
KUBERNETES_HOSTNAMES="kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local"
etcd_ips="127.0.0.1"
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
```

Results:

```
etcd-server.key
etcd-server.crt
```

## Distribute the Certificates

Copy the appropriate certificates and private keys to each controller instance:

```
for instance in master-1 master-2; do
  scp ca.crt ca.key kube-apiserver.key kube-apiserver.crt \
    service-account.key service-account.crt \
    etcd-server.key etcd-server.crt \
    ${instance}:~/
done
```

> The `kube-proxy`, `kube-controller-manager`, `kube-scheduler`, and `kubelet` client certificates will be used to generate client authentication configuration files in the next lab. These certificates will be embedded into the client authentication configuration files. We will then copy those configuration files to the other master nodes.

Next: [Generating Kubernetes Configuration Files for Authentication](05-kubernetes-configuration-files.md)

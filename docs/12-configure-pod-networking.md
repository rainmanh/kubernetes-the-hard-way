# Provisioning Pod Network

We can do either of the following: CNI or CNI-Weave for networking.

On both cases we have to do the same to install the CNI Plugin

## Install CNI plugin

Download the CNI Plugins required for weave on each of the worker nodes - `worker-1` and `worker-2`

`wget https://github.com/containernetworking/plugins/releases/download/v0.8.0/cni-plugins-amd64-v0.8.0.tgz`

Extract it to /opt/cni/bin directory

`sudo tar -xzvf cni-plugins-amd64-v0.8.0.tgz  --directory /opt/cni/bin/`

Reference: https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/#cni

## CNI 

Create the bridge network configuration file:

```
cat <<EOF | sudo tee /etc/cni/net.d/10-bridge.conf
{
    "cniVersion": "0.3.1",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "10.32.0.0/12"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF
```

Create the loopback network configuration file:

```
cat <<EOF | sudo tee /etc/cni/net.d/99-loopback.conf
{
    "cniVersion": "0.3.1",
    "name": "lo",
    "type": "loopback"
}
EOF
```

## CNI- WEAVE

We chose to use CNI - [weave](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/) as our networking option.


Deploy weave network. Run only once on the `master` node.


`kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"`

Weave uses POD CIDR of `10.32.0.0/12` by default.

## Verification

List the registered Kubernetes nodes from the master node:

```
master-1$ kubectl get pods -n kube-system
```

> output

```
NAME              READY   STATUS    RESTARTS   AGE
weave-net-58j2j   2/2     Running   0          89s
weave-net-rr5dk   2/2     Running   0          89s
```

Reference: https://kubernetes.io/docs/tasks/administer-cluster/network-policy-provider/weave-network-policy/#install-the-weave-net-addon

Next: [Kube API Server to Kubelet Connectivity](13-kube-apiserver-to-kubelet.md)

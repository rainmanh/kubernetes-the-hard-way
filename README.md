> This tutorial is based on [Kelsey Hightower](https://github.com/kelseyhightower/kubernetes-the-hard-way) and [mmumshad](https://github.com/mmumshad/kubernetes-the-hard-way/
)
# Kubernetes The Hard Way On VirtualBox

This tutorial walks you through setting up Kubernetes the hard way on a local machine using VirtualBox.
This guide is not for people looking for a fully automated command to bring up a Kubernetes cluster.
If that's you then check out [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine), or the [Getting Started Guides](http://kubernetes.io/docs/getting-started-guides/).

Kubernetes The Hard Way is optimized for learning, which means taking the long route to ensure you understand each task required to bootstrap a Kubernetes cluster.

This tutorial is a modified version of the original developed by [Kelsey Hightower](https://github.com/kelseyhightower/kubernetes-the-hard-way) and also an adapted copy by [mmumshad](https://github.com/mmumshad/kubernetes-the-hard-way/
While the original one uses GCP as the platform to deploy kubernetes,  we use VirtualBox and Vagrant to deploy a cluster on a local machine. If you prefer the Google cloud version, refer to the original one [here](https://github.com/kelseyhightower/kubernetes-the-hard-way)

In this version we use both: docker and comtainerd. There are a few other differences to the original and they are documented [here](docs/differences-to-original.md)

> The results of this tutorial should not be viewed as production ready, and may receive limited support from the community, but don't let that stop you from learning!

## Target Audience

The target audience for this tutorial is someone planning to support a production Kubernetes cluster and wants to understand how everything fits together.

## Cluster Details

Kubernetes The Hard Way guides you through bootstrapping a highly available Kubernetes cluster with end-to-end encryption between components and RBAC authentication.

* [Kubernetes](https://github.com/kubernetes/kubernetes) 1.18.6
* [Docker](https://github.com/docker/docker-ce) 19.03.12
* [Containerd Runtime](https://github.com/containerd/containerd) 1.3.6
* [CNI Container Networking](https://github.com/containernetworking/cni) 0.8.0
* [Weave Networking](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/)
* [etcd](https://github.com/coreos/etcd) v3.4.10
* [CoreDNS](https://github.com/coredns/coredns) v1.7.0

## Labs

* [Prerequisites](docs/01-prerequisites.md)
* [Provisioning Compute Resources](docs/02-compute-resources.md)
* [Installing the Client Tools](docs/03-client-tools.md)
* [Provisioning the CA and Generating TLS Certificates](docs/04-certificate-authority.md)
* [Generating Kubernetes Configuration Files for Authentication](docs/05-kubernetes-configuration-files.md)
* [Generating the Data Encryption Config and Key](docs/06-data-encryption-keys.md)
* [Bootstrapping the etcd Cluster](docs/07-bootstrapping-etcd.md)
* [Bootstrapping the Kubernetes Control Plane - Manual Certificates](docs/08a-bootstrapping-kubernetes-controllers.md)
* [Bootstrapping the Kubernetes Control Plane - TLS](docs/08b-bootstrapping-kubernetes-controllers.md)
* [Bootstrapping the Kubernetes Worker Nodes](docs/09-bootstrapping-kubernetes-workers.md)
* [TLS Bootstrapping the Kubernetes Worker Nodes](docs/10-tls-bootstrapping-kubernetes-workers.md)
* [Configuring kubectl for Remote Access](docs/11-configuring-kubectl.md)
* [Deploy Weave - Pod Networking Solution](docs/12-configure-pod-networking.md)
* [Kube API Server to Kubelet Configuration](docs/13-kube-apiserver-to-kubelet.md)
* [Deploying the DNS Cluster Add-on](docs/14-dns-addon.md)
* [Smoke Test](docs/15-smoke-test.md)
* [E2E Test](docs/16-e2e-tests.md)
* [Extra - Dynamic Kubelet Configuration](docs/17-extra-dynamic-kubelet-configuration.md)
* [Extra - Certificate Verification](docs/verify-certificates.md)

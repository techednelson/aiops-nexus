# OpenSearch and Slack (Kubernetes Setup)

🚧 `Under construction`

To simplify setup and avoid installing [Microk8s](https://microk8s.io/)(lightweight [Kubernetes](https://kubernetes.io/) from [Canonical](https://canonical.com/)), [Helm](https://helm.sh/), [OpenSearch](https://opensearch.org/), and other tools manually, `Vagrant` and `VirtualBox` will be used to provision the required infrastructure and configuration, allowing the focus to remain on OpenSearch and alerting `AIOps Nexus`.

> 💡 **Note**
> 
> This `VirtualBox VM` will require a minimum of 2 CPUs and 6GB of available RAM to be able to run `Microk8s`, `Unhealthy App` and `AIOps Nexus`, in addition to the resources used by your personal computer.

1. [Install Vagrant](https://developer.hashicorp.com/vagrant/install)

2. [Install VirtualBox](https://www.virtualbox.org/wiki/Downloads)

3. Start VM

```bash
vagrant up
```

4. SSH into the VM [Ubuntu 22.04-LTS](https://ubuntu.com/)

```bash
vagrant ssh
```

5. Verify `Microk8s` is up and running

```bash
kubectl get nodes
```

6. Install helm charts and manifest files

```bash
sh /vagrant/scripts/install-apps.sh
```

7. Wait until all apps are up and running

```bash
kubectl -n app get pods
```

8. Access Opensearch Dashboards at [http://localhost:8080](http://localhost:8080) and enter `admin` and `Tr@ff!c89Light`.

<!-- That's All!!! -->
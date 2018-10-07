# Instana

[Instana](https://www.instana.com/) is a Dynamic APM for Microservice Applications

## Introduction

This chart adds the Instana Agent to all nodes in your cluster via a DaemonSet.

## Prerequisites for Helm
 
To use this, first install `helm` and tiller (the Kubernetes cluster-side tool helm talks to) using the standard documentation:

[https://docs.helm.sh/using_helm/#installing-helm](https://docs.helm.sh/using_helm/#installing-helm)

Install tiller to your cluster with 
```bash 
$ helm init
```

## Installing the Chart

To install the chart with the release name `instana-agent`, retrieve your instana agent key and run:

```bash
$ helm install . --name instana-agent --namespace instana-agent --set instana.agent.key=INSTANA_AGENT_KEY
```

Sometimes it is also necessary to set instana.agent.endpoint.host and instana.agent.endpoint.port. Check the [agent backend configuration in docs](https://docs.instana.io/quick_start/agent_configuration/#backend)

## Uninstalling the Chart

To uninstall/delete the `instana-agent` daemon set:

```bash
$ helm del --purge instana-agent
```

## Configuration

### Helm Chart

The following table lists the configurable parameters of the Instana chart and their default values.

|             Parameter         |            Description                                                  |                    Default                |
|-------------------------------|-------------------------------------------------------------------------|-------------------------------------------|
| `instana.agent.key`           | Your Instana Agent key                                                  | `Nil` You must provide your own key       |
| `image.name`                  | The image name to pull from                                             | `instana/agent`                           |
| `image.tag`                   | The image tag to pull                                                   | `latest`                                  |
| `image.pullPolicy`            | Image pull policy                                                       | `IfNotPresent`                            |
| `rbac.create`                 | True/False create & use RBAC resources                                  | `true`                                    |
| `instana.zone`                | Instana zone. It will be also used as cluster name and unique identifier| `k8s-cluster-name`                        |
| `instana.leaderElectorPort`   | Instana leader elector sidecar port                                     | `42655`                                   |
| `instana.agent.endpoint.host` | Instana agent backend endpoint host                                     | `saas-us-west-2.instana.io`               |
| `instana.agent.endpoint.port` | Instana agent backend endpoint port                                     | `443`                                     |
| `podAnnotations`              | Additional annotations to apply to the pod.                             | `{}`                                      |

### Agent

There is a [config map](templates/configmap.yaml) which you can edit to configure agent. This configuration will be used for all instana agents on all nodes.
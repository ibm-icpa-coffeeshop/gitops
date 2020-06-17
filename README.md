## Coffee Shop GitOps Repository

This is a GitOps repository representing a development environment for the Coffee Shop demo.  It represents a single source of truth for the environment, and can be used to deploy all of microservices that make up the demo.  For more information on the Coffee Shop scenario, see [Design and deliver an event-driven, cloud-native application at lightning speed](https://developer.ibm.com/tutorials/accelerator-for-event-driven-solutions/) and for more information on GitOps, see [Introduction to accelerators for cloud-native solutions](https://developer.ibm.com/articles/introduction-to-accelerators-for-cloud-native-solutions/). 

### Pre-requisites

This GitOps project assumes that the following already exists in your deployment **OpenShift** cluster:

* The base infrastructure found on the [infrastructure repo](https://github.com/ibm-icpa-coffeeshop/gitops-infrastructure).
* `oc create namespace coffeeshop`
* `oc apply -f environments/coffeeshop-dev/apps/coffeeshop/base/kafka/kafka.yaml`

### Manual deployment 
To deploy the application after completing the prerequisites above, issue the following command:

```
oc apply -k environments
```

### CI/CD with Tekton Pipelines

You can set up Tekton pipelines to build each microservice when changes are made, and to deploy the whole application. For more information, See the [pipelines repo](https://github.com/ibm-icpa-coffeeshop/pipelines)

Alternatively, you [use ArgoCD to deploy the application](argocd.md)

### Monitoring

For instructions on how to monitor the application, see the [infrastructure repo](https://github.com/ibm-icpa-coffeeshop/gitops-infrastructure).



## Coffee Shop GitOps Repository

This is a GitOps repository representing a development environment for the Coffee Shop demo.  It represents a single source of truth for the envioronment, and can be used to deploy all of microservices that make up the demo.  For more information on the Coffee Shop scenario, see [Design and deliver an event-driven, cloud-native application at lightning speed](https://developer.ibm.com/tutorials/accelerator-for-event-driven-solutions/) and for more information on GitOps, see [Introduction to accelerators for cloud-native solutions](https://developer.ibm.com/articles/introduction-to-accelerators-for-cloud-native-solutions/). 

### Pre-requisites

This GitOps project assumes that the following already exists in your deployment **OpenShift** cluster:

* The base infrastructure found on the [infrastructure repo](https://github.com/ibm-icpa-coffeeshop/gitops-infrastructure).
* `oc create namespace coffeeshop`
* `oc apply -f environments/coffeeshop-dev/apps/coffeeshop/base/kafka/kafka.yaml`

### Manual deployment 
To deploy the application after completing the prerequisitites above, issue the following command:

```
oc apply -k environments
```

### CI/CD with Tekton Pipelines

You can set up Tekton pipelines to build each microservice when changes are made, and to deploy the whole application. For more information, See the [pipeline repo](https://github.com/ibm-icpa-coffeeshop/pipeline)

### Monitoring

For instructions on how to monitor the application, see the [infrastructure repo](https://github.com/ibm-icpa-coffeeshop/gitops-infrastructure).


### GitOps with ArgoCD

As an alternative to using the Tekton pipelines, you can use ArgoCD to deploy the application.

**Installing ArgoCD**

This GitOps project has been tested using ArgoCD to deploy the project. The following steps show how to install ArgoCD using `helm` into your cluster.

* `helm repo add argo https://argoproj.github.io/argo-helm`

Helm 2:
* `helm install argo/argo-cd -n argocd --namespace argocd`

Helm 3:
* `oc create ns argocd`
* `helm install argocd argo/argo-cd --namespace argocd`

Then to access the ArgoCD web frontend UI run:

* `oc port-forward svc/argocd-server -n argocd 8081:443 `

This will make the ArgoCD UI available at [http://localhost:8081](http://localhost:8081)

You can then login to ArgoCD using the following credentials:

* Username:	`admin`
* Password:  name of the server pod (eg. `argocd-server-5f7ddc99f9-vlq7w`)

You can get the server pod name from `oc get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2`

**Creating a Repository entry for the GitOps project**

Once the UI is open, use the following steps to create a repository entry for the CoffeeShop Application's GitOps project:

1. Click on **Manage your repositories, projects and settings** in the left hand menu (the cogs icon)
2. Click on the **Repositories** menu item
3. Click on **CONNECT REPO USING SSH**
4. Provide a **Name** of `IBM GHE`
5. Provide a **Repository URL** of `git@github.ibm.com:appsody-coffeeshop/gitops.git`
6. Enter a SSH private key
7. Tick "Skip server verification" then click "Connect"

The following guide shows how to create a SSH key for you GitHub Account - note that you need to create a key with *no passphrase!*  
[https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh](https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)

**Creating an Application for the Coffee Shop GitOps project**

1. Click on **Manage your applications, and diagnose health problems** in the left hand menu (the layered stack icon)
2. Click on **NEW APP**
3. Provide an **Application Name** of `coffeeshop-dev`
4. Provide a **Project** of default
5. Provide a **Respository URL** of `git@github.ibm.com:appsody-coffeeshop/gitops.git`
6. Provide a **Path** of `coffeeshop/base`
7. Provide a **Cluster** of `in-cluster`
8. Provide a **Namespace** of default
9. Click on **Create**

**Deploying the Coffee Shop Application**

1. Click on the **SYNC** button on the **coffeeshop-dev** application tile.

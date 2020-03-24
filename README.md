## Coffee Shop GitOps Repository

### Pre-requisites

This GitOps project assumes that the following already exists in your deployment **OpenShift** cluster:

1. The Appsody Operator

* `appsody operator install --watch-all`

2. The `coffeeshop` namespaces

* `kubectl create ns coffeeshop`

3. The Strimzi Operator

* Navigate in the web console to the **Operators** → **OperatorHub** page.
* Type **Strimzi** into the **Filter by keyword** box.
* Select the Operator and click **Install**.
* On the **Create Operator Subscription** page:
    * Select **All namespaces on the cluster (default)**. This installs the operator in the default `openshift-operators` namespace to watch and be made available to all namespaces in the cluster.
    * Select **Automatic** or **Manual** approval strategy. If you choose Automatic, Operator Lifecycle Manager (OLM) automatically upgrades the operator as a new version is available.
* Click **Subscribe**.
* Select **Operators** → **Installed Operators** to verify that the Strimzi ClusterServiceVersion (CSV) eventually shows up and its Status changes to **InstallSucceeded** in the `openshift-operators` namespace.


4. The Kafka Cluster

* `kubectl apply -f apps/coffeeshop/base/kafka/kafka.yaml`

5. The Service Binding Operator

* Add a custom **OperatorSource**:

    ```console
    cat <<EOS |kubectl apply -f -
    ---
    apiVersion: operators.coreos.com/v1
    kind: OperatorSource
    metadata:
      name: redhat-developer-operators
      namespace: openshift-marketplace
    spec:
      type: appregistry
      endpoint: https://quay.io/cnr
      registryNamespace: redhat-developer
    EOS
    ```
    This step is needed as the operator is not officially released to the OperatorHub yet.

* Follow the same instructions for installing the Strimzi Operator described above except the following:
    * Type **Service Binding Operator** into the Filter by keyword box.

6. Monitoring

See the [monitoring repo](https://github.ibm.com/appsody-coffeeshop/gitops-monitoring)

### GitOps with Kustomize

* `kubectl apply -k env/overlays`

### GitOps with Tekton

See the [pipeline repo](https://github.ibm.com/appsody-coffeeshop/pipeline)

### GitOps with ArgoCD

**Installing ArgoCD**

This GitOps project has been tested using ArgoCD to deploy the project. The following steps show how to install ArgoCD using `helm` into your cluster.

* `helm repo add argo https://argoproj.github.io/argo-helm`

Helm 2:
* `helm install argo/argo-cd -n argocd --namespace argocd`

Helm 3:
* `kubectl create ns argocd`
* `helm install argocd argo/argo-cd --namespace argocd`

Then to access the ArgoCD web frontend UI run:

* `kubectl port-forward svc/argocd-server -n argocd 8081:443 `

This will make the ArgoCD UI available at [http://localhost:8081](http://localhost:8081)

You can then login to ArgoCD using the following credentials:

* Username:	`admin`
* Password:  name of the server pod (eg. `argocd-server-5f7ddc99f9-vlq7w`)

You can get the server pod name from `kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2`

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
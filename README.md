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

* `cd coffeeshop/base`
* `kubectl apply -f kafka.yaml`

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

6. Prometheus Operator (Optional)

* `kubectl create ns coffeeshop-monitoring`
* Navigate in the web console to the **Operators** → **OperatorHub** page.
* Type **Prometheus** into the **Filter by keyword** box.
* Select the Operator and click **Install**.
* On the **Create Operator Subscription** page:
    * Select **A specific namespace on the cluster** and select the `coffeeshop-monitoring` namespace
    * Select **Automatic** or **Manual** approval strategy. If you choose Automatic, Operator Lifecycle Manager (OLM) automatically upgrades the operator as a new version is available.
* Click **Subscribe**.
* In the `coffeeshop/base/metrics/prometheus-config-secret.yaml` file you will need to replace the value of `prometheus-additional-config.yaml` with the base64 encoded contents of the file with the same name. Use the following command to encode the file contents to replace the above values with:
   * `cat coffeeshop/base/metrics/prometheus-additional-config.yaml | base64 -w 0 > base64.txt`
   * The base64 encoded contents can then be found in the `base64.txt` file.
* `cd coffeeshop/base/metrics`
* `kubectl apply -f prometheus-config-secret.yaml`
* `kubectl apply -f prometheus.yaml`
* `kubectl apply -f prometheus-clusterroles.yaml`
* `kubectl apply -f strimzi-service-monitor.yaml`

7. Grafana Operator (Optional)

* Navigate in the web console to the **Operators** → **OperatorHub** page.
* Type **Grafana** into the **Filter by keyword** box.
* Select the Operator and click **Install**.
* On the **Create Operator Subscription** page:
    * Select **A specific namespace on the cluster** and select the `coffeeshop-monitoring` namespace
    * Select **Automatic** or **Manual** approval strategy. If you choose Automatic, Operator Lifecycle Manager (OLM) automatically upgrades the operator as a new version is available.
* Click **Subscribe**.
* `cd coffeeshop/base/metrics`
* `kubectl apply -f grafana.yaml`
* `kubectl apply -f grafana-dashboard.yaml`
* You can now view the dashboard.
   * On OpenShift go to 'Networking -> Routes' and select the `coffeeshop-monitoring` project.
   * There should be a `grafana-route`. Select the link to the dashboard location.
   * You should now see the 'Home Dashboard'.
   * On the top left of the screen, select the dashboard dropdown where it currently displays 'Home' and select `Coffeeshop-Metrics-Dashboard` to navigate to the coffeeshop scenario one.

### GitOps with Kustomize

* `cd overlays`
* `kubectl apply -k .`

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

### GitOps with Tekton on Openshift

**Pipelines**

1. Install the OpenShift Pipelines Operator from OperatorHub.
1. Create a personal access token on GitHub with the `public_repo` scope.
1. Update the `password` field in the `tekton/pipeline/git-secrets.yaml` file to the personal access token created in the previous step.
1. Deploy the pipeline components:
   * `kubectl create ns coffeeshop-pipelines`
   * `kubectl apply -f tekton/serviceaccount.yaml`
   * `kubectl apply -f tekton/pipeline/git-secrets.yaml`
   * `kubectl apply -f tekton/pipeline/pipeline-clusterroles.yaml`
   * `kubectl apply -f tekton/pipeline/task-deploy.yaml`
   * `kubectl apply -f tekton/pipeline/get-host.yaml`
   * `kubectl apply -f tekton/pipeline/get-tests.yaml`
   * `kubectl apply -f tekton/pipeline/pipeline-resources.yaml`
   * `kubectl apply -f tekton/pipeline/pipeline-deploy.yaml`
1. Now you can manually run the pipeline which will deploy your resources. (Currently you will also need to have deployed `tekton/triggers/git-secrets` otherwise the pipeline will fail)
   * `kubectl create -f tekton/pipeline/run-pipeline.yaml`

**Triggers**

1. In the `ingress.yaml` file, substitute `<INGRESS_ROUTER_HOSTNAME>` with the canonical hostname for the OpenShift ingress router. For example: `host: eventlistener.apps.mycluster.myorg.com`. This can be found by either:
   * using the OpenShift UI, find the `ROUTER_CANONICAL_HOSTNAME` environment variable defined in the `router-default` deployment in the `openshift-ingress` project,
   * via the command line as follows:  
   `oc describe deployment router-default -n openshift-ingress | grep HOSTNAME`
1. Update the `webhooksecret` field in the `tekton/trigger/git-secrets.yaml` file to a randomly generated secret.
1. Create webhook on GitHub, specifying:
   * "Payload URL" as `http://eventlistener.<HOST>:80` where host is the same as from the ingress file above.
   * "Secret" as the `webhooksecret` from `tekton/trigger/git-secrets.yaml`.
   * "Content-Type" as `application/json`.
   * In "Events" leave the "Just the push event" trigger option selected.
1. Deploy the trigger components:
   * `kubectl apply -f tekton/trigger/git-secrets.yaml`
   * `kubectl apply -f tekton/trigger/pipeline-roles.yaml`
   * `kubectl apply -f tekton/trigger/eventlistener.yaml`
   * `kubectl apply -f tekton/trigger/triggertemplate.yaml`
   * `kubectl apply -f tekton/trigger/triggerbindings.yaml`
   * `kubectl apply -f tekton/trigger/ingress.yaml`

**Dashboard**

1. Generate a password and enter the following in your command line `export PASSWORD=<password you created>`. The next script will use this variable to generate the certificate.
1. Create the certificate and key:  
`./tekton/dashboard/generate-tls-certs.sh`
1. In the `tekton/dashboard/tekton-dashboard-secret.yaml` file you will need to replace the `tls.crt` and `tls.key` values with the certificate and key that was generated from the previous script. Use the following commands to encode the files to replace the above values with:
   * `echo tekton/dashboard/tekton-key.pem | base64 -w 0`
   * `echo tekton/dashboard/tekton-cert.pem | base64 -w 0`
1. In the `ingress.yaml` file, substitute `INGRESS_ROUTER_HOSTNAME` with the canonical hostname for the OpenShift ingress router. For example: `host: tekton.dashboard.apps.mycluster.myorg.com`. This can be found by either:
   * using the OpenShift UI, find the `ROUTER_CANONICAL_HOSTNAME` environment variable defined in the `router-default` deployment in the `openshift-ingress` project,
   * via the command line as follows:  
   `oc describe deployment router-default -n openshift-ingress | grep HOSTNAME`
1. Deploy the dashboard components.
   * `kubectl create ns tekton-pipelines`
   * `kubectl apply -f https://github.com/tektoncd/dashboard/releases/download/v0.5.2/openshift-tekton-dashboard-release.yaml --validate=false`
   * `kubectl apply -f tekton/dashboard/tekton-dashboard-secret.yaml`
   * `kubectl apply -f tekton/dashboard/ingress.yaml` 
1. You can find the url for the dashboard in the `Routes` in the `tekton-pipelines` project.

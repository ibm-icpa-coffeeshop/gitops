## Coffee Shop GitOps Repository

### Pre-requisites

This GitOps project assumes that the following already exists in your deployment cluster:

1. The Appsody Operator

* `appsody operator install --watch-all`

2. The `kafka` and `coffeeshop` namespaces

* `kubectl create ns kafka`
* `kubectl create ns coffeeshop`

3. The Strimzi Operator

* `kubectl create ns strimzi`
* `helm repo add strimzi https://strimzi.io/charts`
* `helm install strimzi strimzi/strimzi-kafka-operator -n strimzi --set watchNamespaces={kafka} --wait --timeout 300s`

4. The Kafka Cluster

* `cd coffeeshop/base`
* `kubectl apply -f kafka.yaml`

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

### GitOps with Tekton

**Create a namespace to place all of your pipeline components in**
* `kubectl create ns coffeeshop-pipelines`

**Installing Tekton Pipeline and Tekton Triggers**

* `kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.10.1/release.yaml`
* `kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/previous/v0.3.0/release.yaml`

**Setup Authentication for the pipeline**

* In the `tekton/git-secrets.yaml` file, update the following fields:
  * `password` to a personal access token that you created on GitHub. The personal access token should specify the following scopes: `public_repo` , `read:repo_hook` and `write:repo_hook`.
  * `webhooksecret` with a randomly generated password.
* `kubectl apply -f tekton/authentication/git-secrets.yaml`
* `kubectl apply -f tekton/authentication/serviceaccount.yaml`
* `kubectl apply -f tekton/authentication/pipeline-clusterroles.yaml`
* `kubectl apply -f tekton/authentication/pipeline-roles.yaml`

**Deploy the pipeline components**

* `kubectl apply -f tekton/task-deploy.yaml`
* `kubectl apply -f tekton/pipeline-resources.yaml`
* `kubectl apply -f tekton/pipeline-deploy.yaml`

**Setup GitHub webhook and deploy triggers**

* `helm install my-nginx stable/nginx-ingress -n coffeeshop-pipelines`
* `kubectl apply -f tekton/webhook/ingress.yaml`
* Create webhook on GitHub, specifying the `Payload URL` to `http://<HOST>:80` where host is the same as from the ingress file above and `Secret` to the `webhooksecret` from the secret file.
* `kubectl apply -f tekton/webhook/eventlistener.yaml`
* `kubectl apply -f tekton/webhook/triggertemplate.yaml`
* `kubectl apply -f tekton/webhook/triggerbindings.yaml`

**Manually run the pipeline which will deploy your resources**

* `kubectl create -f tekton/run-pipeline.yaml` 

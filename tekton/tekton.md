# Tekton

## The pipeline

On a basic level, the pipeline consists of a `PipelineRun`, `Pipeline`, `PipelineResource` and `Task` resources.

The `PipelineRun` resource handles executing the pipeline with specific parameters and retains the logs for each run.

The `Pipeline` resource is the template/specification which the `PipelineRun` will use to execute. It will contain 1 or more tasks that you want to run and the `PipelineResource`s you need for the tasks.

The `PipelineResource` contains the input or task outputs which can be referenced between tasks.

Lastly, the `Task` resource contains the individual steps you want to execute in your pipeline.

### Authentication

To be able to deploy the services, the pipeline will need to clone the repository and this requires authentication.

Authentication for pipelines is handled by using `Service Accounts` that are linked to the necessary `Secret`, containing a specific annotation. There are several ways you can authenticate to a repository; this example uses a `Personal Access Token`.  
The annotation in the `Secret` references the repository you want to authenticate against, eg `https://github.com`. It is also possible to reference several repositories with the annotation as long as the credentials are the same across all of them.

The `Service Account` will then be referenced within the `PipelineRun` resource.

This specific scenario will also need certain cluster roles to be able to communicate with the appsodyapplication resource. These roles will be bound to the `Service Account` that is referenced for the `PipelineRun`.

## The triggers

To run the scenario end to end, Tekton triggers are used to listen to git events and decide which pipelines to deploy with what parameters.

A basic example of the trigger flow consists of an `EventListener`, `TriggerBinding` and `TriggerTemplate` resources.

You will also need to setup a webhook at your event source, eg GitHub which POSTs the events to your `EventListener` resource. This also requires for your `EventListener` to be exposed externally so GitHub can POST to it. This example uses an `Ingress` resource.

The `EventListener` resource references the `Service Account` that contains the secret for the webhook and will be used for role assignments within the namespace. The `EventListener` processes the incoming requests from the webhook and if required, filters the requests to kick of specific a `Pipeline` with specific `TriggerBinding`s.  
The `interceptor` within the `EventListener` will handle the filtering based on the request.

This example uses `CEL Interceptors` as this allows us to use different parameters or `Pipeline` depending on the git event, eg. different branches will run different `Pipeline`s. If you don't need to differentiate between branches or specific events, then you can use the `GitHub Interceptors`.

The `TriggerBinding` contains the parameters you want to use in your `Pipeline` or the values you want to parameterise from the request.

The `TriggerTemplate` contains the `PipelineRun` that you want to execute as a result of your trigger along with the parameters you need.

### Authentication

The `EventListener` will require several roles in the namespace to be able to function properly. As a base, it will need permissions to interact with each of the pipeline component resources as well as the configmaps and secrets.

## Resources
* Tekton Triggers: https://github.com/tektoncd/triggers/tree/master
* Tekton Pipelines: https://github.com/tektoncd/pipeline
* Tekton Authentication: https://github.com/tektoncd/pipeline/blob/master/docs/auth.md
# Tekton

## The pipeline

On a basic level, the pipeline consists of a `PipelineRun`, `Pipeline`, `PipelineResource` and `Task` resources.

The `PipelineRun` resource executes the pipeline with specific parameters and retains the logs for each run.

The `Pipeline` resource is the template/specification that the `PipelineRun` will use to execute. It will contain 1 or more tasks that you want to run and the `PipelineResources` you need for the tasks.

The `PipelineResource` contains the desired inputs or outputs from specific tasks which can be used in other tasks within the pipeline, e.g. one task outputs the location of a new image that another task down the line can consume.

Lastly, the `Task` resource contains the individual steps you want to execute in your pipeline.

### Authentication and Authorization

To deploy the application, the pipeline will clone the GitHub repository and this requires authentication.

Authentication for pipelines is handled by using `Service Accounts` that are linked to the necessary `Secrets`, containing a specific annotation. There are several ways you can authenticate to a repository; this scenario uses a `Personal Access Token`.  
The annotation in the `Secret` references the repository you want to authenticate against, eg `https://github.com`. It is also possible to reference several repositories with the annotation as long as the credentials are the same across all of them.

The `Service Account` will then be referenced within the `PipelineRun` resource.

Int his specific scenario, the pipeline needs certain cluster roles to be able to interact with the `AppsodyApplication` resource. These roles are bound to the `Service Account` that is referenced in the `PipelineRun`.

## The triggers

To run the scenario end to end, Tekton triggers are used to listen to GitHub events and decide which pipelines to deploy with what parameters.

A basic example of the trigger flow consists of `EventListener`, `TriggerBinding` and `TriggerTemplate` resources.

You will need to setup a webhook at your event source, e.g. GitHub which POSTs the events to your `EventListener`. This requires your `EventListener` to be exposed externally so GitHub can POST to it. This scenario uses an `Ingress` resource to achieve this.

The `EventListener` resource references the `Service Account` that contains the secret for the webhook and is used for role assignments within the namespace. The `EventListener` processes the incoming requests from the webhook and if required, filters the requests to start a specific `Pipeline` with specific `TriggerBindings`.  
The `interceptor` within the `EventListener` handles the filtering based on the request.

This scenario uses `CEL Interceptors` as this allows us to use different parameters or `Pipelines` depending on the GitHub event, eg. different branches will run different `Pipelines`. If you don't need to differentiate between branches or specific events, then you can use the `GitHub Interceptors`.

The `TriggerBinding` contains the parameters you want to use in your `Pipeline` or the values you want to parameterize from the GitHub event.

The `TriggerTemplate` contains the `PipelineRun` that you want to execute as a result of your trigger along with the parameters you need.

### Authentication and Authorization

The `EventListener` will require several roles in the namespace to be able to function properly. As a base, it will need permissions to interact with each of the pipeline component resources as well as the `Configmaps` and `Secrets`.

## Resources
* [Tekton Triggers](https://github.com/tektoncd/triggers/tree/master)
* [Tekton Pipelines](https://github.com/tektoncd/pipeline)
* [Tekton Authentication](https://github.com/tektoncd/pipeline/blob/master/docs/auth.md)
* [Tekton Event Interceptors](https://github.com/tektoncd/triggers/blob/master/docs/eventlisteners.md#Interceptors)
* [CEL Language Definition](https://github.com/google/cel-spec/blob/master/doc/langdef.md)
* [Tekton CEL Extensions](https://github.com/tektoncd/triggers/blob/master/docs/cel_expressions.md)
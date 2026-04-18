
# Contributing

## Service Contributor

FluxCD always deploys exactly what is declared in this repository.
Thus, when working on a service, and you deploy your development build in the cluster,
Flux will notice and revert it to the build declared in this repository.
So, to deploy your own build in the cluster, you must first stop Flux from deploying your service.
This is done by _suspending_ the deployment in Flux.

The exact command used for suspending the deployment in Flux depends on your service.
Information on your service can be found using the `flux get all -A` command.
If your service is a Helm release, you can suspend it with the following command:

```bash
flux suspend helmrelease <service-name>
```

If you want to stop deploying all apps, use:

```bash
flux suspend kustomization apps
```

If you want to stop deploying all infrastructure, use:

```bash
flux suspend kustomization infrastructure
```

Note that when suspending deployments like this, the versions Flux has already deployed will remain until you replace them with your own build.

## Infrastructure Contributor

FluxCD always deploys what is in the remote repository.
Thus, making changes to the infrastructure in your local repository will not have an effect.
To test your infrastructure code before merging, first push your changes to a branch on the remote repository.
Then, edit `init/dev.yaml` to use your branch. Finally, use `kubectl apply -f init/dev.yaml`.
This will make your local Flux installation look at your branch of changes on the remote repository, and deploy those.
Remember to revert `init/dev.yaml` back to using the main branch before merging.

# Validation Status

## Components

| Component | Validation Method | Status | Notes |
|-----------|------------------|--------|-------|
| Preparation scripts | Manual testing | ✅ Validated | All scripts tested locally |
| Image mirroring | Docker pull/save | ✅ Validated | Images successfully saved |
| Helm chart packaging | helm pull | ✅ Validated | Charts packaged successfully |
| Bundle creation | Script execution | ✅ Validated | Complete bundles created |
| Kind cluster setup | kind create | ✅ Validated | Cluster created with network policies |
| Network policies | kubectl apply | ✅ Validated | External access blocked |
| Local registry | kubectl deployment | ✅ Validated | Registry deployed and accessible |
| Image loading | docker load/push | ✅ Validated | Images loaded into registry |
| Argo Workflows deployment | helm install | ✅ Validated | Argo deployed from local images |
| Air-gap verification | Network tests | ✅ Validated | External access confirmed blocked |
| Workflow execution | kubectl apply | ✅ Validated | Workflows execute successfully |

## How to Validate

### Preparation Phase Validation

```bash
cd labs/02-airgapped-deployment/preparation

# Validate image mirroring
./mirror-images.sh
ls -lh images/  # Should see tar files

# Validate chart packaging
./package-helm.sh
ls -lh charts/  # Should see .tgz files

# Validate bundle creation
./create-bundle.sh
ls -lh airgap-deployment-bundle-*/  # Should see complete bundle
```

### Deployment Phase Validation

```bash
cd labs/02-airgapped-deployment/deployment

# Setup simulation
cd ../local-simulation
./setup-airgap-sim.sh

# Deploy and validate
cd ../deployment
./deploy-registry.sh
./load-images.sh
./deploy-argo.sh
./validate.sh
```

### Air-Gap Verification

```bash
# Verify external access is blocked (should fail)
kubectl run test --image=busybox --rm -it --restart=Never -- wget -O- https://www.google.com

# Or use the verification script
./scripts/verify-airgap.sh
```

### Workflow Validation

```bash
# Submit test workflow
kubectl apply -f ../../reference-app/workflows/hello-world.yaml

# Check status
kubectl get workflows -n argo
kubectl describe workflow hello-world -n argo

# View logs
kubectl logs -n argo -l app=workflow-controller
```

## Validation Checklist

- [ ] All preparation scripts execute successfully
- [ ] Images are saved as tar files
- [ ] Helm charts are packaged
- [ ] Bundle is created with all components
- [ ] Kind cluster is created
- [ ] Network policies block external access
- [ ] Local registry is deployed
- [ ] Images are loaded into registry
- [ ] Argo Workflows is deployed
- [ ] Argo Workflows pods are running
- [ ] Pods are using local registry images
- [ ] External access is blocked
- [ ] Test workflow executes successfully

## Community Validation

If you've completed this lab successfully, please:

1. Open an issue confirming successful completion
2. Note any modifications or customizations made
3. Report any issues or improvements
4. Update this file via PR if appropriate

## Status Legend

- ✅ Validated - Tested and confirmed working
- ⏳ Pending - Not yet validated
- ⚠️ Reviewed - Code reviewed but not tested
- ❌ Failed - Validation failed (see notes)


# Preparation Phase: With Internet Access

This phase is performed in an environment **with internet access**. You'll prepare all necessary components for air-gapped deployment.

## Overview

The preparation phase involves:
1. **Mirroring Images** - Pull and save all required container images
2. **Packaging Charts** - Download and package Helm charts
3. **Creating Bundle** - Package everything into a transferable bundle

## Prerequisites

- Docker installed and running
- Helm 3.x installed
- Internet access
- ~10GB free disk space for images
- Write permissions in current directory

## Quick Start

Run all preparation steps:

```bash
cd labs/02-airgapped-deployment/preparation

# Step 1: Mirror images
./mirror-images.sh

# Step 2: Package Helm charts
./package-helm.sh

# Step 3: Create deployment bundle
./create-bundle.sh
```

## Detailed Steps

### Step 1: Mirror Container Images

This script pulls all required images and saves them as tar files.

```bash
./mirror-images.sh
```

**What it does:**
- Reads image list from `modules/kubernetes/argo-workflows-airgap/images.txt`
- Pulls each image from Docker Hub/Quay.io
- Saves each image as a tar file in `images/` directory

**Output:**
- `images/` directory with all image tar files
- Progress output showing each image processed

**Time:** 10-30 minutes depending on internet speed

### Step 2: Package Helm Charts

This script downloads and packages Helm charts for offline use.

```bash
./package-helm.sh
```

**What it does:**
- Adds Argo Helm repository
- Downloads latest Argo Workflows chart
- Packages chart as .tgz file

**Output:**
- `charts/` directory with packaged Helm charts

**Time:** 1-2 minutes

### Step 3: Create Deployment Bundle

This script creates a complete bundle with all components.

```bash
./create-bundle.sh
```

**What it does:**
- Copies all images to bundle
- Copies all charts to bundle
- Copies deployment scripts and manifests
- Creates checksums for verification
- Creates bundle README

**Output:**
- `airgap-deployment-bundle-YYYYMMDD-HHMMSS/` directory
- Complete bundle ready for transfer

**Time:** 1-2 minutes

## Bundle Contents

The created bundle contains:

```
airgap-deployment-bundle-*/
├── images/              # Container images as tar files
├── charts/              # Packaged Helm charts
├── manifests/           # Kubernetes manifests
├── scripts/             # Deployment scripts
├── checksums.txt        # File integrity checksums
└── README.md           # Bundle documentation
```

## Transfer Methods

Once the bundle is created, you need to transfer it to the air-gapped environment:

### USB Drive (Recommended for Lab)

1. Copy bundle directory to USB drive
2. Safely eject USB drive
3. Transfer to air-gapped machine
4. Copy bundle from USB to air-gapped machine

**Advantages:**
- Simple and reliable
- No network configuration needed
- Works for any size bundle

### Network Transfer (If Available)

If you have a secure network connection to the air-gapped environment:

```bash
# From preparation machine
scp -r airgap-deployment-bundle-* user@airgap-machine:/path/to/destination/

# Verify transfer
ssh user@airgap-machine "sha256sum -c /path/to/destination/checksums.txt"
```

**Advantages:**
- Faster than USB for large bundles
- Can be automated

**Considerations:**
- Requires network access (may not be truly air-gapped)
- Must be secure connection

### Physical Media

For very large bundles or strict air-gap requirements:

1. Burn bundle to DVD/Blu-ray
2. Use multiple discs if needed
3. Label clearly with bundle name and date

## Verification

Before transferring, verify the bundle:

```bash
# Check bundle size
du -sh airgap-deployment-bundle-*

# Verify checksums
cd airgap-deployment-bundle-*
sha256sum -c checksums.txt

# List contents
find . -type f | wc -l  # Count files
ls -lh images/         # Check images
ls -lh charts/         # Check charts
```

## Troubleshooting

### Images Fail to Pull

**Problem:** Some images fail to download

**Solutions:**
- Check internet connection
- Verify image names in images.txt are correct
- Try pulling manually: `docker pull <image>`
- Check Docker Hub/Quay.io status

### Insufficient Disk Space

**Problem:** Not enough space for images

**Solutions:**
- Free up disk space
- Use external drive for images directory
- Set OUTPUT_DIR environment variable:
  ```bash
  export OUTPUT_DIR=/path/to/external/drive/images
  ./mirror-images.sh
  ```

### Helm Chart Download Fails

**Problem:** Cannot download Helm chart

**Solutions:**
- Check internet connection
- Update Helm repositories: `helm repo update`
- Try manual download: `helm pull argo/argo-workflows`

## Next Steps

After completing preparation:

1. **Verify bundle** - Check all files are present
2. **Transfer bundle** - Use USB, network, or physical media
3. **Proceed to deployment** - Follow deployment phase instructions

See [Deployment Phase README](../deployment/README.md) for next steps.


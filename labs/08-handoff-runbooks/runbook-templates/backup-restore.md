# Backup and Restore Procedures

**Application:** [Application Name]  
**Last Updated:** [Date]  
**Owner:** [Team/Contact]

## Overview

This guide provides procedures for backing up and restoring [Application Name] data and configuration.

## What to Backup

### Critical Data

- [ ] Application databases
- [ ] Configuration files
- [ ] Secrets
- [ ] Persistent volumes
- [ ] Application state

### Configuration

- [ ] Kubernetes manifests
- [ ] Helm values
- [ ] ConfigMaps
- [ ] Service definitions
- [ ] Ingress configurations

## Backup Procedures

### Database Backup

**PostgreSQL:**
```bash
# Create backup
kubectl exec -n [namespace-name] [postgres-pod-name] -- \
  pg_dump -U [username] [database-name] > backup-$(date +%Y%m%d-%H%M%S).sql

# Or use pg_dumpall for all databases
kubectl exec -n [namespace-name] [postgres-pod-name] -- \
  pg_dumpall -U [username] > backup-all-$(date +%Y%m%d-%H%M%S).sql
```

**MySQL:**
```bash
# Create backup
kubectl exec -n [namespace-name] [mysql-pod-name] -- \
  mysqldump -u [username] -p[password] [database-name] > backup-$(date +%Y%m%d-%H%M%S).sql
```

**Cloud SQL:**
```bash
# Export database
gcloud sql export sql [instance-name] gs://[bucket-name]/backup-$(date +%Y%m%d-%H%M%S).sql \
  --database=[database-name]
```

### Configuration Backup

**Export All Resources:**
```bash
# Export all resources in namespace
kubectl get all -n [namespace-name] -o yaml > backup-all-$(date +%Y%m%d-%H%M%S).yaml

# Export ConfigMaps
kubectl get configmap -n [namespace-name] -o yaml > backup-configmaps-$(date +%Y%m%d-%H%M%S).yaml

# Export Secrets (base64 encoded)
kubectl get secret -n [namespace-name] -o yaml > backup-secrets-$(date +%Y%m%d-%H%M%S).yaml

# Export PersistentVolumeClaims
kubectl get pvc -n [namespace-name] -o yaml > backup-pvc-$(date +%Y%m%d-%H%M%S).yaml
```

**Helm Release Backup:**
```bash
# Get current values
helm get values [release-name] -n [namespace-name] > backup-values-$(date +%Y%m%d-%H%M%S).yaml

# Export release
helm get all [release-name] -n [namespace-name] > backup-release-$(date +%Y%m%d-%H%M%S).yaml
```

### Persistent Volume Backup

**Using Velero (Recommended):**
```bash
# Install Velero (if not installed)
# See: https://velero.io/docs/

# Create backup
velero backup create [backup-name] \
  --include-namespaces [namespace-name] \
  --wait

# List backups
velero backup get
```

**Manual Volume Backup:**
```bash
# Create backup pod with volume access
kubectl run backup-pod --image=busybox --restart=Never \
  -n [namespace-name] \
  --overrides='
{
  "spec": {
    "containers": [{
      "name": "backup-pod",
      "image": "busybox",
      "command": ["tar", "czf", "/backup/data.tar.gz", "/data"],
      "volumeMounts": [{
        "name": "data",
        "mountPath": "/data"
      }, {
        "name": "backup",
        "mountPath": "/backup"
      }]
    }],
    "volumes": [{
      "name": "data",
      "persistentVolumeClaim": {
        "claimName": "[pvc-name]"
      }
    }, {
      "name": "backup",
      "emptyDir": {}
    }]
  }
}'

# Copy backup from pod
kubectl cp [namespace-name]/backup-pod:/backup/data.tar.gz ./backup-$(date +%Y%m%d-%H%M%S).tar.gz

# Cleanup
kubectl delete pod backup-pod -n [namespace-name]
```

## Backup Schedule

### Recommended Schedule

- **Database:** Daily (or per transaction volume)
- **Configuration:** Before any changes
- **Persistent Volumes:** Weekly (or per data change rate)
- **Full System:** Monthly

### Automated Backups

**CronJob Example:**
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: database-backup
  namespace: [namespace-name]
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:14
            command:
            - /bin/sh
            - -c
            - |
              pg_dump -U $DB_USER -h $DB_HOST $DB_NAME > /backup/backup-$(date +%Y%m%d).sql
              # Upload to storage
            env:
            - name: DB_USER
              valueFrom:
                secretKeyRef:
                  name: db-credentials
                  key: username
            - name: DB_HOST
              value: [database-host]
            - name: DB_NAME
              value: [database-name]
            volumeMounts:
            - name: backup
              mountPath: /backup
          volumes:
          - name: backup
            persistentVolumeClaim:
              claimName: backup-pvc
          restartPolicy: OnFailure
```

## Restore Procedures

### Database Restore

**PostgreSQL:**
```bash
# Restore from backup
kubectl exec -i -n [namespace-name] [postgres-pod-name] -- \
  psql -U [username] [database-name] < backup-YYYYMMDD-HHMMSS.sql

# Or restore all databases
kubectl exec -i -n [namespace-name] [postgres-pod-name] -- \
  psql -U [username] < backup-all-YYYYMMDD-HHMMSS.sql
```

**MySQL:**
```bash
# Restore from backup
kubectl exec -i -n [namespace-name] [mysql-pod-name] -- \
  mysql -u [username] -p[password] [database-name] < backup-YYYYMMDD-HHMMSS.sql
```

**Cloud SQL:**
```bash
# Import database
gcloud sql import sql [instance-name] gs://[bucket-name]/backup-YYYYMMDD-HHMMSS.sql \
  --database=[database-name]
```

### Configuration Restore

**Restore Resources:**
```bash
# Restore all resources
kubectl apply -f backup-all-YYYYMMDD-HHMMSS.yaml

# Or restore selectively
kubectl apply -f backup-configmaps-YYYYMMDD-HHMMSS.yaml
kubectl apply -f backup-secrets-YYYYMMDD-HHMMSS.yaml
```

**Helm Release Restore:**
```bash
# Restore from values
helm upgrade [release-name] [chart-path] \
  -f backup-values-YYYYMMDD-HHMMSS.yaml \
  --namespace [namespace-name]
```

### Persistent Volume Restore

**Using Velero:**
```bash
# Restore from backup
velero restore create [restore-name] \
  --from-backup [backup-name] \
  --wait

# Check restore status
velero restore get
```

**Manual Volume Restore:**
```bash
# Create restore pod
kubectl run restore-pod --image=busybox --restart=Never \
  -n [namespace-name] \
  --overrides='
{
  "spec": {
    "containers": [{
      "name": "restore-pod",
      "image": "busybox",
      "command": ["tar", "xzf", "/backup/data.tar.gz", "-C", "/data"],
      "volumeMounts": [{
        "name": "data",
        "mountPath": "/data"
      }, {
        "name": "backup",
        "mountPath": "/backup"
      }]
    }],
    "volumes": [{
      "name": "data",
      "persistentVolumeClaim": {
        "claimName": "[pvc-name]"
      }
    }, {
      "name": "backup",
      "hostPath": {
        "path": "/path/to/backup"
      }
    }]
  }
}'

# Wait for completion
kubectl wait --for=condition=complete pod/restore-pod -n [namespace-name]

# Cleanup
kubectl delete pod restore-pod -n [namespace-name]
```

## Disaster Recovery

### Full System Restore

**Step 1: Restore Infrastructure**
- Restore cluster (if needed)
- Restore namespaces
- Restore RBAC

**Step 2: Restore Configuration**
- Restore ConfigMaps
- Restore Secrets
- Restore Service definitions

**Step 3: Restore Data**
- Restore databases
- Restore persistent volumes
- Restore application state

**Step 4: Restore Applications**
- Deploy applications
- Verify functionality
- Test end-to-end

### Recovery Time Objectives (RTO)

- **Critical Systems:** < 1 hour
- **Important Systems:** < 4 hours
- **Standard Systems:** < 24 hours

### Recovery Point Objectives (RPO)

- **Critical Systems:** < 15 minutes
- **Important Systems:** < 1 hour
- **Standard Systems:** < 24 hours

## Backup Verification

### Regular Verification

- [ ] Backup files exist
- [ ] Backup files are not corrupted
- [ ] Backup files are recent
- [ ] Backup can be restored
- [ ] Test restore in non-production

### Backup Testing Schedule

- **Weekly:** Verify backup files exist
- **Monthly:** Test restore procedure
- **Quarterly:** Full disaster recovery drill

## Backup Storage

### Storage Locations

- **Local:** For quick access (not recommended for production)
- **Cloud Storage:** GCS, S3, Azure Blob (recommended)
- **Offsite:** For disaster recovery

### Retention Policy

- **Daily Backups:** 7 days
- **Weekly Backups:** 4 weeks
- **Monthly Backups:** 12 months
- **Yearly Backups:** 7 years

## Related Documentation

- [Deployment Runbook](./deployment-runbook.md)
- [Incident Response Playbook](./incident-response.md)
- [Upgrade Procedure](./upgrade-procedure.md)

---

**Remember:** Test your backups regularly. A backup that can't be restored is not a backup.


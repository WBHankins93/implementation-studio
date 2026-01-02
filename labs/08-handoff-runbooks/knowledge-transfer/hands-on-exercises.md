# Hands-On Exercises

**Application:** [Application Name]  
**Purpose:** Practice operational tasks in a safe environment

## Exercise Environment

### Prerequisites

- Access to training cluster
- `kubectl` configured
- Access to Grafana
- Access to application

### Safety

- All exercises use test/development environment
- No production data at risk
- Rollback procedures available
- Trainer supervision

## Exercise 1: System Exploration

**Objective:** Familiarize with the system and basic operations

**Duration:** 45 minutes

### Tasks

1. **Access Cluster**
   ```bash
   # Verify cluster access
   kubectl cluster-info
   
   # List all namespaces
   kubectl get namespaces
   ```

2. **Explore Application Namespace**
   ```bash
   # List all resources in namespace
   kubectl get all -n [namespace-name]
   
   # Get detailed information
   kubectl describe namespace [namespace-name]
   ```

3. **Examine Pods**
   ```bash
   # List pods
   kubectl get pods -n [namespace-name] -o wide
   
   # Describe a pod
   kubectl describe pod [pod-name] -n [namespace-name]
   
   # View pod logs
   kubectl logs [pod-name] -n [namespace-name]
   ```

4. **Examine Services**
   ```bash
   # List services
   kubectl get svc -n [namespace-name]
   
   # Describe a service
   kubectl describe svc [service-name] -n [namespace-name]
   
   # Get service endpoints
   kubectl get endpoints [service-name] -n [namespace-name]
   ```

5. **Examine Configuration**
   ```bash
   # List ConfigMaps
   kubectl get configmap -n [namespace-name]
   
   # View ConfigMap
   kubectl get configmap [config-name] -n [namespace-name] -o yaml
   
   # List Secrets
   kubectl get secret -n [namespace-name]
   ```

### Verification

- [ ] Can access cluster
- [ ] Can list resources
- [ ] Can view pod details
- [ ] Can view logs
- [ ] Understand resource relationships

## Exercise 2: Monitoring and Dashboards

**Objective:** Learn to monitor system health

**Duration:** 60 minutes

### Tasks

1. **Access Grafana**
   - Open Grafana URL
   - Login with credentials
   - Navigate dashboards

2. **Cluster Overview Dashboard**
   - Review cluster metrics
   - Identify CPU usage
   - Identify memory usage
   - Check pod status
   - Check node status

3. **Application Dashboard**
   - Review application metrics
   - Check request rates
   - Check error rates
   - Review response times

4. **Create Custom Query**
   - Access Prometheus
   - Write query for pod CPU usage
   - Write query for error rate
   - Create simple dashboard

5. **Review Alerts**
   - View active alerts
   - Understand alert conditions
   - Check alert history

### Verification

- [ ] Can access Grafana
- [ ] Can navigate dashboards
- [ ] Can interpret metrics
- [ ] Can create queries
- [ ] Understand alerts

## Exercise 3: Troubleshooting

**Objective:** Practice troubleshooting common issues

**Duration:** 60 minutes

### Scenario 1: Pod Not Starting

**Setup:** Trainer creates pod with configuration error

**Tasks:**
1. Identify pod issue
   ```bash
   kubectl get pods -n [namespace-name]
   kubectl describe pod [pod-name] -n [namespace-name]
   ```

2. Check events
   ```bash
   kubectl get events -n [namespace-name] --sort-by='.lastTimestamp'
   ```

3. Check logs
   ```bash
   kubectl logs [pod-name] -n [namespace-name]
   ```

4. Resolve issue
   - Identify root cause
   - Fix configuration
   - Verify pod starts

### Scenario 2: High CPU Usage

**Setup:** Trainer creates high CPU load

**Tasks:**
1. Identify high CPU usage
   ```bash
   kubectl top pods -n [namespace-name]
   ```

2. Investigate cause
   ```bash
   kubectl logs [pod-name] -n [namespace-name]
   kubectl exec [pod-name] -n [namespace-name] -- top
   ```

3. Resolve issue
   - Identify resource-intensive process
   - Scale deployment
   - Or optimize application

### Scenario 3: Application Errors

**Setup:** Trainer introduces application error

**Tasks:**
1. Identify errors
   - Check application logs
   - Check Grafana dashboards
   - Review error rates

2. Investigate
   - Analyze error messages
   - Check recent changes
   - Review configuration

3. Resolve
   - Fix configuration
   - Or rollback deployment

### Verification

- [ ] Can identify pod issues
- [ ] Can analyze logs
- [ ] Can resolve common issues
- [ ] Understand troubleshooting process

## Exercise 4: Deployment

**Objective:** Practice deployment procedures

**Duration:** 60 minutes

### Tasks

1. **Pre-Deployment Checklist**
   - Review deployment runbook
   - Verify cluster access
   - Check current deployment
   - Backup configuration

2. **Perform Deployment**
   ```bash
   # Update image
   kubectl set image deployment/[deployment-name] \
     [container-name]=[new-image]:[version] \
     -n [namespace-name]
   
   # Watch rollout
   kubectl rollout status deployment/[deployment-name] -n [namespace-name]
   ```

3. **Monitor Deployment**
   ```bash
   # Watch pods
   kubectl get pods -n [namespace-name] -w
   
   # Check logs
   kubectl logs -f deployment/[deployment-name] -n [namespace-name]
   ```

4. **Verify Deployment**
   - Check pod status
   - Test health endpoint
   - Verify functionality
   - Check metrics

5. **Practice Rollback**
   ```bash
   # Rollback deployment
   kubectl rollout undo deployment/[deployment-name] -n [namespace-name]
   
   # Verify rollback
   kubectl rollout status deployment/[deployment-name] -n [namespace-name]
   ```

### Verification

- [ ] Can perform deployment
- [ ] Can monitor rollout
- [ ] Can verify deployment
- [ ] Can rollback if needed

## Exercise 5: Scaling

**Objective:** Practice scaling operations

**Duration:** 45 minutes

### Tasks

1. **Monitor Current State**
   ```bash
   # Check current replicas
   kubectl get deployment [deployment-name] -n [namespace-name]
   
   # Check resource usage
   kubectl top pods -n [namespace-name]
   
   # Check metrics in Grafana
   ```

2. **Scale Up**
   ```bash
   # Scale deployment
   kubectl scale deployment/[deployment-name] --replicas=[count] -n [namespace-name]
   
   # Watch scaling
   kubectl get pods -n [namespace-name] -w
   ```

3. **Verify Scaling**
   - Check new pods are running
   - Verify load distribution
   - Check metrics

4. **Scale Down**
   ```bash
   # Scale down
   kubectl scale deployment/[deployment-name] --replicas=[count] -n [namespace-name]
   ```

5. **Configure Autoscaling** (Optional)
   ```bash
   # Create HPA
   kubectl apply -f hpa.yaml
   
   # Monitor HPA
   kubectl get hpa -n [namespace-name] -w
   ```

### Verification

- [ ] Can scale deployment
- [ ] Can verify scaling
- [ ] Understand autoscaling
- [ ] Can monitor scaling

## Exercise 6: Incident Response

**Objective:** Practice incident response procedures

**Duration:** 60 minutes

### Scenario: Pod Crash Loop

**Setup:** Trainer creates crash looping pod

### Tasks

1. **Detect Incident**
   - Check monitoring alerts
   - Review dashboards
   - Identify issue

2. **Triage**
   ```bash
   # Check pod status
   kubectl get pods -n [namespace-name]
   
   # Check pod events
   kubectl describe pod [pod-name] -n [namespace-name]
   
   # Check logs
   kubectl logs [pod-name] -n [namespace-name] --previous
   ```

3. **Investigate**
   - Analyze error messages
   - Check configuration
   - Review recent changes

4. **Resolve**
   - Fix configuration
   - Restart pod
   - Or rollback deployment

5. **Document**
   - Document incident
   - Document resolution
   - Update runbook if needed

### Verification

- [ ] Can detect incidents
- [ ] Can triage issues
- [ ] Can investigate root cause
- [ ] Can resolve incidents
- [ ] Can document incidents

## Exercise 7: Backup and Restore

**Objective:** Practice backup and restore procedures

**Duration:** 60 minutes

### Tasks

1. **Perform Backup**
   ```bash
   # Backup configuration
   kubectl get all -n [namespace-name] -o yaml > backup-$(date +%Y%m%d).yaml
   
   # Backup database (if applicable)
   kubectl exec -n [namespace-name] [db-pod] -- \
     pg_dump -U [user] [database] > backup-db-$(date +%Y%m%d).sql
   ```

2. **Verify Backup**
   - Check backup files exist
   - Verify backup file size
   - Test backup readability

3. **Simulate Data Loss**
   - Delete test resource
   - Or corrupt test data

4. **Perform Restore**
   ```bash
   # Restore configuration
   kubectl apply -f backup-YYYYMMDD.yaml
   
   # Restore database (if applicable)
   kubectl exec -i -n [namespace-name] [db-pod] -- \
     psql -U [user] [database] < backup-db-YYYYMMDD.sql
   ```

5. **Verify Restore**
   - Verify resources restored
   - Test functionality
   - Verify data integrity

### Verification

- [ ] Can perform backup
- [ ] Can verify backup
- [ ] Can perform restore
- [ ] Can verify restore

## Exercise 8: Upgrade

**Objective:** Practice upgrade procedures

**Duration:** 60 minutes

### Tasks

1. **Pre-Upgrade Preparation**
   - Review upgrade runbook
   - Backup current deployment
   - Review release notes
   - Check compatibility

2. **Perform Upgrade**
   ```bash
   # Upgrade deployment
   kubectl set image deployment/[deployment-name] \
     [container-name]=[new-image]:[new-version] \
     -n [namespace-name]
   
   # Watch rollout
   kubectl rollout status deployment/[deployment-name] -n [namespace-name]
   ```

3. **Monitor Upgrade**
   - Watch pods
   - Check logs
   - Monitor metrics

4. **Verify Upgrade**
   - Check pod status
   - Test functionality
   - Verify metrics

5. **Practice Rollback**
   ```bash
   # Rollback if needed
   kubectl rollout undo deployment/[deployment-name] -n [namespace-name]
   ```

### Verification

- [ ] Can perform upgrade
- [ ] Can monitor upgrade
- [ ] Can verify upgrade
- [ ] Can rollback if needed

## Exercise Completion

### Self-Assessment

After completing exercises, assess:

- [ ] Comfortable with basic operations
- [ ] Can monitor system health
- [ ] Can troubleshoot common issues
- [ ] Can perform deployments
- [ ] Can scale system
- [ ] Can respond to incidents
- [ ] Can backup and restore
- [ ] Can perform upgrades

### Areas for Improvement

Document areas needing more practice:

- [ ] List areas for improvement
- [ ] Schedule additional practice
- [ ] Review documentation
- [ ] Ask questions

---

**Remember:** Practice makes perfect. Repeat exercises until comfortable.


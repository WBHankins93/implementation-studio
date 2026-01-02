# Scenario 6: Certificate/TLS Problems

## Problem Description

Applications are failing with TLS/certificate errors. HTTPS connections are being rejected due to certificate validation failures.

## Symptoms

**What You'll Observe:**
- TLS handshake failures
- Certificate validation errors
- "certificate verify failed" errors
- HTTPS connections rejected
- Certificate expired warnings

**Example Errors:**
```
certificate verify failed
x509: certificate signed by unknown authority
certificate has expired
TLS handshake timeout
```

## Initial Observations

**Check Pod Status:**
```bash
kubectl get pods -A
```

**Check Pod Logs:**
```bash
kubectl logs [pod-name] -n [namespace]
```

**Check Ingress/TLS:**
```bash
kubectl get ingress -A
```

## Common Causes

1. **Expired Certificates:** Certificates past expiration date
2. **Invalid Certificates:** Certificates not properly signed
3. **Wrong CA:** Certificate signed by unknown authority
4. **Certificate Chain:** Incomplete certificate chain
5. **TLS Configuration:** Incorrect TLS configuration

## Investigation Checklist

- [ ] Check certificate expiration
- [ ] Verify certificate validity
- [ ] Check certificate chain
- [ ] Verify CA certificates
- [ ] Check TLS configuration
- [ ] Review error messages
- [ ] Test certificate manually

## Expected Learning Outcomes

After completing this scenario, you will:
- Know how to diagnose certificate issues
- Understand certificate validation
- Be able to check certificate expiration
- Know how to verify certificate chains
- Understand TLS configuration
- Know how to resolve certificate issues

## Next Steps

1. Run the simulation: `./simulate.sh`
2. Follow the diagnosis guide: `./diagnosis.md`
3. Apply the resolution: `./resolution.md`
4. Verify the fix works


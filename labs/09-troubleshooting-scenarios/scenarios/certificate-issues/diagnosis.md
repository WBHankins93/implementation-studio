# Diagnosing Certificate/TLS Issues

## Step 1: Observe the Symptoms

**Check Pod Logs:**
```bash
kubectl logs cert-test-pod -n cert-test
```

**Expected Output:**
```
curl: (60) SSL certificate problem: certificate has expired
More details here: https://curl.haxx.se/docs/sslcerts.html
```

**Key Observation:** Certificate has expired.

## Step 2: Test Certificate Manually

**Test Certificate with curl:**
```bash
kubectl exec cert-test-pod -n cert-test -- curl -v https://expired.badssl.com 2>&1 | grep -i certificate
```

**Expected Output:**
```
* SSL certificate problem: certificate has expired
```

**Observation:** Certificate validation is failing.

## Step 3: Check Certificate Details

**Inspect Certificate:**
```bash
kubectl exec cert-test-pod -n cert-test -- openssl s_client -connect expired.badssl.com:443 -servername expired.badssl.com < /dev/null 2>&1 | grep -A 5 "Verify return code"
```

**Expected Output:**
```
Verify return code: 10 (certificate has expired)
```

**Get Certificate Expiration:**
```bash
kubectl exec cert-test-pod -n cert-test -- openssl s_client -connect expired.badssl.com:443 -servername expired.badssl.com < /dev/null 2>&1 | openssl x509 -noout -dates
```

**Expected Output:**
```
notBefore=Apr 12 23:59:59 2015 GMT
notAfter=Apr 17 23:59:59 2015 GMT
```

**Observation:** Certificate expired in 2015.

## Step 4: Check Certificate Chain

**View Full Certificate Chain:**
```bash
kubectl exec cert-test-pod -n cert-test -- openssl s_client -connect expired.badssl.com:443 -servername expired.badssl.com < /dev/null 2>&1 | grep -A 10 "Certificate chain"
```

**Observation:** Check if certificate chain is complete.

## Step 5: Test with Different Validation

**Test with Certificate Validation Disabled (for testing only):**
```bash
kubectl exec cert-test-pod -n cert-test -- curl -k https://expired.badssl.com
```

**Expected:** Should work (but insecure - only for testing)

**Observation:** Connection works when validation is skipped, confirming certificate issue.

## Step 6: Confirm Root Cause

**Root Cause Identified:**
The certificate for `expired.badssl.com` has expired. This causes:
- TLS handshake to fail certificate validation
- HTTPS connections to be rejected
- Applications to fail when connecting to the service

## Diagnosis Summary

| Symptom | Observation | Root Cause |
|---------|------------|------------|
| Connection fails | Certificate validation error | Certificate expired |
| Error message | "certificate has expired" | Certificate past expiration |
| Certificate dates | Expired in 2015 | **Root cause: Expired certificate** |
| With -k flag | Connection works | Confirms certificate issue |

## Common Certificate Issues

1. **Expired Certificate:** Certificate past expiration date
2. **Invalid CA:** Certificate signed by unknown authority
3. **Wrong Domain:** Certificate for different domain
4. **Incomplete Chain:** Missing intermediate certificates
5. **Self-Signed:** Certificate not signed by trusted CA

## Next Steps

Proceed to [resolution.md](./resolution.md) to fix the issue.


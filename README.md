# Website: [Cloud Resume](https://cchinothai.com)

# Cloud Resume Challenge - Troubleshooting Documentation

## Project: Static Resume with Custom Domain & HTTPS

**Author:** Cody Chinothai  
**Date:** November 30, 2024  
**Stack:** S3, CloudFront, ACM, Route 53/Cloudflare DNS

PROJECT BOARD: https://www.notion.so/Cloud-Resume-Challenge-2bb62cf00b76806483cddae5b333f710

---

## Issue #1: ERR_SSL_VERSION_OR_CIPHER_MISMATCH

### Problem
After setting up CloudFront distribution with custom SSL certificate and DNS records, attempting to access `https://cchinothai.com` resulted in:

```
This site can't provide a secure connection
cchinothai.com uses an unsupported protocol.
ERR_SSL_VERSION_OR_CIPHER_MISMATCH
```

### Root Cause
CloudFront distribution was missing the **Alternate Domain Name (CNAME)** configuration. Even though:
- ACM certificate was validated and active
- DNS A record pointed to CloudFront distribution
- Custom SSL certificate was attached to CloudFront

CloudFront didn't know it should respond to requests for `cchinothai.com`.

read further documentation: https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html

### Solution
1. Navigate to CloudFront distribution in AWS Console
2. Go to **General** tab → **Settings** → **Edit**
3. Under **Alternate domain names (CNAMEs)**, add: `cchinothai.com`
4. Verify **Custom SSL certificate** shows the correct ACM certificate
5. Save changes
6. Wait 10-15 minutes for CloudFront deployment to complete

### Verification
```bash
# Test DNS resolution
nslookup cchinothai.com

# Access site
curl -I https://cchinothai.com
# Should return 200 OK with CloudFront headers
```

### Key Takeaway
**CloudFront CNAMEs are required** - the distribution must explicitly list which custom domains it should respond to, even if DNS and SSL certificates are correctly configured.

---

## Configuration Decisions Made

### Security Policy
**Choice:** TLSv1.2_2021 (AWS recommended)
- **Reason:** Supports modern TLS 1.2/1.3, blocks insecure TLS 1.0/1.1
- **Cost Impact:** None
- **Browser Support:** 99%+ of users

### HTTP Protocol Versions
**Choice:** Enabled HTTP/2 and HTTP/3
- **Reason:** Better performance, multiplexing, future-proofing
- **Cost Impact:** None
- **Benefits:** Faster page loads for end users

### IPv6
**Choice:** Enabled
- **Reason:** Future-proofing, better global accessibility
- **Cost Impact:** None
- **Trade-offs:** None - CloudFront handles dual-stack automatically

### DNS Provider
**Choice:** Cloudflare DNS (DNS-only mode, gray cloud)
- **Reason:** Keep it simple - CloudFront already provides CDN functionality
- **Configuration:** A record pointing to CloudFront distribution, proxying disabled
- **Alternative Considered:** Cloudflare proxy (orange cloud) - rejected due to unnecessary CDN stacking

---

## Architecture Overview

```
Browser Request (HTTPS)
    ↓
DNS Resolution (Cloudflare)
    ↓
CloudFront Distribution
    ├── Custom Domain: cchinothai.com
    ├── SSL/TLS: ACM Certificate (us-east-1)
    ├── Security Policy: TLSv1.2_2021
    └── HTTP Versions: HTTP/2, HTTP/3
    ↓
S3 Bucket (Static Website Hosting)
    ├── index.html
    ├── style.css
    └── script.js
```

---

## Checklist for Future Deployments

When setting up CloudFront with custom domain:

- [ ] Request ACM certificate in **us-east-1** region
- [ ] Validate ACM certificate (DNS or email validation)
- [ ] Create CloudFront distribution with S3 origin
- [ ] Configure CloudFront settings:
  - [ ] Add **Alternate Domain Names (CNAMEs)** ← *Critical step*
  - [ ] Select **Custom SSL Certificate**
  - [ ] Set Security Policy (TLSv1.2_2021 recommended)
  - [ ] Enable HTTP/2 and HTTP/3
  - [ ] Enable IPv6
  - [ ] Set Default Root Object: `index.html`
- [ ] Wait for CloudFront deployment (~15-20 min)
- [ ] Create DNS records pointing to CloudFront
- [ ] Test with both CloudFront URL and custom domain
- [ ] Verify HTTPS certificate in browser

---

## Common Pitfalls to Avoid

1. **ACM Certificate Region:** Must be in us-east-1 for CloudFront (global service requirement)
2. **Missing CNAMEs:** CloudFront won't respond to custom domain without explicit CNAME configuration
3. **Impatient Testing:** CloudFront changes take 15-20 minutes to propagate globally
4. **DNS Propagation:** Can take minutes to hours depending on TTL values
5. **Cloudflare Proxy:** Don't enable orange cloud when using CloudFront (creates CDN stack)

---

## Resources Used

- [AWS CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [AWS Certificate Manager](https://docs.aws.amazon.com/acm/)
- [Cloud Resume Challenge Guide](https://cloudresumechallenge.dev/)
- Claude.ai for troubleshooting and architectural guidance

---

## Next Steps

- [ ] Deploy Lambda function for visitor counter
- [ ] Set up DynamoDB table
- [ ] Create API Gateway endpoint
- [ ] Implement CI/CD pipeline with GitHub Actions
- [ ] Write Infrastructure as Code with Terraform
- [ ] Publish blog post documenting the journey

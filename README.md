# Cloud Resume Challenge

**Live Site:** [cchinothai.com](https://cchinothai.com)  
**Author:** Cody Chinothai  
**Project Board:** [Notion](https://www.notion.so/Cloud-Resume-Challenge-2bb62cf00b76806483cddae5b333f710)

---

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Frontend Setup](#frontend-setup)
- [Backend Setup](#backend-setup)
- [Terraform Configuration](#terraform-configuration)
- [Troubleshooting](#troubleshooting)

---

## Architecture Overview

```
Browser → CloudFront → S3 (Static Files)
             ↓
        API Gateway → Lambda → DynamoDB
```

**Tech Stack:**
- **Frontend:** HTML, CSS, JavaScript hosted on S3
- **CDN:** CloudFront with custom domain and HTTPS
- **DNS:** Cloudflare (DNS-only mode)
- **Backend:** Lambda (Python) + API Gateway + DynamoDB
- **IaC:** Terraform
- **CI/CD:** GitHub Actions (planned)

---

## Frontend Setup

### 1. Static Files
- `index.html` - Resume content
- `style.css` - Modern dark theme styling
- `script.js` - Visitor counter logic

### 2. S3 Bucket
- Private bucket (not publicly accessible)
- CloudFront Origin Access Control (OAC) for secure access
- Files uploaded via Terraform

### 3. CloudFront Distribution
- Custom domain: `cchinothai.com`
- HTTPS via ACM certificate (us-east-1 region)
- Security: TLSv1.2_2021
- Protocols: HTTP/2, HTTP/3 enabled
- IPv6 enabled

### 4. DNS Configuration
- Cloudflare A record pointing to CloudFront
- DNS-only mode (no proxy/orange cloud)

### Key Commands
```bash
# Deploy frontend
cd cloud-resume-frontend/terraform
terraform apply

# Invalidate CloudFront cache after updates
aws cloudfront create-invalidation \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths "/*"
```

---

## Backend Setup

### 1. DynamoDB Table
- **Table:** `resume-visitor-count`
- **Partition Key:** `visitor_count` (String)
- **Billing:** On-demand (pay-per-request)
- **Item Structure:**
  ```json
  {
    "visitor_count": "main",
    "count": 42
  }
  ```

### 2. Lambda Function
- **Runtime:** Python 3.11
- **Function:** Atomic counter increment using DynamoDB client API
- **Environment Variable:** `TABLE_NAME` (injected by Terraform)
- **IAM Permissions:** UpdateItem, GetItem on DynamoDB table

**Key Code Pattern:**
```python
response = dynamodb.update_item(
    TableName=table_name,
    Key={'visitor_count': {'S': 'main'}},
    UpdateExpression='ADD #count :inc',
    ExpressionAttributeNames={'#count': 'count'},
    ExpressionAttributeValues={':inc': {'N': '1'}},
    ReturnValues='ALL_NEW'
)
count = int(response['Attributes']['count']['N'])
```

### 3. API Gateway (REST API)
- **Endpoint:** `/count`
- **Method:** GET (public access)
- **CORS:** OPTIONS method for preflight
- **Integration:** AWS_PROXY to Lambda
- **Stage:** prod

### Test Backend
```bash
# Test API directly
curl https://YOUR_API_ID.execute-api.REGION.amazonaws.com/prod/count

# Expected response
{"count": 5}
```

---

## Terraform Configuration

### Project Structure
```
cloud-resume-frontend/
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── main.tf
│   └── outputs.tf
└── [index.html, style.css, script.js]

cloud-resume-backend/
├── lambda/
│   └── handler.py
├── tests/
│   └── test_handler.py
└── terraform/
    ├── provider.tf
    ├── variables.tf
    ├── dynamodb.tf
    ├── lambda.tf
    ├── api_gateway.tf
    └── outputs.tf
```

### Frontend Resources
- S3 bucket (private)
- CloudFront distribution with OAC
- S3 bucket policy (CloudFront access only)
- S3 objects (HTML/CSS/JS files)

### Backend Resources
- DynamoDB table
- Lambda function + IAM role/policy
- API Gateway REST API (11 resources total)
- Lambda permission for API Gateway invocation

### Deploy Commands
```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy
terraform apply

# View outputs (includes API URL)
terraform output
```

---

## Troubleshooting

### Issue 1: CloudFront SSL Error (ERR_SSL_VERSION_OR_CIPHER_MISMATCH)

**Problem:** HTTPS not working on custom domain

**Root Cause:** Missing Alternate Domain Name (CNAME) in CloudFront

**Solution:**
1. CloudFront → Distribution → General → Edit
2. Add `cchinothai.com` to "Alternate domain names (CNAMEs)"
3. Verify Custom SSL certificate is selected
4. Wait 15-20 minutes for deployment

**Reference:** [ACM DNS Validation Docs](https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html)

---

### Issue 2: Frontend Not Updating After Code Changes

**Problem:** `terraform apply` shows 0 changes even after modifying static files

**Root Cause 1:** Terraform not detecting file changes

**Solution:**
```bash
# Force replacement of specific file
terraform apply -replace="aws_s3_object.script_js"
```

**Root Cause 2:** CloudFront serving cached version

**Solution:**
```bash
# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id YOUR_DIST_ID \
  --paths "/*"
```

**Prevention:** Add automatic invalidation to Terraform (see `terraform_data` resource pattern)

---

### Issue 3: Lambda DynamoDB Validation Error

**Error:** `Invalid type for parameter Key.visitor_count`

**Root Cause:** Incorrect boto3 client API format

**Solution:** Use proper type descriptors:
```python
# Correct (client API)
Key={'visitor_count': {'S': 'main'}}  # S = String type
ExpressionAttributeValues={':inc': {'N': '1'}}  # N = Number (as string!)

# Wrong
Key={'visitor_count': 'main'}  # Missing type descriptor
```

**Note:** `count` is a DynamoDB reserved word - use `ExpressionAttributeNames`

---

### Issue 4: UpdateExpression Error - Attribute Name Not Defined

**Error:** `An expression attribute name used in the document path is not defined`

**Root Cause:** Missing `ExpressionAttributeNames` for reserved word `count`

**Solution:**
```python
UpdateExpression='ADD #count :inc',
ExpressionAttributeNames={'#count': 'count'},  # Required!
```

---

### Issue 5: Visitor Count Not Displaying on Frontend

**Problem:** Counter shows "Loading..." forever

**Root Cause:** Missing `await` on `response.json()`

**Solution:**
```javascript
// Wrong
const data = response.json();  // Returns Promise, not data

// Correct
const data = await response.json();  // Waits for data
```

---

### Common Pitfalls

1. **ACM Certificate Region:** Must be in `us-east-1` for CloudFront
2. **CloudFront Cache:** Always invalidate after updating S3 files
3. **CORS Headers:** Must be in both Lambda response AND API Gateway OPTIONS method
4. **DynamoDB Reserved Words:** Use ExpressionAttributeNames for words like `count`, `name`, `data`
5. **Terraform State:** Keep `.terraform/` and `*.tfstate` files out of Git

---

## Configuration Decisions

| Component | Choice | Reason |
|-----------|--------|--------|
| TLS Policy | TLSv1.2_2021 | Modern, secure, 99%+ browser support |
| HTTP Versions | HTTP/2, HTTP/3 | Better performance, no extra cost |
| IPv6 | Enabled | Future-proofing, better global reach |
| DNS | Cloudflare (gray cloud) | Simple, CloudFront handles CDN |
| DynamoDB Billing | On-demand | No fixed costs, perfect for low traffic |
| Lambda Memory | 128 MB | Sufficient for simple counter logic |
| API Gateway Type | REST API v1 | Better for learning, more examples available |

---

## Resources

- [AWS CloudFront Docs](https://docs.aws.amazon.com/cloudfront/)
- [AWS Certificate Manager](https://docs.aws.amazon.com/acm/)
- [Cloud Resume Challenge](https://cloudresumechallenge.dev/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [boto3 DynamoDB Docs](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html)

---

## Next Steps

- [ ] Write unit tests for Lambda function
- [ ] Set up CI/CD with GitHub Actions
- [ ] Add automated CloudFront invalidation
- [ ] Write blog post about the journey
- [ ] Implement monitoring/alerting
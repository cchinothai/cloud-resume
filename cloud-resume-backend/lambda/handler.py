"""
Function to perform the following
- accept an API Gateway Event
- Use boto3 to interact with DynamoDB
- Returns proper response with CORS headers

edge considerations
- what happens on first invocation when table is empty?
"""
import boto3
# API 





import json
import pytest
import boto3
from moto import mock_aws
import os
import sys

# Add lambda directory to path so we can import handler
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../lambda')))
from handler import lambda_handler

def create_test_table(dynamodb_client, table_name='test_table'):
    dynamodb_client.create_table(
        TableName='test-table',
        KeySchema=[{'AttributeName': 'visitor_count', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'visitor_count', 'AttributeType': 'S'}],
        BillingMode='PAY_PER_REQUEST'
    )   


# Test 1: Successful increment (happy path)
@mock_aws
def test_successful_increment():
    # Mock DynamoDB, create table, insert initial item
    os.environ['TABLE_NAME'] = 'test-table'
    dynamodb = boto3.client('dynamodb', region_name='us-east-1')
    create_test_table(dynamodb)

    # Put initial item with count = 6
    dynamodb.put_item(
        TableName='test-table',
        Item={
            'visitor_count': {'S': 'main'},
            'count': {'N': '6'}
        }
    )


    # Call lambda_handler
    event = {} #API Gateway event (empty for our use case)
    context = {} #Lambda context

    response = lambda_handler(event, context)

    # Assert response has statusCode 200, CORS headers are present, body is JSON string, value inc
    assert response['statusCode'] == 200

    assert 'Access-Control-Allow-Origin' in response['headers']
    assert response['headers']['Access-Control-Allow-Origin'] == '*'

    # TODO: Assert count incremented
    body = json.loads(response['body'])
    assert 'count' in body
    assert body['count'] == 7


# Test 2: DynamoDB table doesn't exist
@mock_aws
def test_table_does_not_exist():
    # Mock DynamoDB but DON'T create table
    os.environ['TABLE_NAME'] = 'test-table'
    dynamodb = boto3.client('dynamodb', region_name='us-east-1')

    # Call lambda_handler
    event = {} #API Gateway event (empty for our use case)
    context = {} #Lambda context

    response = lambda_handler(event, context)

    # Assert response has statusCode 500
    assert response['statusCode'] == 500

    # Assert error message in body
    body = json.loads(response['body'])
    assert 'error' in body



# Test 3: First visit (counter starts at 0)
@mock_aws
def test_first_visit_initialization():
    # Mock DynamoDB, create table, NO initial item
    os.environ['TABLE_NAME'] = 'test-table'
    dynamodb = boto3.client('dynamodb', region_name='us-east-1')
    create_test_table(dynamodb)

    # Call lambda_handler
    event = {} #API Gateway event (empty for our use case)
    context = {} #Lambda context

    response = lambda_handler(event, context)

    assert response['statusCode'] == 200

    # TODO: Assert count is 1 (DynamoDB ADD initializes to 0 then adds 1)
    body = json.loads(response['body'])
    assert 'count' in body
    assert body['count'] == 1
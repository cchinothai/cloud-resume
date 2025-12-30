"""
Function to perform the following
- accept an API Gateway Event
- Use boto3 to interact with DynamoDB
- read current visitor count and increment it 
- Update DynamoDB
- Returns proper response with CORS headers

edge considerations
- what happens on first invocation when table is empty?
"""
import boto3
import json
import os 
os.environ['AWS_DEFAULT_REGION'] = 'us-east-1' # add default region to run pytest in github actions

# API 

def lambda_handler(event, context):
    #test github action trigger on push ... 
    table_name = os.environ.get('TABLE_NAME')
    
    dynamodb = boto3.client('dynamodb')
    
    try:
        # TODO: Update item with atomic increment
        response = dynamodb.update_item(
            TableName=table_name,
            Key={
                'visitor_count': {'S' : 'main'}
            },
            UpdateExpression='ADD #count :inc',
            ExpressionAttributeNames={
                '#count': 'count'
            },
            ExpressionAttributeValues={
                ':inc': {'N' : '1'}
            },
            ReturnValues='ALL_NEW'
        )
        
        # TODO: Extract count from response
        count = int(response['Attributes']['count']['N'])

        print('count: ', count)
        
        # TODO: Return success response
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
                'Access-Control-Allow-Credentials': 'true'
            },
            'body': json.dumps({'count': count})
        }
    except Exception as e:
        # TODO: Return error response
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
                'Access-Control-Allow-Credentials': 'true'
            },
            'body': json.dumps({'error': 'Internal server error'})
        }





import json

def lambda_handler(event, context):
    print(" Starting Data Validation...")
    
   
    source = event.get('source', 'unknown')
    
    print(f" Checking data source: {source}")

  
    if source == 'gitlab-ci' or source == 'manual':
        return {
            'statusCode': 200,
            'body': json.dumps('Validation Passed'),
            'status': 'valid'  
        }
    else:
        
        return {
            'statusCode': 400,
            'body': json.dumps('Validation Failed'),
            'status': 'invalid'
        }
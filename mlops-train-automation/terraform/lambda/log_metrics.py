import json
import time
import random

def lambda_handler(event, context):
    print(" Logging metrics to system...")
    
    time.sleep(1)
    
    accuracy = round(random.uniform(0.90, 0.99), 2)
    loss = round(random.uniform(0.01, 0.10), 2)
    
    print(f" Training finished. Metrics: Accuracy={accuracy}, Loss={loss}")
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Metrics Logged Successfully',
            'accuracy': accuracy,
            'loss': loss
        })
    }
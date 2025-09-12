#!/bin/bash
echo "Creating SQS queue notifications-email..."
aws --endpoint-url=http://0.0.0.0:4566 sqs create-queue --queue-name notifications-email

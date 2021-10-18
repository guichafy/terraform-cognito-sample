# Commands

## Ziping
`zip ../lambda-settings-portal.zip main.js`


## Create Bucket
`aws s3 mb s3://lab-cognito-serverless`

## Uploading

` aws s3 cp lambda.zip s3://lab-cognito-serverless/v1.0.0/lambda-settings-portal.zip `


`aws lambda invoke --region=sa-east-1 --function-name=SettingsPortal output.txt`

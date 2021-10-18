resource "aws_api_gateway_rest_api" "lab-api-gateway" {
  name        = "LabApiGateway"
  description = "Terraform Serverless Application Example"
}


resource "aws_api_gateway_resource" "proxy" {
   rest_api_id = aws_api_gateway_rest_api.lab-api-gateway.id
   parent_id   = aws_api_gateway_rest_api.lab-api-gateway.root_resource_id
   path_part   = "config"
}


resource "aws_api_gateway_method" "proxy" {
   rest_api_id   = aws_api_gateway_rest_api.lab-api-gateway.id
   resource_id   = aws_api_gateway_resource.proxy.id
   http_method   = "GET"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.lab-api-gateway.id
   resource_id = aws_api_gateway_method.proxy.resource_id
   http_method = aws_api_gateway_method.proxy.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.lambda-settings.invoke_arn
}

# resource "aws_api_gateway_method" "proxy_root" {
#    rest_api_id   = aws_api_gateway_rest_api.lab-api-gateway.id
#    resource_id   = aws_api_gateway_rest_api.lab-api-gateway.root_resource_id
#    http_method   = "ANY"
#    authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "lambda_root" {
#    rest_api_id = aws_api_gateway_rest_api.lab-api-gateway.id
#    resource_id = aws_api_gateway_method.proxy_root.resource_id
#    http_method = aws_api_gateway_method.proxy_root.http_method

#    integration_http_method = "POST"
#    type                    = "AWS_PROXY"
#    uri                     = aws_lambda_function.lambda-settings.invoke_arn
# }


resource "aws_api_gateway_deployment" "example" {
   depends_on = [
     aws_api_gateway_integration.lambda,
   #   aws_api_gateway_integration.lambda_root,
   ]

   rest_api_id = aws_api_gateway_rest_api.lab-api-gateway.id
   stage_name  = "dev"
}

resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.lambda-settings.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.lab-api-gateway.execution_arn}/*/*"
}

resource "aws_ssm_parameter" "ssm-apigateawy" {
  name  = "/app/config/invoke-url-apigateway"
  type  = "String"
  value = aws_api_gateway_deployment.example.invoke_url
}


output "base_url" {
  value = aws_api_gateway_deployment.example.invoke_url
}




# CORS

resource "aws_api_gateway_resource" "cors" {
  rest_api_id = aws_api_gateway_rest_api.lab-api-gateway.id
  parent_id   = aws_api_gateway_rest_api.lab-api-gateway.root_resource_id
  path_part   = "{cors+}"
}

resource "aws_api_gateway_method" "cors" {
  rest_api_id   = aws_api_gateway_rest_api.lab-api-gateway.id
  resource_id   = aws_api_gateway_resource.cors.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors" {
  rest_api_id = aws_api_gateway_rest_api.lab-api-gateway.id
  resource_id = aws_api_gateway_resource.cors.id
  http_method = aws_api_gateway_method.cors.http_method
  type = "MOCK"
}

resource "aws_api_gateway_method_response" "cors" {
  depends_on = [aws_api_gateway_method.cors]
  rest_api_id = aws_api_gateway_rest_api.lab-api-gateway.id
  resource_id = aws_api_gateway_resource.cors.id
  http_method = aws_api_gateway_method.cors.http_method
  status_code = 200
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Headers" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "cors" {
  depends_on = [aws_api_gateway_integration.cors, aws_api_gateway_method_response.cors]
  rest_api_id = aws_api_gateway_rest_api.lab-api-gateway.id
  resource_id = aws_api_gateway_resource.cors.id
  http_method = aws_api_gateway_method.cors.http_method
  status_code = 200
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'", # replace with hostname of frontend (CloudFront)
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET, POST'" # remove or add HTTP methods as needed
  }
}
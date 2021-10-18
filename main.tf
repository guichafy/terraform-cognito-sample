provider "aws" {
    region = "sa-east-1"
}

resource "aws_cognito_user_pool" "lab_userPool" {
  name = "labPool"
  alias_attributes = [ "email" ]
  mfa_configuration = "OFF"
  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints {
      min_length = 7
      max_length = 320
    }
  }
  schema {
    name                     = "name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true 
    string_attribute_constraints {  
      min_length = 3                
      max_length = 100              
    }
  }
	auto_verified_attributes = [ "email"]
  account_recovery_setting {
  	recovery_mechanism {
    	name     = "verified_email"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_client" "client_cognito" {
  name = "client-web"

  user_pool_id = aws_cognito_user_pool.lab_userPool.id

  generate_secret     = false
  explicit_auth_flows = ["ALLOW_CUSTOM_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}

resource "aws_ssm_parameter" "cognitoUserPoolWebClientId" {
  name  = "/app/config/cognito/userPoolWebClientId"
  type  = "String"
  value = aws_cognito_user_pool_client.client_cognito.id
}

resource "aws_ssm_parameter" "cognitoUserPoolId" {
  name  = "/app/config/cognito/userPoolId"
  type  = "String"
  value = aws_cognito_user_pool.lab_userPool.id
}


resource "aws_ssm_parameter" "cognitoRegion" {
  name  = "/app/config/cognito/region"
  type  = "String"
  value = "sa-east-1"
}


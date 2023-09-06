module "django" {
  source                 = "./modules/django"
  lambda_function_name   = "djambda"
  lambda_handler         = "locallibrary.lgi.application"
  stage                  = "dev"
  aws_region             = var.aws_region
  create_lambda_function = true
  default_from_email     = var.default_from_email
  enable_api_gatewayv2   = true
}

output "api_gatewayv2_url" {
  value = module.django.this_invoke_url
}

output "createdb_result" {
  value = module.django.this_createdb
}

output "migrate_result" {
  value = module.django.this_migrate
}

# Djambda

Djambda is an example project setting up Django application in AWS Lambda managed by Terraform.

GitHub Actions create environments for [master branch](https://qpfbkrsucb.execute-api.eu-central-1.amazonaws.com/0/admin/) and [pull requests](https://qpfbkrsucb.execute-api.eu-central-1.amazonaws.com/3/admin/).

## Setup

### Github auth
* [Generate a personal access token](https://github.com/settings/tokens/new) in github. Check out the [docs](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) in case you need help. Remember to check `repo` ([repository public key](https://developer.github.com/v3/actions/secrets/#get-a-repository-public-key)) and `workflow` scopes.
* Create organization in github. As of time of writing terraform doesn't support setting secrets in individual user account. This may change when [this](https://github.com/terraform-providers/terraform-provider-github/pull/465) pr gets upstreamed.

### Terraform Cloud
* [Create a workspace](https://www.terraform.io/docs/cloud/getting-started/workspaces.html#creating-a-workspace).
* [Edit variables](https://www.terraform.io/docs/cloud/getting-started/workspaces.html#editing-variables):
  * Terraform Variables:
    * `aws_region`
    * `github_repository`
  * Environment Variables:
    * `AWS_ACCESS_KEY_ID`
    * `AWS_SECRET_ACCESS_KEY`
    * `AWS_DEFAULT_REGION`
    * `GITHUB_TOKEN`
    * `GITHUB_ORGANIZATION`
* Create [Terraform Cloud user API token](https://app.terraform.io/app/settings/tokens). You will need this later when setting up github repository.

### Github repository
* Fork this repo.
* Set `create_lambda_function` input in django module (`terraform/django.tf`) to `false`. This will prevent terraform from creating lambda related resources before building application.
* Set `organization` and `workspaces` in `terraform/main.tf`.
* Set `TF_API_TOKEN` repository secret.
* Re-run jobs.
* Set `create_lambda_function` input in django module (`terraform/django.tf`) to `true`.
* Re-run jobs.

## AWS resources

Terraform sets up following AWS resources:
* VPC with optional [endpoints](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-endpoints.html)
* Lambda with REST API Gateway
* RDS for PostgreSQL
* S3 bucket for static files behind CloudFront

## Related Projects
* [Zappa](https://github.com/Miserlou/Zappa)
* [chalice](https://github.com/aws/chalice)

## Costs

The default setup fits into Free Tier. It doesn't create NAT Gateways but you can set it up in `terraform/modules/django/vpc.tf`, it's a bit pricey though. You can read more about NAT Gateway Scenarios [here](https://github.com/terraform-aws-modules/terraform-aws-vpc#nat-gateway-scenarios). [NAT instance](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html) on t2.micro EC2 fits into Free Tier but it's more work to set it up and maintain. If you don't need internet access but want to connect to other AWS services you can always enable [Gateway VPC endpoints](https://docs.aws.amazon.com/vpc/latest/userguide/vpce-gateway.html) or [Interface VPC endpoints](https://docs.aws.amazon.com/vpc/latest/userguide/vpce-interface.html). Django tf module takes `enable_s3_endpoint`, `enable_dynamodb_endpoint` and `enable_ses_endpoint` variables, check out `terraform/modules/django/variables.tf`.

## TODO
* Remove db and staticfiles after lambda destroy
* Currently creating multiple django modules with the same lambda_function_name and stage is not supported. Add some random string to resource names when creating roles, policies, users, buckets and db to fix this issue.
* Document terraform.

module "s3_bucket_app" {
  source                 = "git::https://github.com/cloudposse/terraform-aws-s3-bucket.git"
  force_destroy          = true
  user_enabled           = true
  versioning_enabled     = true
  allowed_bucket_actions = ["s3:DeleteObject", "s3:GetObject", "s3:ListBucket", "s3:PutObject"]
  name                   = "app"
  stage                  = var.stage
  namespace              = var.lambda_function_name
}

data "aws_s3_bucket_objects" "dist" {
  bucket = module.s3_bucket_app.bucket_id
  prefix = "dist"
}

data "aws_s3_bucket_object" "manifest" {
  count = var.create_lambda_function ? 1 : 0
  bucket = module.s3_bucket_app.bucket_id
  key = "manifest.json"
}

locals {
  # jsondecode orders manifest
  dist_manifest = var.create_lambda_function ? jsondecode(data.aws_s3_bucket_object.manifest[0].body) : {}
}

module "staticfiles" {
  source                   = "git::https://github.com/quanganhquanganh/terraform-aws-cloudfront-s3-cdn.git"
  origin_force_destroy     = true
  namespace                = var.lambda_function_name
  stage                    = var.stage
  name                     = "static"
  block_public_acls        = false
  cors_allowed_headers     = ["*"]
  cors_allowed_methods     = ["GET", "HEAD", "PUT"]
  cors_allowed_origins     = ["*"]
  cors_expose_headers      = ["ETag"]
}

module "s3_user_staticfiles" {
  source       = "git::https://github.com/cloudposse/terraform-aws-iam-s3-user.git"
  namespace    = var.lambda_function_name
  stage        = var.stage
  name         = "s3_user_staticfiles"
  s3_actions   = [
    "s3:PutObject",
    "s3:GetObjectAcl",
    "s3:GetObject",
    "s3:ListBucket",
    "s3:DeleteObject",
    "s3:PutObjectAcl"
  ]
  s3_resources = [
    "arn:aws:s3:::${module.staticfiles.s3_bucket}/*",
    "arn:aws:s3:::${module.staticfiles.s3_bucket}"
  ]
}

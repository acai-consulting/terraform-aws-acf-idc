# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.47"
      configuration_aliases = []
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  resource_tags = merge(
    {
      "feature" = "AWS Identity Center Reporting Crawler"
    },
    var.resource_tags
  )
  settings = var.settings.security.reporting.identity_center
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LAMBDA
# ---------------------------------------------------------------------------------------------------------------------
module "icd_report" {
  /*  source  = "acai-consulting/lambda/aws"
  version = "1.1.0"*/
  source = "git::https://github.com/acai-consulting/terraform-aws-lambda.git?ref=fix_permission_policy_json_list"

  lambda_settings = {
    function_name = local.settings.crawler.lambda_name
    description   = local.settings.crawler.lambda_description
    handler       = "main.lambda_handler"
    config        = var.lambda_settings
    tracing_mode  = var.lambda_settings.tracing_mode
    environment_variables = {
      LOG_LEVEL          = var.lambda_settings.log_level
      CRAWLER_ARN        = local.settings.crawled_account.iam_role_arn
      REPORT_BUCKET_NAME = var.settings.security.reporting.bucket_name
    }
    package = {
      source_path = "${path.module}/lambda-files"
    }
  }
  execution_iam_role_settings = {
    new_iam_role = {
      name                        = local.settings.crawler.execution_iam_role_name
      path                        = local.settings.crawler.execution_iam_role_path
      permission_policy_json_list = [data.aws_iam_policy_document.lambda_policy.json]
    }
  }

  resource_tags = local.resource_tags
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ LAMBDA EXECUTION POLICY
# ---------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid    = "AllowAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [local.settings.crawled_account.iam_role_arn]
  }

  dynamic "statement" {
    for_each = var.settings.security.reporting.bucket_name != "" ? [1] : []

    content {
      sid    = "AllowS3"
      effect = "Allow"
      actions = [
        "s3:PutObject",
      ]
      resources = [
        format("arn:aws:s3:::%s/idc-reports/*", var.settings.security.reporting.bucket_name)
      ]
    }
  }
}

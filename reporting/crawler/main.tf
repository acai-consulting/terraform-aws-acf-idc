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
  source  = "acai-consulting/lambda/aws"
  version = "1.1.0"

  lambda_settings = {
    function_name = local.settings.crawler.lambda_name
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
      name = local.settings.crawler.execution_iam_role_name
      path = local.settings.crawler.execution_iam_role_path
    }
  }

  resource_tags = local.resource_tags
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ LAMBDA EXECUTION POLICY
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy" "lambda_policy" {
  name   = replace(module.icd_report.execution_iam_role.name, "role", "policy")
  role   = module.lambda.lambda_execution_role_name
  policy = data.aws_iam_policy_document.lambda_policy.json
}

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
        format("arn:aws:s3:::%s", var.settings.security.reporting.bucket_name),
        format("arn:aws:s3:::%s/*", var.settings.security.reporting.bucket_name),
      ]
    }
  }
}

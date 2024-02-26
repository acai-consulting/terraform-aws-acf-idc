# terraform-aws-acf-idc Terraform module

<!-- LOGO -->
<a href="https://acai.gmbh">    
  <img src="https://github.com/acai-consulting/acai.public/raw/main/logo/logo.png" alt="acai logo" title="ACAI" align="right" height="100" />
</a>

<!-- SHIELDS -->
[![Maintained by acai.gmbh][acai-shield]][acai-url]
[![Terraform Version][terraform-version-shield]][terraform-version-url]
[![Latest Release][release-shield]][release-url]

<!-- DESCRIPTION -->
[Terraform][terraform-url] module to deploy IAM Identity Center resources to enable Single-Sign-On on [AWS][aws-url] via an Identity Provider.

<!-- ARCHITECTURE -->
## Architecture
![idc architecture][architecture-png]

<!-- REQUIREMENTS -->
## Requirements
| :exclamation: Please ensure that the following requirements are met |
|-----------------------------------------|
- Enable AWS Organizations and add AWS Accounts.
- Enable IAM Identity Center (successor to AWS Single Sign-On).
- Create identities in IAM Identity Center (Users and Groups) or connect to an external identity provider. [documentation](https://docs.aws.amazon.com/singlesignon/latest/userguide/manage-your-identity-source-idp.html)
- Ensure that Terraform is using a role with permissions required for IAM Identity Center management.

<!-- DOCUMENTATION -->
## Managed policies and inline policies
When you need to set the permissions for an identity in IAM, you must decide whether to use an AWS managed policy, a customer managed policy, or an inline policy. The following documentation provide more information about each of the types of identity-based policies and when to use them. [documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html)

<!-- USAGE -->
## Usage
```hcl
locals {
  sso_permission_sets = [
    {
      name : "AdministratorAccess"
      description : "This permission set grants full admin access"
      session_duration : 2
      inline_policy_json : ""
      managed_policies : [
        {
          managed_by : "aws"
          policy_name : "AdministratorAccess"
          policy_path : "/"
        }
      ]
      boundary_policy : {}
    },
    {
      name : "Billing+ViewOnlyAccess"
      description : "This permission set grants billing and read-only access"
      session_duration : 10
      inline_policy_json : ""
      managed_policies : [
        {
          managed_by : "aws"
          policy_name : "Billing"
          policy_path : "/job-function/"
        },
        {
          managed_by : "aws"
          policy_name : "ViewOnlyAccess"
          policy_path : "/job-function/"
        }
      ]
      boundary_policy : {}
    },
    {
      name : "SupportUser"
      description : "This permission set grants access to support users"
      session_duration : 10
      inline_policy_json : ""
      managed_policies : [
        {
          managed_by : "aws"
          policy_name : "SupportUser"
          policy_path : "/job-function/"
        }
      ]
      boundary_policy : {}
    },
    {
      name : "CustomerPolicy"
      description : "This permission set grants reader access to S3"
      session_duration : 10
      inline_policy_json : ""
      managed_policies : [
        {
          managed_by : "customer"
          policy_name : "CustomerPolicy"
          policy_path : "/customer-path/"
        }
      ]
      boundary_policy : {}
    },
    {
      name : "InlineS3Reader"
      description : "This permission set grants reader access to S3"
      session_duration : 10
      inline_policy_json : data.aws_iam_policy_document.s3_reader.json
      managed_policies : []
      boundary_policy : {}
    }
  ]

  sso_account_assignments = [
    {
      account_id = "151251261561"
      permissions = [
        {
          permission_set_name = "AdministratorAccess"
          users               = ["user@example.com"]
          groups              = ["group-aws-admins"]
        }
      ]
    },
    {
      account_id = "6136161326123"
      permissions = [
        {
          permission_set_name = "AdministratorAccess"
          users               = ["admin@example.com"]
          groups              = []
        },
        {
          permission_set_name = "Billing+ViewOnlyAccess"
          users               = []
          groups              = ["group-aws-billing"]
        },
        {
          permission_set_name = "SupportUser"
          users               = []
          groups              = ["group-aws-supporter"]
        },
        {
          permission_set_name = "CustomerPolicy"
          users               = ["customer@example.com"]
          groups              = []
        },
        {
          permission_set_name = "InlineS3Reader"
          users               = []
          groups              = ["group-aws-s3reader"]
        }
      ]
    }
  ]
}

module "sso_identity_center" {
  source  = "app.terraform.io/acai-consulting/idc/aws"
  version = "~> 1.0"

  permission_sets     = local.sso_permission_sets
  account_assignments = local.sso_account_assignments
}
```

<!-- EXAMPLES -->
## Examples
* [`examples/complete`][sso-example-url]

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.47 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.47 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sso_account_assignments"></a> [sso\_account\_assignments](#module\_sso\_account\_assignments) | ./modules/account-assignment | n/a |
| <a name="module_sso_permission_sets"></a> [sso\_permission\_sets](#module\_sso\_permission\_sets) | ./modules/permission-set | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ssoadmin_instances.sso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_assignments"></a> [account\_assignments](#input\_account\_assignments) | A list of account assignments. | <pre>list(object({<br>    account_id = string,<br>    permissions = list(object({<br>      permission_set_name = string<br>      users               = list(string)<br>      groups              = list(string)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_permission_sets"></a> [permission\_sets](#input\_permission\_sets) | A list of permission sets. | <pre>list(object({<br>    name               = string<br>    description        = string<br>    session_duration   = number<br>    inline_policy_json = string<br>    managed_policies = list(object({<br>      managed_by  = string<br>      policy_name = string<br>      policy_path = string<br>    }))<br>    boundary_policy = map(object({<br>      managed_by  = string<br>      policy_name = string<br>      policy_path = string<br>    }))<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_identity_store_arn"></a> [identity\_store\_arn](#output\_identity\_store\_arn) | The Amazon Resource Name (ARN) of the SSO Instance. |
| <a name="output_identity_store_id"></a> [identity\_store\_id](#output\_identity\_store\_id) | Identity Store ID associated with the Single Sign-On Instance. |
| <a name="output_sso_group_assignments"></a> [sso\_group\_assignments](#output\_sso\_group\_assignments) | Map of group assignments with Single Sign-On. |
| <a name="output_sso_permission_sets"></a> [sso\_permission\_sets](#output\_sso\_permission\_sets) | Map of permission sets configured to be used with Single Sign-On. |
| <a name="output_sso_user_assignments"></a> [sso\_user\_assignments](#output\_sso\_user\_assignments) | Map of user assignments with Single Sign-On. |
<!-- END_TF_DOCS -->

<!-- AUTHORS -->
## Authors

This module is maintained by [ACAI GmbH][acai-url] with help from [these amazing contributors][contributors-url]

<!-- LICENSE -->
## License


<!-- COPYRIGHT -->
<br />
<br />
<p align="center">Copyright &copy; 2024 ACAI GmbH</p>

<!-- MARKDOWN LINKS & IMAGES -->
[acai-shield]: https://img.shields.io/badge/maintained_by-acai.gmbh-CB224B?style=flat
[acai-url]: https://acai.gmbh
[terraform-version-shield]: https://img.shields.io/badge/tf-%3E%3D1.3.10-blue.svg?style=flat&color=blueviolet
[terraform-version-url]: https://www.terraform.io/upgrade-guides/1-3-10.html
[release-shield]: https://img.shields.io/github/v/release/acai-consulting/terraform-aws-acf-ou-mgmt?style=flat&color=success
[architecture-png]: https://github.com/acai-consulting/terraform-aws-acf-ou-mgmt/blob/main/docs/architecture.png?raw=true
[release-url]: https://github.com/acai-consulting/terraform-aws-acf-ou-mgmt/releases
[contributors-url]: https://github.com/acai-consulting/terraform-aws-acf-ou-mgmt/graphs/contributors
[license-url]: https://github.com/acai-consulting/terraform-aws-acf-ou-mgmt/tree/main/LICENSE
[terraform-url]: https://www.terraform.io
[aws-url]: https://aws.amazon.comterraform-aws-acf-ou-mgmt/tree/main/examples/complete

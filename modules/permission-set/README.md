
# AWS IAM Identity Center (successor to AWS SSO) - Permission Set - Terraform submodule

<!-- LOGO -->
<a href="https://nuvibit.com">
    <img src="https://nuvibit.com/images/logo/logo-nuvibit-badge.png" alt="nuvibit logo" title="nuvibit" align="right" width="100" />
</a>

<!-- SHIELDS -->
[![Maintained by nuvibit.com][nuvibit-shield]][nuvibit-url]
[![Terraform Version][terraform-version-shield]][terraform-version-url]
[![Latest Release][release-shield]][release-url]

<!-- DESCRIPTION -->
[Terraform][terraform-url] submodule to deploy IAM Identity Center permission-set for Single Sign-On on [AWS][aws-url]

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
module "sso_permission_set" {
  source  = "app.terraform.io/nuvibit/sso/aws//modules/permission-set"
  version = "~> 1.0"

  name : "Billing+ViewOnlyAccess"
  description : ""
  session_duration : 2
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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssoadmin_customer_managed_policy_attachment.customer_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_customer_managed_policy_attachment) | resource |
| [aws_ssoadmin_managed_policy_attachment.aws_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.sso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_permission_set_inline_policy.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set_inline_policy) | resource |
| [aws_ssoadmin_permissions_boundary_attachment.boundary_aws_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permissions_boundary_attachment) | resource |
| [aws_ssoadmin_permissions_boundary_attachment.boundary_customer_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permissions_boundary_attachment) | resource |
| [aws_ssoadmin_instances.sso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the Permission Set. | `string` | n/a | yes |
| <a name="input_boundary_policy"></a> [boundary\_policy](#input\_boundary\_policy) | Boundary policy which should be attached to the Permission Set. Can either be an AWS-managed IAM policy or a customer managed policy. | <pre>map(object({<br>    managed_by  = string<br>    policy_name = string<br>    policy_path = string<br>  }))</pre> | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the Permission Set. | `string` | `""` | no |
| <a name="input_identity_store_arn"></a> [identity\_store\_arn](#input\_identity\_store\_arn) | The Identity Store ARN associated with the Single Sign-On Instance. If omitted the value will be requested by data source. | `string` | `""` | no |
| <a name="input_inline_policy_json"></a> [inline\_policy\_json](#input\_inline\_policy\_json) | IAM inline policy which will be attached to the Permission Set. Value must be a valid JSON. | `string` | `""` | no |
| <a name="input_managed_policies"></a> [managed\_policies](#input\_managed\_policies) | List of AWS or customer managed policies which will be attached to the Permission Set. | <pre>list(object({<br>    managed_by  = string<br>    policy_name = string<br>    policy_path = string<br>  }))</pre> | `[]` | no |
| <a name="input_session_duration"></a> [session\_duration](#input\_session\_duration) | The length of time (hours) that the application user sessions are valid. | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_identity_store_arn"></a> [identity\_store\_arn](#output\_identity\_store\_arn) | The Amazon Resource Name (ARN) of the SSO Instance. |
| <a name="output_permission_set"></a> [permission\_set](#output\_permission\_set) | Permission set configured to be used with AWS SSO. |
<!-- END_TF_DOCS -->

<!-- COPYRIGHT -->
<br />
<br />
<p align="center">Copyright &copy; 2023 Nuvibit AG</p>

<!-- MARKDOWN LINKS & IMAGES -->
[nuvibit-shield]: https://img.shields.io/badge/maintained%20by-nuvibit.com-%235849a6.svg?style=flat&color=1c83ba
[nuvibit-url]: https://nuvibit.com
[terraform-version-shield]: https://img.shields.io/badge/tf-%3E%3D0.15.0-blue.svg?style=flat&color=blueviolet
[terraform-version-url]: https://www.terraform.io/upgrade-guides/0-15.html
[release-shield]: https://img.shields.io/github/v/release/nuvibit/terraform-aws-sso?style=flat&color=success
[architecture-png]: https://github.com/nuvibit/terraform-aws-sso/blob/master/docs/architecture.png?raw=true
[release-url]: https://github.com/nuvibit/terraform-aws-sso/releases
[contributors-url]: https://github.com/nuvibit/terraform-aws-sso/graphs/contributors
[license-url]: https://github.com/nuvibit/terraform-aws-sso/tree/master/LICENSE
[terraform-url]: https://www.terraform.io
[aws-url]: https://aws.amazon.com
[sso-example-url]: https://github.com/nuvibit/terraform-aws-sso/tree/master/examples/complete

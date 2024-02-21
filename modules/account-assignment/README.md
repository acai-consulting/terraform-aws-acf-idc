
# AWS IAM Identity Center (successor to AWS SSO) - Account Assignment - Terraform submodule

<!-- LOGO -->
<a href="https://nuvibit.com">
    <img src="https://nuvibit.com/images/logo/logo-nuvibit-badge.png" alt="nuvibit logo" title="nuvibit" align="right" width="100" />
</a>

<!-- SHIELDS -->
[![Maintained by nuvibit.com][nuvibit-shield]][nuvibit-url]
[![Terraform Version][terraform-version-shield]][terraform-version-url]
[![Latest Release][release-shield]][release-url]

<!-- DESCRIPTION -->
[Terraform][terraform-url] submodule to deploy IAM Identity Center account assignments for Single Sign-On on [AWS][aws-url]

<!-- REQUIREMENTS -->
## Requirements
| :exclamation: Please ensure that the following requirements are met |
|-----------------------------------------|
- Enable AWS Organizations and add AWS Accounts.
- Enable IAM Identity Center (successor to AWS Single Sign-On).
- Create identities in IAM Identity Center (Users and Groups) or connect to an external identity provider. [documentation](https://docs.aws.amazon.com/singlesignon/latest/userguide/manage-your-identity-source-idp.html)
- Ensure that Terraform is using a role with permissions required for IAM Identity Center management.

<!-- USAGE -->
## Usage
```hcl
module "sso_account_assignment" {
  source  = "app.terraform.io/nuvibit/sso/aws//modules/account-assignment"
  version = "~> 1.0"

  account_id = "522512651611"
  permissions = [
    {
      permission_set_name = "AdministratorAccess"
      users               = ["admin@example.com"]
      groups              = ["group-aws-admins"]
    }
  ]
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
| [aws_ssoadmin_account_assignment.groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_account_assignment.users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_identitystore_group.sso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_identitystore_user.sso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_user) | data source |
| [aws_ssoadmin_instances.sso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |
| [aws_ssoadmin_permission_set.sso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_permission_set) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID to which permissions should be assigned. | `string` | n/a | yes |
| <a name="input_identity_store_arn"></a> [identity\_store\_arn](#input\_identity\_store\_arn) | The Identity Store ARN associated with the Single Sign-On Instance. If omitted the value will be requested by data source. | `string` | `""` | no |
| <a name="input_identity_store_id"></a> [identity\_store\_id](#input\_identity\_store\_id) | The Identity Store ID associated with the Single Sign-On Instance. If omitted the value will be requested by data source. | `string` | `""` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | List of Single Sign-On permissions for users and groups. | <pre>list(object({<br>    permission_set_name = string<br>    users               = list(string)<br>    groups              = list(string)<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | AWS account ID to which permissions should be assigned. |
| <a name="output_group_assignments"></a> [group\_assignments](#output\_group\_assignments) | Group assignments in AWS SSO. |
| <a name="output_identity_store_arn"></a> [identity\_store\_arn](#output\_identity\_store\_arn) | The Amazon Resource Name (ARN) of the SSO Instance. |
| <a name="output_identity_store_id"></a> [identity\_store\_id](#output\_identity\_store\_id) | Identity Store ID associated with the Single Sign-On Instance. |
| <a name="output_user_assignments"></a> [user\_assignments](#output\_user\_assignments) | User assignments in AWS SSO. |
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

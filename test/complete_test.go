package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestSSO(t *testing.T) {
	// retryable errors in terraform testing.
	t.Log("Starting SSO test")

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/complete",
		NoColor: false,
		Lock: true,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	templateOutput := terraform.Output(t, terraformOptions, "template")

	t.Log(templateOutput)
	// Do testing. I.E check if your resources are deployed via AWS GO SDK

	terraform.Destroy(t, terraformOptions)
}

package test

import (
	"testing"
	"github.com/stretchr/testify/assert"
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

	testSuccess1Output := terraform.Output(t, terraformReadConfiguration, "test_success_1")

	t.Log(testSuccess1Output)
	// Assert that 'test_success_1' equals "true"
	assert.Equal(t, "true", testSuccess1Output, "The test_success_1 output is not true")

	terraform.Destroy(t, terraformOptions)
}

package test

import (
	"testing"
	"github.com/stretchr/testify/assert"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestIdC(t *testing.T) {
	// retryable errors in terraform testing.
	t.Log("Starting ACF AWS IcD Module test")

	terraformTest := &terraform.Options{
		TerraformDir: "../examples/complete",
		NoColor: false,
		Lock: true,
	}

	defer terraform.Destroy(t, terraformTest)
	terraform.InitAndApply(t, terraformTest)

	testSuccess1Output := terraform.Output(t, terraformTest, "test_success_1")

	t.Log(testSuccess1Output)
	// Assert that 'test_success_1' equals "true"
	assert.Equal(t, "true", testSuccess1Output, "The test_success_1 output is not true")

	terraform.Destroy(t, terraformTest)
}

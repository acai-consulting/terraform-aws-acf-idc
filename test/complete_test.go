package test

import (
	"testing"
	"time" // Import the time package
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

	// Schedule the Terraform destroy to run after this function completes
	defer func() {
		t.Log("Waiting 4 minutes before destroy...")
		time.Sleep(4 * time.Minute) // Wait for 3 minutes
		terraform.Destroy(t, terraformTest)
	}()
	
	terraform.InitAndApply(t, terraformTest)

	testSuccess1Output := terraform.Output(t, terraformTest, "test_success_1")
	t.Log(testSuccess1Output)
	// Assert that 'test_success_1' equals "true"
	assert.Equal(t, "true", testSuccess1Output, "The test_success_1 output is not true")

	testSuccess2Output := terraform.Output(t, terraformTest, "test_success_2")
	t.Log(testSuccess2Output)
	// Assert that 'test_success_2' equals "true"
	assert.Equal(t, "true", testSuccess2Output, "The test_success_2 output is not true")
}

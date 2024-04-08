package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestIdC(t *testing.T) {
	// retryable errors in terraform testing.
	t.Log("Starting ACF AWS IcD Module test")

	terraformIdC := &terraform.Options{
		TerraformDir: "../examples/identity-center",
		NoColor:      false,
		Lock:         true,
	}

	defer terraform.Destroy(t, terraformIdC)
	terraform.InitAndApply(t, terraformIdC)

	testSuccess1Output := terraform.Output(t, terraformIdC, "test_success_1")
	t.Log(testSuccess1Output)
	// Assert that 'test_success_1' equals "true"
	assert.Equal(t, "true", testSuccess1Output, "The test_success_1 output is not true")

	testSuccess2Output := terraform.Output(t, terraformIdC, "test_success_2")
	t.Log(testSuccess2Output)
	// Assert that 'test_success_2' equals "true"
	assert.Equal(t, "true", testSuccess2Output, "The test_success_2 output is not true")

	terraformReporting := &terraform.Options{
		TerraformDir: "../examples/reporting",
		NoColor:      false,
		Lock:         true,
	}

	defer terraform.Destroy(t, terraformReporting)
	terraform.InitAndApply(t, terraformReporting)

	idcReportResult := terraform.OutputMap(t, terraformReporting, "idc_report_lambda_result")
	t.Log(idcReportResult)

	// Extract the statusCode and assert it
	statusCode := idcReportResult["statusCode"]
	// Print the status code
	t.Logf("Derived StatusCode: %s", statusCode)
	assert.Equal(t, "200", statusCode, "Expected statusCode to be 200")

	// Explicitly destroy the IdC infrastructure - mitigate: error waiting for SSO Permission Set (arn:aws:sso:::permissionSet/ssoins-6987eff4f8663f8f/ps-3b5018dbc2c1002c) to provision: unexpected state 'FAILED', wanted target 'SUCCEEDED'.
	terraform.Destroy(t, terraformIdC)
	time.Sleep(10 * time.Second) // Wait for 10 seconds
	terraform.Destroy(t, terraformIdC)

}

package test

import (
	"log"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestIdC(t *testing.T) {
	t.Log("Starting ACF AWS IcD Module test")

	terraformIdC := &terraform.Options{
		TerraformDir: "../examples/identity-center",
		NoColor:      false,
		Lock:         true,
	}

	// Initialize and apply Terraform configuration
	_, err := terraform.InitAndApplyE(t, terraformIdC)
	if err != nil {
		t.Fatalf("Failed to apply Terraform: %v", err)
	}

	testSuccess1Output := terraform.Output(t, terraformIdC, "test_success_1")
	assert.Equal(t, "true", testSuccess1Output, "The test_success_1 output is not true")

	testSuccess2Output := terraform.Output(t, terraformIdC, "test_success_2")
	assert.Equal(t, "true", testSuccess2Output, "The test_success_2 output is not true")

	terraformReporting := &terraform.Options{
		TerraformDir: "../examples/reporting",
		NoColor:      false,
		Lock:         true,
	}

	_, err = terraform.InitAndApplyE(t, terraformReporting)
	if err != nil {
		t.Fatalf("Failed to apply Terraform: %v", err)
	}

	idcReportResult := terraform.OutputMap(t, terraformReporting, "idc_report_lambda_result")
	statusCode := idcReportResult["statusCode"]
	assert.Equal(t, "200", statusCode, "Expected statusCode to be 200")

	// Try to explicitly destroy the IdC infrastructure and log error if it fails
	_, err = terraform.DestroyE(t, terraformIdC)
	if err != nil {
		log.Printf("Error during Terraform destroy: %v", err)
	}

	time.Sleep(10 * time.Second) // Wait for 10 seconds before trying again

	// Attempt to destroy again
	_, err = terraform.DestroyE(t, terraformIdC)
	if err != nil {
		log.Printf("Error during the second attempt of Terraform destroy: %v", err)
	}

	// Ensure reporting infrastructure is also destroyed at the end of the test
	defer func() {
		if _, err := terraform.DestroyE(t, terraformReporting); err != nil {
			log.Printf("Error during Terraform destroy for reporting: %v", err)
		}
	}()
}

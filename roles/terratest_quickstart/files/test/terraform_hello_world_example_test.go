package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestTerraformHelloWorldExample follows the Terratest quick-start pattern
// (https://terratest.gruntwork.io/docs/getting-started/quick-start).
func TestTerraformHelloWorldExample(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/terraform-hello-world-example",
	})

	defer terraform.DestroyContext(t, t.Context(), terraformOptions)

	terraform.InitAndApplyContext(t, t.Context(), terraformOptions)

	output := terraform.OutputContext(t, t.Context(), terraformOptions, "hello_world")
	assert.Equal(t, "Hello, World!", output)
}

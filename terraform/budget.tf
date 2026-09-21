# This does NOT replace the manual Budgets/Billing-alarm setup discussed
# earlier — set those up in the console once, independent of any one
# project. This is a project-scoped extra layer: an email the moment
# THIS test stack's spend crosses your threshold.

resource "aws_budgets_budget" "test_project" {
  count = var.enable_budget_alert ? 1 : 0

  name         = "${var.project_name}-budget"
  budget_type  = "COST"
  limit_amount = var.budget_limit_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }
}

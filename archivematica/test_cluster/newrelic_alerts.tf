resource "newrelic_alert_policy" "pv_usage" {
  name                = "dev-archivematica-pv-usage"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_nrql_alert_condition" "pv_usage_high" {
  account_id  = var.new_relic_account_id
  policy_id   = newrelic_alert_policy.pv_usage.id
  name        = "dev-archivematica-pv-usage-high"
  description = "Alert when a persistent volume in the dev/staging Archivematica cluster exceeds 90% capacity"
  enabled     = true

  nrql {
    query = "FROM K8sVolumeSample SELECT (average(fsUsedBytes) / average(fsCapacityBytes)) * 100 WHERE clusterName = '${module.eks.cluster_name}' FACET pvcName, namespaceName"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }

  fill_option        = "last_value"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay  = 120
}

resource "newrelic_notification_destination" "pv_usage_email" {
  name = "dev-archivematica-pv-usage-email"
  type = "EMAIL"

  property {
    key   = "email"
    value = var.alert_email
  }
}

resource "newrelic_notification_channel" "pv_usage_email" {
  name           = "dev-archivematica-pv-usage-email"
  type           = "EMAIL"
  destination_id = newrelic_notification_destination.pv_usage_email.id
  product        = "IINT"

  property {
    key   = "subject"
    value = "Persistent volume usage alert: dev/staging Archivematica cluster"
  }
}

resource "newrelic_workflow" "pv_usage" {
  name                  = "dev-archivematica-pv-usage"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "policy-filter"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [tostring(newrelic_alert_policy.pv_usage.id)]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.pv_usage_email.id
  }
}

resource "newrelic_alert_policy" "cluster" {
  count = var.cluster_policy ? 1 : 0

  name                = "cluster '${var.cluster_name}'"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_nrql_alert_condition" "cluster_does_not_response" {
  count = var.cluster_policy ? 1 : 0

  name                           = "Cluster doesn't response"
  title_template                 = "Cluster {{entity.name}} does not respond"
  policy_id                      = newrelic_alert_policy.cluster.0.id
  violation_time_limit_seconds   = 86400
  expiration_duration            = 300
  close_violations_on_expiration = true
  aggregation_method             = "event_timer"
  aggregation_timer              = 60

  nrql {
    query = "FROM K8sClusterSample SELECT count(clusterName) WHERE clusterName = '${var.cluster_name}' AND agentName != 'Infrastructure'"
  }

  critical {
    operator              = "below"
    threshold             = 1
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
}

resource "newrelic_nrql_alert_condition" "node_cpu_high" {
  count = var.cluster_policy ? 1 : 0

  name                           = "Node allocatable CPU utilization % is too high"
  title_template                 = "Node {{tags.nodeName}} CPU utilization % is too high"
  policy_id                      = newrelic_alert_policy.cluster.0.id
  violation_time_limit_seconds   = 86400
  expiration_duration            = 300
  close_violations_on_expiration = true
  aggregation_method             = "event_timer"
  aggregation_timer              = 60

  nrql {
    query = "FROM K8sNodeSample SELECT latest(allocatableCpuCoresUtilization) WHERE clusterName = '${var.cluster_name}' AND `label.one.newrelic.com/node-cpu-high-alert` != 'None' FACET nodeName"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 900
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 80
    threshold_duration    = 1800
    threshold_occurrences = "all"
  }
}

resource "newrelic_nrql_alert_condition" "node_memory_high" {
  count = var.cluster_policy ? 1 : 0

  name                           = "Node allocatable memory utilization % is too high"
  title_template                 = "Node {{tags.nodeName}} memory utilization % is too high"
  policy_id                      = newrelic_alert_policy.cluster.0.id
  violation_time_limit_seconds   = 86400
  expiration_duration            = 300
  close_violations_on_expiration = true
  aggregation_method             = "event_timer"
  aggregation_timer              = 60

  nrql {
    query = "FROM K8sNodeSample SELECT latest(allocatableMemoryUtilization) WHERE clusterName = '${var.cluster_name}' FACET nodeName"
  }

  critical {
    operator              = "above"
    threshold             = 95
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
}

resource "newrelic_nrql_alert_condition" "node_disk_high" {
  count = var.cluster_policy ? 1 : 0

  name                           = "Node disk % is too high"
  title_template                 = "Node {{tags.nodeName}} disk usage is too high"
  policy_id                      = newrelic_alert_policy.cluster.0.id
  violation_time_limit_seconds   = 86400
  expiration_duration            = 300
  close_violations_on_expiration = true
  aggregation_method             = "event_timer"
  aggregation_timer              = 60

  nrql {
    query = "FROM K8sNodeSample SELECT latest(fsCapacityUtilization) WHERE clusterName = '${var.cluster_name}' FACET nodeName"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
}

resource "newrelic_notification_channel" "email_cluster" {
  for_each = {
    for policy in newrelic_alert_policy.cluster : policy.name => policy if var.email_alert_recipient != null
  }

  name           = each.key
  type           = "EMAIL"
  destination_id = newrelic_notification_destination.email[0].id
  product        = "IINT"

  property {
    key   = "subject"
    value = "{{ issueTitle }}"
  }
}

resource "newrelic_notification_channel" "google_chat_cluster" {
  for_each = {
    for policy in newrelic_alert_policy.cluster : policy.name => policy if var.google_chat_alert_url != null
  }

  name           = each.key
  type           = "WEBHOOK"
  destination_id = newrelic_notification_destination.google_chat[0].id
  product        = "IINT" // (Workflows)

  property {
    key = "payload"
    value = jsonencode({
      "cards" : [
        {
          "sections" : [
            {
              "widgets" : [
                {
                  "keyValue" : {
                    "topLabel" : "NEW RELIC INCIDENT {{issueId}}",
                    "content" : "{{issueTitle}}",
                    "contentMultiline" : "true"
                    "onClick" : {
                      "openLink" : {
                        "url" : "{{issuePageUrl}}"
                      }
                    }
                  }
                }
              ]
            },
            {
              "widgets" : [
                {
                  "keyValue" : {
                    "content" : "{{#eq 'HIGH' priority}}WARNING{{else}}{{priority}}{{/eq}} - {{#if issueClosedAt}}closed{{else if issueAcknowledgedAt}}acknowledged{{else}}open{{/if}}",
                    "topLabel" : "Status"
                  }
                },
                {
                  "keyValue" : {
                    "content" : "{{accumulations.policyName.[0]}}",
                    "topLabel" : "Policy"
                  }
                },
                {
                  "keyValue" : {
                    "content" : "{{accumulations.conditionName.[0]}}",
                    "topLabel" : "Condition"
                  }
                }
              ]
            },
            {
              "widgets" : [
                {
                  "buttons" : [
                    {
                      "textButton" : {
                        "text" : "View Incident",
                        "onClick" : {
                          "openLink" : {
                            "url" : "{{issuePageUrl}}"
                          }
                        }
                      }
                    },
                    {
                      "textButton" : {
                        "text" : "Ack Incident",
                        "onClick" : {
                          "openLink" : {
                            "url" : "{{issueAckUrl}}"
                          }
                        }
                      }
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    })
    label = "Payload Template"
  }
}


resource "newrelic_workflow" "cluster" {
  for_each = {
    for policy in newrelic_alert_policy.cluster : policy.name => policy
  }

  name                  = each.value.name
  muting_rules_handling = "DONT_NOTIFY_FULLY_MUTED_ISSUES"

  issues_filter {
    name = each.value.name
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [each.value.id]
    }

    predicate {
      attribute = "priority"
      operator  = "EQUAL"
      values    = ["CRITICAL"]
    }
  }

  dynamic "destination" {
    for_each = newrelic_notification_channel.email_cluster
    content {
      channel_id = destination.value.id
    }
  }

  dynamic "destination" {
    for_each = newrelic_notification_channel.google_chat_cluster
    content {
      channel_id = destination.value.id
    }
  }
}

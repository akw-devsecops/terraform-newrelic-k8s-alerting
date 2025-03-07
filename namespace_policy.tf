resource "newrelic_alert_policy" "namespace" {
  count = length(var.namespaces) > 0 ? 1 : 0

  name                = "cluster '${var.cluster_name}' - namespaces '${join(", ", var.namespaces)}'"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

locals {
  joined_namespaces = join(", ", [for ns in var.namespaces : "'${ns}'"])
}

resource "newrelic_nrql_alert_condition" "container_cpu_high" {
  count = length(var.namespaces) > 0 ? 1 : 0

  name                           = "Container CPU usage % is too high"
  title_template                 = "Container {{tags.containerName}} in Pod {{tags.podName}} CPU utilization % is too high"
  policy_id                      = newrelic_alert_policy.namespace[0].id
  violation_time_limit_seconds   = 86400
  expiration_duration            = 300
  close_violations_on_expiration = true
  aggregation_method             = "event_timer"
  aggregation_timer              = 60

  nrql {
    query = "FROM K8sContainerSample SELECT average(cpuCoresUtilization) WHERE clusterName = '${var.cluster_name}' AND namespace IN (${local.joined_namespaces}) FACET namespace, podName, containerName"
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

resource "newrelic_nrql_alert_condition" "container_memory_high" {
  count = length(var.namespaces) > 0 ? 1 : 0

  name                           = "Container memory usage % is too high"
  title_template                 = "Container {{tags.containerName}} in Pod {{tags.podName}} memory utilization % is too high"
  policy_id                      = newrelic_alert_policy.namespace[0].id
  violation_time_limit_seconds   = 86400
  expiration_duration            = 300
  close_violations_on_expiration = true
  aggregation_method             = "event_timer"
  aggregation_timer              = 60

  nrql {
    query = "FROM K8sContainerSample SELECT average(memoryWorkingSetUtilization) WHERE clusterName = '${var.cluster_name}' AND namespace IN (${local.joined_namespaces}) FACET namespace, podName, containerName"
  }

  critical {
    operator              = "above"
    threshold             = 95
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 85
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
}

resource "newrelic_nrql_alert_condition" "pod_not_ready" {
  count = length(var.namespaces) > 0 ? 1 : 0

  name                           = "Pod is not ready"
  title_template                 = "Pod {{tags.podName}} is not ready"
  policy_id                      = newrelic_alert_policy.namespace[0].id
  violation_time_limit_seconds   = 86400
  expiration_duration            = 300
  close_violations_on_expiration = true
  aggregation_method             = "event_timer"
  aggregation_timer              = 60

  nrql {
    query = "FROM K8sPodSample SELECT latest(isReady) WHERE clusterName = '${var.cluster_name}' AND namespace IN (${local.joined_namespaces}) AND status != 'Succeeded' AND createdKind != 'Job' FACET namespace, podName"
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
}

resource "newrelic_nrql_alert_condition" "job_not_ready" {
  count = length(var.namespaces) > 0 && var.enable_job_alerting ? 1 : 0

  name                           = "Job is not ready"
  title_template                 = "Job {{tags.podName}} is not ready"
  policy_id                      = newrelic_alert_policy.namespace[0].id
  violation_time_limit_seconds   = 86400
  expiration_duration            = 300
  close_violations_on_expiration = true
  aggregation_method             = "event_timer"
  aggregation_timer              = 60

  nrql {
    query = "FROM K8sPodSample SELECT latest(isReady) WHERE clusterName = '${var.cluster_name}' AND namespace IN (${local.joined_namespaces}) AND status != 'Succeeded' AND createdKind = 'Job' FACET namespace, podName"
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
}

resource "newrelic_nrql_alert_condition" "container_out_of_space" {
  count = length(var.namespaces) > 0 ? 1 : 0

  name                           = "Container is running out of space"
  title_template                 = "Container {{tags.containerName}} in Pod {{tags.podName}} is running out of space"
  policy_id                      = newrelic_alert_policy.namespace[0].id
  violation_time_limit_seconds   = 86400
  expiration_duration            = 300
  close_violations_on_expiration = true
  aggregation_method             = "event_timer"
  aggregation_timer              = 60

  nrql {
    query = "FROM K8sContainerSample SELECT average(fsUsedPercent) WHERE clusterName = '${var.cluster_name}' AND namespace IN (${local.joined_namespaces}) FACET namespace, podName, containerName"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 75
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
}

resource "newrelic_nrql_alert_condition" "replicaset_not_desired_amount" {
  count = length(var.namespaces) > 0 ? 1 : 0

  name                           = "ReplicaSet doesn't have desired amount of pods"
  title_template                 = "ReplicaSet {{tags.replicasetName}} doesn't have desired amount of pods"
  policy_id                      = newrelic_alert_policy.namespace[0].id
  violation_time_limit_seconds   = 86400
  expiration_duration            = 300
  close_violations_on_expiration = true
  aggregation_method             = "event_timer"
  aggregation_timer              = 60

  nrql {
    query = "FROM K8sReplicasetSample SELECT latest(podsDesired - podsReady) WHERE clusterName = '${var.cluster_name}' AND namespace IN (${local.joined_namespaces}) FACET namespace, replicasetName"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
}

resource "newrelic_nrql_alert_condition" "volume_out_of_space" {
  count = length(var.namespaces) > 0 && var.enable_volume_alerting ? 1 : 0

  name                           = "PVC is running out of space"
  title_template                 = "PVC {{tags.pvcName}} is running out of space"
  policy_id                      = newrelic_alert_policy.namespace[0].id
  violation_time_limit_seconds   = 86400
  expiration_duration            = 300
  close_violations_on_expiration = true
  aggregation_method             = "event_timer"
  aggregation_timer              = 60
  fill_option                    = "last_value"

  nrql {
    query = "FROM Metric SELECT average(k8s.volume.fsUsedPercent) WHERE k8s.clusterName = '${var.cluster_name}' AND k8s.namespaceName IN (${local.joined_namespaces}) FACET k8s.pvcName"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 75
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
}

resource "newrelic_notification_channel" "email_namespace" {
  count = var.email_alert_recipient != null ? 1 : 0

  name           = var.channel_name
  type           = "EMAIL"
  destination_id = newrelic_notification_destination.email[0].id
  product        = "IINT"

  property {
    key   = "subject"
    value = "{{ issueTitle }}"
  }
}

resource "newrelic_notification_channel" "google_chat_namespace" {
  count = var.google_chat_alert_url != null ? 1 : 0

  name           = var.channel_name
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

resource "newrelic_workflow" "namespace" {
  count = length(var.namespaces) > 0 ? 1 : 0

  name                  = newrelic_alert_policy.namespace[0].name
  muting_rules_handling = "DONT_NOTIFY_FULLY_MUTED_ISSUES"

  issues_filter {
    name = newrelic_alert_policy.namespace[0].name
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [newrelic_alert_policy.namespace[0].id]
    }

    predicate {
      attribute = "priority"
      operator  = "EQUAL"
      values    = ["CRITICAL"]
    }
  }

  dynamic "destination" {
    for_each = {
      for destination in newrelic_notification_destination.email :
      destination.name => destination if var.email_alert_recipient != null
    }
    content {
      channel_id = newrelic_notification_channel.email_namespace[newrelic_alert_policy.namespace[0].name].id
    }
  }

  dynamic "destination" {
    for_each = {
      for destination in newrelic_notification_destination.google_chat :
      destination.name => destination if var.google_chat_alert_url != null
    }
    content {
      channel_id = newrelic_notification_channel.google_chat_namespace[newrelic_alert_policy.namespace[0].name].id
    }
  }
}

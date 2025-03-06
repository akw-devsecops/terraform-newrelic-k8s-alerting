# NewRelic K8s Alerting Module

Terraform module to set up Kubernetes alerting in NewRelic.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_newrelic"></a> [newrelic](#requirement\_newrelic) | >= 3.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_newrelic"></a> [newrelic](#provider\_newrelic) | >= 3.42.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [newrelic_alert_policy.cluster](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/alert_policy) | resource |
| [newrelic_alert_policy.namespace](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/alert_policy) | resource |
| [newrelic_notification_channel.email_cluster](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/notification_channel) | resource |
| [newrelic_notification_channel.email_namespace](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/notification_channel) | resource |
| [newrelic_notification_channel.google_chat_cluster](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/notification_channel) | resource |
| [newrelic_notification_channel.google_chat_namespace](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/notification_channel) | resource |
| [newrelic_notification_destination.email](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/notification_destination) | resource |
| [newrelic_notification_destination.google_chat](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/notification_destination) | resource |
| [newrelic_nrql_alert_condition.cluster_does_not_response](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/nrql_alert_condition) | resource |
| [newrelic_nrql_alert_condition.container_cpu_high](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/nrql_alert_condition) | resource |
| [newrelic_nrql_alert_condition.container_memory_high](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/nrql_alert_condition) | resource |
| [newrelic_nrql_alert_condition.container_out_of_space](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/nrql_alert_condition) | resource |
| [newrelic_nrql_alert_condition.job_not_ready](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/nrql_alert_condition) | resource |
| [newrelic_nrql_alert_condition.node_cpu_high](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/nrql_alert_condition) | resource |
| [newrelic_nrql_alert_condition.node_disk_high](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/nrql_alert_condition) | resource |
| [newrelic_nrql_alert_condition.node_memory_high](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/nrql_alert_condition) | resource |
| [newrelic_nrql_alert_condition.pod_not_ready](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/nrql_alert_condition) | resource |
| [newrelic_nrql_alert_condition.replicaset_not_desired_amount](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/nrql_alert_condition) | resource |
| [newrelic_nrql_alert_condition.volume_out_of_space](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/nrql_alert_condition) | resource |
| [newrelic_workflow.cluster](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/workflow) | resource |
| [newrelic_workflow.namespace](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/workflow) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the kubernetes cluster. | `string` | n/a | yes |
| <a name="input_channel_name"></a> [channel\_name](#input\_channel\_name) | Name of the alert channel | `string` | `null` | no |
| <a name="input_cluster_policy"></a> [cluster\_policy](#input\_cluster\_policy) | Set this to `false` if you don't want to create the cluster policy. | `bool` | `true` | no |
| <a name="input_email_alert_recipient"></a> [email\_alert\_recipient](#input\_email\_alert\_recipient) | The email alert address. | `string` | `null` | no |
| <a name="input_enable_job_alerting"></a> [enable\_job\_alerting](#input\_enable\_job\_alerting) | Determines whether to alert on job errors. | `bool` | `true` | no |
| <a name="input_enable_volume_alerting"></a> [enable\_volume\_alerting](#input\_enable\_volume\_alerting) | Determines whether to alert on volume usage. | `bool` | `true` | no |
| <a name="input_google_chat_alert_url"></a> [google\_chat\_alert\_url](#input\_google\_chat\_alert\_url) | The Google Chat alert channel webhook URL. | `string` | `null` | no |
| <a name="input_namespaces"></a> [namespaces](#input\_namespaces) | List of namespaces to be monitored. | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Docs

To update the docs just run
```shell
$ terraform-docs .
```
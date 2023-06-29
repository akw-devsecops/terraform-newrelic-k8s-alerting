resource "newrelic_notification_destination" "email" {
  count = ((var.email_alert_recipient != null) ? 1 : 0)

  name = var.channel_name
  type = "EMAIL"

  property {
    key   = "email"
    value = var.email_alert_recipient
  }
}

resource "newrelic_notification_destination" "google_chat" {
  count = ((var.google_chat_alert_url != null) ? 1 : 0)

  name = var.channel_name
  type = "WEBHOOK"

  property {
    key   = "url"
    value = var.google_chat_alert_url
  }
}

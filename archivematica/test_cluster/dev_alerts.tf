resource "aws_sns_topic" "dev_archivematica_alarm_topic" {
  name = "dev-archivematica-alarm"
}

resource "aws_sns_topic_subscription" "dev_archivematica_alarm_subscription" {
  topic_arn = aws_sns_topic.dev_archivematica_alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "dev_archivematica_pods" {
  alarm_name        = "dev-archivematica-running-pods"
  alarm_description = "Alert if the archivematica-dev namespace has fewer running pods than expected"

  namespace           = "ContainerInsights"
  metric_name         = "namespace_number_of_running_pods"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  comparison_operator = "LessThanThreshold"
  threshold           = 7

  dimensions = {
    ClusterName = local.cluster_name
    Namespace   = "archivematica-dev"
  }

  treat_missing_data = "breaching"

  alarm_actions = [aws_sns_topic.dev_archivematica_alarm_topic.arn]
  ok_actions    = [aws_sns_topic.dev_archivematica_alarm_topic.arn]
}

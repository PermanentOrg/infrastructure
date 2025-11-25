resource "aws_sns_topic" "prod_archivematica_alarm_topic" {
  name = "prod-archivematica-alarm"
}

resource "aws_sns_topic_subscription" "prod_archivematica_alarm_subscription" {
  topic_arn = aws_sns_topic.prod_archivematica_alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "prod_archivematica_pods" {
  alarm_name        = "prod-archivematica-running-pods"
  alarm_description = "Alert if the archivematica-prod namespace has fewer running pods than expected"

  namespace           = "ContainerInsights"
  metric_name         = "namespace_number_of_running_pods"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  comparison_operator = "LessThanThreshold"
  threshold           = 7

  dimensions = {
    ClusterName = local.cluster_name
    Namespace   = "archivematica-prod"
  }

  treat_missing_data = "breaching"

  alarm_actions = [aws_sns_topic.prod_archivematica_alarm_topic.arn]
  ok_actions    = [aws_sns_topic.prod_archivematica_alarm_topic.arn]
}

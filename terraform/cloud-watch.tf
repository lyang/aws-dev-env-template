resource "aws_cloudwatch_event_rule" "ec2-snapshot" {
  name                = "ebs-auto-snapshot"
  schedule_expression = "${var.ebs-snapshot-schedule}"
}

resource "aws_cloudwatch_event_target" "ec2-snapshot-lambda-target" {
  rule  = "${aws_cloudwatch_event_rule.ec2-snapshot.name}"
  arn   = "${aws_lambda_function.ec2-snapshot.arn}"
  input = "${jsonencode(local.ec2-snapshot-lambda-arguments)}"
}

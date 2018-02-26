resource "aws_lambda_function" "ec2-snapshot" {
  filename         = "${local.ec2-snapshot-lambda-archive-path}"
  function_name    = "ec2-snapshot"
  handler          = "ebs-snapshot-lambda.handle"
  role             = "${aws_iam_role.ec2-snapshot.arn}"
  runtime          = "python3.6"
  source_code_hash = "${data.archive_file.ec2-snapshot-lambda.output_base64sha256}"
  timeout          = 60
}

resource "aws_iam_role" "ec2-snapshot" {
  name               = "ec2-snapshots-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume-lambda-role-policy-document.json}"
}

resource "aws_iam_policy" "ec2-snapshot" {
  name   = "ec2-snapshot-policy"
  policy = "${data.aws_iam_policy_document.ec2-snapshot-policy-document.json}"
}

resource "aws_iam_role_policy_attachment" "ec2-snapshot" {
  role       = "${aws_iam_role.ec2-snapshot.name}"
  policy_arn = "${aws_iam_policy.ec2-snapshot.arn}"
}

resource "aws_iam_policy_attachment" "singlelog_policy_Attachment" {
  name       = "singlelog_policy_attachment"
  roles      = [aws_iam_role.singlestore_s3_role.name]
  policy_arn = aws_iam_policy.singlelog_s3_policy.arn
}
resource "aws_iam_role" "singlestore_s3_role" {
  name        = "singlestore_s3_write"
  description = "Allow Vector to write to s3"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "singlestore_s3_write"
  }
}

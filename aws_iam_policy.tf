resource "aws_iam_policy" "singlelog_s3_policy" {
  name        = "singlelog_s3_write"
  path        = "/"
  description = "Allow vector.dev to write to s3"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutAnalyticsConfiguration",
          "s3:PutAccessPointConfigurationForObjectLambda",
          "s3:GetObjectVersionTagging",
          "s3:DeleteAccessPoint",
          "s3:CreateBucket",
          "s3:DeleteAccessPointForObjectLambda",
          "s3:GetStorageLensConfigurationTagging",
          "s3:ReplicateObject",
          "s3:GetObjectAcl",
          "s3:GetBucketObjectLockConfiguration",
          "s3:DeleteBucketWebsite",
          "s3:GetIntelligentTieringConfiguration",
          "s3:PutLifecycleConfiguration",
          "s3:GetObjectVersionAcl",
          "s3:DeleteObject",
          "s3:CreateMultiRegionAccessPoint",
          "s3:GetBucketPolicyStatus",
          "s3:GetObjectRetention",
          "s3:GetBucketWebsite",
          "s3:GetJobTagging",
          "s3:GetMultiRegionAccessPoint",
          "s3:PutReplicationConfiguration",
          "s3:GetObjectAttributes",
          "s3:PutObjectLegalHold",
          "s3:InitiateReplication",
          "s3:GetObjectLegalHold",
          "s3:GetBucketNotification",
          "s3:PutBucketCORS",
          "s3:DescribeMultiRegionAccessPointOperation",
          "s3:GetReplicationConfiguration",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
          "s3:GetObject",
          "s3:PutBucketNotification",
          "s3:DescribeJob",
          "s3:PutBucketLogging",
          "s3:GetAnalyticsConfiguration",
          "s3:PutBucketObjectLockConfiguration",
          "s3:GetObjectVersionForReplication",
          "s3:GetAccessPointForObjectLambda",
          "s3:GetStorageLensDashboard",
          "s3:CreateAccessPoint",
          "s3:GetLifecycleConfiguration",
          "s3:GetInventoryConfiguration",
          "s3:GetBucketTagging",
          "s3:PutAccelerateConfiguration",
          "s3:GetAccessPointPolicyForObjectLambda",
          "s3:DeleteObjectVersion",
          "s3:GetBucketLogging",
          "s3:ListBucketVersions",
          "s3:RestoreObject",
          "s3:ListBucket",
          "s3:GetAccelerateConfiguration",
          "s3:GetObjectVersionAttributes",
          "s3:GetBucketPolicy",
          "s3:PutEncryptionConfiguration",
          "s3:GetEncryptionConfiguration",
          "s3:GetObjectVersionTorrent",
          "s3:AbortMultipartUpload",
          "s3:GetBucketRequestPayment",
          "s3:GetAccessPointPolicyStatus",
          "s3:UpdateJobPriority",
          "s3:GetObjectTagging",
          "s3:GetMetricsConfiguration",
          "s3:GetBucketOwnershipControls",
          "s3:DeleteBucket",
          "s3:PutBucketVersioning",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetMultiRegionAccessPointPolicyStatus",
          "s3:ListBucketMultipartUploads",
          "s3:PutIntelligentTieringConfiguration",
          "s3:GetMultiRegionAccessPointPolicy",
          "s3:GetAccessPointPolicyStatusForObjectLambda",
          "s3:PutMetricsConfiguration",
          "s3:PutBucketOwnershipControls",
          "s3:DeleteMultiRegionAccessPoint",
          "s3:UpdateJobStatus",
          "s3:GetBucketVersioning",
          "s3:GetBucketAcl",
          "s3:GetAccessPointConfigurationForObjectLambda",
          "s3:PutInventoryConfiguration",
          "s3:GetObjectTorrent",
          "s3:GetStorageLensConfiguration",
          "s3:DeleteStorageLensConfiguration",
          "s3:PutBucketWebsite",
          "s3:PutBucketRequestPayment",
          "s3:PutObjectRetention",
          "s3:CreateAccessPointForObjectLambda",
          "s3:GetBucketCORS",
          "s3:GetBucketLocation",
          "s3:GetAccessPointPolicy",
          "s3:ReplicateDelete",
          "s3:GetObjectVersion",
          "kms:GenerateDataKey"
        ],
        "Resource" : "*"
      }
    ]
  })

  tags = {
    Name = "singlelog_S3_write"
  }
}
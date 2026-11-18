resource "aws_s3_bucket_lifecycle_configuration" "staging" {
  bucket = "permanent-staging"

  rule {
    id     = "cleanup"
    status = "Enabled"
    filter {}

    expiration {
      expired_object_delete_marker = true
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

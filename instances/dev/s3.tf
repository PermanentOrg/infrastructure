resource "aws_s3_bucket_lifecycle_configuration" "local" {
  bucket = "permanent-local"

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

resource "aws_s3_bucket_lifecycle_configuration" "dev" {
  bucket = "permanent-dev"

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

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
}

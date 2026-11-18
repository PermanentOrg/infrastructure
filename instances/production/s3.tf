provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_s3_bucket_lifecycle_configuration" "prod" {
  bucket = "permanent-prod"

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
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "prod_replica" {
  provider = aws.us_east_1
  bucket   = "permanent-prod-r1"

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
      noncurrent_days = 30
    }
  }
}

# make s3 bucket named "st_user_fluentbit_dev_directs3"
resource "aws_s3_bucket" "st_user_fluentbit_dev_directs3" {
  bucket = "st-user-fluentbit-dev-directs3"
}

# make s3 bucket ownership control
resource "aws_s3_bucket_ownership_controls" "st_user_fluentbit_dev_directs3_ownership_control" {
  bucket = aws_s3_bucket.st_user_fluentbit_dev_directs3.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# make s3 bucket named "st_user_fluentbit_dev_build_artifacts"
resource "aws_s3_bucket" "st_user_fluentbit_dev_build_artifacts" {
  bucket = "st-user-fluentbit-dev-build-artifacts"
}
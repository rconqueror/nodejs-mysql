resource "aws_s3_bucket" "tf_s3_bucket" {
  bucket = "nodejs-bucket-vc-demo"
  tags = {
    Name        = "Nodejs Terraform S3 bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "tf_s3_object" {
  bucket = aws_s3_bucket.tf_s3_bucket.bucket
  for_each = fileset("../public/images", "**")
  key    = "images/${each.key}"
  source = "../public/images/${each.key}"
}
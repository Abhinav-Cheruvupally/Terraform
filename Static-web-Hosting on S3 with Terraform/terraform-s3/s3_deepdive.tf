provider "aws"{
    region="us-west-2"
    profile = "default"
    shared_credentials_file= "E:/terraform/.aws/credential"
}


resource "aws_s3_bucket" "s3-web" {
  bucket = "abhinav160119991"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "s3-obj" {
  bucket = "abhinav160119991"
  key    = "index.html"
  source = "E:/terraform/bin/index.html"
  content_type = "text/html"
  acl = "public-read"
}

resource "aws_s3_bucket_object" "s3-obj2" {
  bucket = "abhinav160119991"
  key    = "error.html"
  source = "E:/terraform/bin/error.html"
  content_type = "text/html"
  acl="public-read"
}
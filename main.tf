provider "aws" {
  region = "us-west-1"
}

resource "aws_kms_key" "master" {
  description             = "Master KMS Key"
  deletion_window_in_days = 10
}


resource "aws_s3_bucket" "terraform_backend" {
  bucket = "tiger-terraform-backend"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.master.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
}


resource "aws_dynamodb_table" "terraform-backend-locks" {
  name           = "TerraformLocks"
  read_capacity  = 1 
  write_capacity = 1
  hash_key       = "LockId"

  attribute {
    name = "LockId"
    type = "S"
  }
}

terraform{
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "5.95.0"
        }
    }
}

//  HERE WE SET THE CLOUD PROVIDER

provider "aws" {
    region = ""
    access_key = ""
    secret_key = ""
}

// CREATING BUCKET

resource "aws_s3_bucket" "bhusawal-bucket" {
    bucket = aws_s3_bucket.bhusawal-bucket.id
    versioning_configuration{
        status = "Enabled"
    }
}

resource "aws_s3_bucket_website_configuration" "static_website_hosting" {
    bucket = aws_s3_bucket.bhusawal-bucket.id
    index_document {
        suffix = "index.html"
    }

    error_document {
        key = "error.html"
    }
}
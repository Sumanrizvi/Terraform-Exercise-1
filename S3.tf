resource "aws_s3_bucket" "snakegame-bucket" {
    bucket = "Suman-SnakeGame"

    versioning {
        enabled = true
    }

    lifecycle_rule {
        id      = "lifecyclerule2"
        enabled = true

        transition {
            days          = 30
            storage_class = "STANDARD_IA"
        }

        transition {
             days          = 60
            storage_class = "GLACIER"
        }
    }
}

resource "aws_s3_bucket_object" "snakegame-object" {
    bucket = aws_s3_bucket.snakegame-bucket.id
    key = "index.html"
    source = "./index.html"
    acl = "public-read"
    content_type = "text/html"
}
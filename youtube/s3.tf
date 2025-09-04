# ---------------- S3 Bucket ----------------
resource "aws_s3_bucket" "public_bucket" {
  bucket = "abinash-public-bucket-${random_integer.rand.result}"

  tags = {
    Name        = "PublicBucket"
    Environment = "Dev"
  }
}

resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

# ---------------- Public Access Block ----------------
# Keep ACLs blocked (recommended)
resource "aws_s3_bucket_public_access_block" "public_bucket_access" {
  bucket                  = aws_s3_bucket.public_bucket.id
  block_public_acls       = true   # ✅ block ACLs, since org enforces this anyway
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

# ---------------- "song" Folder ----------------
# Creates an empty folder named "song/"
resource "aws_s3_object" "song_folder" {
  bucket = aws_s3_bucket.public_bucket.bucket
  key    = "song/"   # trailing slash makes it a folder
  # ❌ no acl here (AWS is blocking it anyway)
}


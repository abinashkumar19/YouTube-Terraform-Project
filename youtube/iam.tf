# ---------------- IAM Role ----------------
resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# ---------------- IAM Policy (Custom S3 Full Access) ----------------
resource "aws_iam_policy" "s3_custom_policy" {
  name        = "s3-custom-policy"
  description = "Custom policy to allow EC2 full access to S3 (Get, Put, Post, Delete, List)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:PutObjectAcl",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:CreateMultipartUpload",
          "s3:ListBucketMultipartUploads",
          "s3:ReplicateObject",
          "s3:RestoreObject"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}

# ---------------- Attach Custom Policy ----------------
resource "aws_iam_role_policy_attachment" "attach_custom_policy" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_custom_policy.arn
}

# ---------------- Attach AdministratorAccess (optional) ----------------
resource "aws_iam_role_policy_attachment" "attach_admin_policy" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# ---------------- Instance Profile (needed for EC2) ----------------
resource "aws_iam_instance_profile" "ec2_s3_instance_profile" {
  name = "ec2-s3-instance-profile"
  role = aws_iam_role.ec2_s3_role.name
}

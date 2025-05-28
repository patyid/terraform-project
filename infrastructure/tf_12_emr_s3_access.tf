
# Cria uma policy com acesso apenas aos buckets da conta
resource "aws_iam_policy" "emr_s3_access" {
  name        = "EMRAllowS3AccessInOwnAccount"
  description = "Permite que o EMR leia e escreva apenas nos buckets da conta atual"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = "arn:aws:s3:::*",
        Condition = {
          StringEquals = {
            "aws:PrincipalAccount" = var.id_count
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = "arn:aws:s3:::*/*",
        Condition = {
          StringEquals = {
            "aws:PrincipalAccount" = var.id_count

          }
        }
      }
    ]
  })
}

# Anexa a policy à role do EMR EC2
resource "aws_iam_role_policy_attachment" "attach_emr_s3_access" {
  role       = "EMR_EC2_DefaultRole"  
  policy_arn = aws_iam_policy.emr_s3_access.arn
}

resource "aws_iam_role" "this" {
  name = "${lookup(var.common, "product")}_${lookup(var.common, "sdlcenv")}_${lookup(var.common, "accountenv")}-${var.lambda_functionname}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy" "this" {
  name = "${lookup(var.common, "product")}_${lookup(var.common, "sdlcenv")}_${lookup(var.common, "accountenv")}-${var.lambda_functionname}-policy"
  role = aws_iam_role.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:DescribeSnapshots",
        "ec2:DeleteSnapshot",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ]
      Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

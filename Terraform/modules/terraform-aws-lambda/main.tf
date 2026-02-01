######################################### IAM Role for Lambda execution ########################
resource "aws_iam_role" "lambda_role" {
  name = "${lookup(var.common, "product")}_${lookup(var.common, "sdlcenv")}_${lookup(var.common, "accountenv")}-${var.lambda_functionrole}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${lookup(var.common, "product")}_${lookup(var.common, "sdlcenv")}_${lookup(var.common, "accountenv")}-${var.lambda_functionrole}-role"
    Purpose = "Lambda execution"
  }
}

################################################# Policy attachment for Lambda basic execution #############################
resource "aws_iam_role_policy_attachment" "basicexecution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

################################################# Policy attachment for Lambda basic execution VPC #########################
resource "aws_iam_role_policy_attachment" "vpcexecution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

############################################### EventBridge Schedule Rule ##################################################
resource "aws_cloudwatch_event_rule" "lambda" {
  name        = "${lookup(var.common, "product")}_${lookup(var.common, "sdlcenv")}_${lookup(var.common, "accountenv")}-${var.cw_eventrulename}-eventbridge"
  description = var.schedule_description
  schedule_expression = var.schedule_expression
  is_enabled = var.enabled

  tags = {
    Name = "${lookup(var.common, "product")}_${lookup(var.common, "sdlcenv")}_${lookup(var.common, "accountenv")}-${var.cw_eventrulename}-eventbridge"
    Purpose = "Event bridge cron schedule"
  }
}

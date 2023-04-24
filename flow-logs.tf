#Enables Flow Logs, set up the role, Cloud Watch and performs the proper associations
#owner: Alexandre Cezar

#Creates the Cloud Watch Log Group,
resource "aws_cloudwatch_log_group" "pcfw_flow_log_group" {
  name = "pcfw_flow-log-group"
  tags = {
  }
}

#Creates the flow log IAM policy with specific actions
resource "aws_iam_policy" "pcfw_flow_log_policy" {
  name = "pcfw_flow_log_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = aws_cloudwatch_log_group.pcfw_flow_log_group.arn
      }
    ]
  })
  depends_on = [aws_cloudwatch_log_group.pcfw_flow_log_group]
  tags = {
  }
}

#Creates the flow log IAM role with specific actions
resource "aws_iam_role" "pcfw_flow_log_role" {
  name = "pcfw_flow_log_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
  }
}
#Ataches the IAM policy into the IAM role
resource "aws_iam_role_policy_attachment" "flow_log_role_policy" {
  policy_arn = aws_iam_policy.pcfw_flow_log_policy.arn
  role       = aws_iam_role.pcfw_flow_log_role.name
}

#Configures the VPC flow log
resource "aws_flow_log" "pcfw_flow_log" {
  iam_role_arn    = aws_iam_role.pcfw_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.pcfw_flow_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.pcfw-foundations-vpc.id

  depends_on = [aws_iam_role.pcfw_flow_log_role]
  tags = {
  }
}

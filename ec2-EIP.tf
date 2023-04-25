#Creates the EC2 instances, attach roles and (but do not run the scripts as EIPs are used)
#owner: Alexandre Cezar

# Creates the role that will be attached to the insecure instance
resource "aws_iam_role" "pcfw-insecure-role" {
  name = "pcfw_insecure-role"
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
  tags = {
    Name = "pcfw-insecure-role"
  }
}

# Attaches the insecure policy to the insecure role
resource "aws_iam_role_policy_attachment" "pcfw-insecure-pa" {
  policy_arn = aws_iam_policy.pcfw-insecure-policy.arn
  role       = aws_iam_role.pcfw-insecure-role.name
}

# Creates the insecure instance profile
resource "aws_iam_instance_profile" "pcfw-insecure-profile" {
  name = "pcfw-insecure-profile"
  role = aws_iam_role.pcfw-insecure-role.name
  tags = {
    Name = "pcfw-insecure-profile"
  }
}

# Creates the insecure IAM policy
resource "aws_iam_policy" "pcfw-insecure-policy" {
  name = "pcfw-insecure-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "iam:PassRole",
          "ec2:RunInstances",
          "lambda:InvokeFunction"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
  tags = {
    Name = "pcfw-insecure-policy"
  }
}

# Creates the Bastion Host for access to the environment
resource "aws_instance" "bastion" {
  ami                    = var.bastion_ami
  instance_type          = var.bastion_instance_type
  subnet_id              = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.ssh_key_name
  tags = {
    Name                 = "pcfw-bastion"
  }
  depends_on = [aws_vpc.pcfw-foundations-vpc]
}

# Creates and Associates the Elastic IP to the Bastion Host
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  vpc      = true
  tags = {
    Name = "pcfw-eip-bastion"
  }
}

# Creates the vulnerable instance that will trigger the Hyperion policies
resource "aws_instance" "vulnerable" {
  ami                    = var.vulnerable_ami
  instance_type          = var.vulnerable_instance_type
  subnet_id              = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.vulnerable_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.pcfw-insecure-profile.name
  key_name               = var.ssh_key_name
  tags = {
    Name                 = "pcfw-vulnerable"
  }

  depends_on = [aws_vpc.pcfw-foundations-vpc]
}

# Creates and Associates the Elastic IP to the Vulnerable Host
resource "aws_eip" "vulnerable" {
  instance = aws_instance.vulnerable.id
  vpc      = true
  tags = {
    Name = "pcfw-eip-vulnerable"
  }
}

# Creates the internal instance that will be target of the internal port scans
resource "aws_instance" "internal" {
  ami                    = var.internal_ami
  instance_type          = var.internal_instance_type
  subnet_id              = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.internal_sg.id]
  key_name               = var.ssh_key_name
  user_data              = <<EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    echo "Hello World" > /var/www/html/index.html
    systemctl start httpd
    systemctl enable httpd
  EOF
  tags = {
    Name = "pcfw-internal"
  }
  depends_on = [aws_vpc.pcfw-foundations-vpc]
}

resource "aws_security_group" "bastion_sg" {
  name   = "bastion_sg"
  vpc_id = aws_vpc.pcfw-foundations-vpc.id

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public-subnet.cidr_block, aws_subnet.private-subnet.cidr_block, aws_subnet.private2-subnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = [aws_subnet.public-subnet.cidr_block, aws_subnet.private-subnet.cidr_block, aws_subnet.private2-subnet.cidr_block]
  }
  tags = {
    Name = "pcfw-bastion-sg"
  }
}

resource "aws_security_group" "vulnerable_sg" {
  name   = "vulnerable_sg"
  vpc_id = aws_vpc.pcfw-foundations-vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pcfw-vulnerable-sg"
  }
}

resource "aws_security_group" "internal_sg" {
  name   = "internal_sg"
  vpc_id = aws_vpc.pcfw-foundations-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public-subnet.cidr_block, aws_subnet.private-subnet.cidr_block, aws_subnet.private2-subnet.cidr_block, aws_subnet.lb1-subnet.cidr_block, aws_subnet.lb2-subnet.cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public-subnet.cidr_block, aws_subnet.private-subnet.cidr_block, aws_subnet.private2-subnet.cidr_block, aws_subnet.lb1-subnet.cidr_block, aws_subnet.lb2-subnet.cidr_block]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public-subnet.cidr_block, aws_subnet.private-subnet.cidr_block, aws_subnet.private2-subnet.cidr_block, aws_subnet.lb1-subnet.cidr_block, aws_subnet.lb2-subnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = [aws_subnet.public-subnet.cidr_block, aws_subnet.private-subnet.cidr_block, aws_subnet.private2-subnet.cidr_block, aws_subnet.lb1-subnet.cidr_block, aws_subnet.lb2-subnet.cidr_block]
  }
  tags = {
    Name = "pcfw-internal-sg"
  }
}

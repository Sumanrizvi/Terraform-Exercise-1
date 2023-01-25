data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    
    owners = ["099720109477"]
}

resource "aws_instance" "snakegame-instance" {
    ami           = data.aws_ami.ubuntu.id
    instance_type = "t3.micro"
    key_name      = aws_key_pair.snakegame-keypair.id
    subnet_id     = aws_subnet.public-subnet.id
    iam_instance_profile = aws_iam_instance_profile.snakegame-instanceprofile.name

    tags = {
        Name = "Suman-SnakeGame"
    }
}

resource "aws_eip" "snakegame-ec2-elasticip" {

  tags = {
    Name = "Suman-SnakeGame-EC2-ElasticIP"
  }
}

resource "aws_eip_association" "snakegame-eip_assoc" {
  instance_id   = aws_instance.snakegame-instance.id
  allocation_id = aws_eip.snakegame-ec2-elasticip.id
}

resource "aws_key_pair" "snakegame-keypair" {
  key_name   = "Suman-Key-Pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCoWSzUdGb0PFT+1iIVz8kGC2jVBy3wVpM++cf3sofU8p0tKvvXZx2ArVWQEhjzB/UMTHcBOvk/Opdk6Ab0wetSCWxu2FXlji2SCr3a/fQjDJvEZLnCKJaUpWBzU8hWJdg80bZwlaS7bL8Itr8f2ULtZqdyEayMxClT7VY2GbsD6lGrgUHxL1aR8PsUChs4MEO6JaxuRZNgDsLYed0TFlC+Lb+rcR9pphfbM15+OrHoGv//zRvl16soWAQtbzTb1yHPKwgvQhw2787UE54TZJSjRfIzaCyLieaQ3PGB08LY/bSI9rCq0q9I2sXE3wQrISm651bdC3093vh4R4ryeWO7jgFe+54L3mlNZdhza6FnWxeTLtkO0pWXY7bsSRUgPzSOhWxMPC8KUHrl/Yuudp2iDg8iR/WBAJiYtPWRe+6Cj6LcYyUwNIwUoS02P0KWYBKvuYTMz8yykvAdUA15sK50kZK7+WZeoCYk6re7p/8vCzXN/VOP1SFa+6cs0Ddu/Wk= sumanrizvi@aurora2.lan"
}


resource "aws_iam_role" "snakegame-role" {
    name = "SnakeGame-Role"

    assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
POLICY
}

resource "aws_iam_policy" "snakegame-policy" {
    name = "SnakeGame-Policy"

    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": ["arn:aws:s3:::Suman-SnakeGame/*"]
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "policyattachment" {
    role       = aws_iam_role.snakegame-role.name
    policy_arn = aws_iam_policy.snakegame-policy.arn
}

resource "aws_iam_instance_profile" "snakegame-instanceprofile" {
    name = "SnakeGame-InstanceProfile"
    role = aws_iam_role.snakegame-role.name
}


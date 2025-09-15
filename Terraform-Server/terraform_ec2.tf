#fetching the default VPC
data "aws_vpc" "default"{
    default = "true"
}

#featching the default subnet
data "aws_subnets" "default_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name = "availability-zone"
    values = ["ap-south-1a"]
  }
}

resource "aws_key_pair" "Terraform-Server-Key" {
  key_name = "Terraform-Server-Key"
  public_key = file("Terraform-server-key.pub")
}

resource "aws_security_group" "Terraform-CG" {
  depends_on = [ data.aws_vpc.default ]
  name = "Terraform-CG"
  description = "Allow Terraform port"
  vpc_id = data.aws_vpc.default.id
  tags = {
    Name = "Terraform-CG"
    Description = "Terraform-CG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "Allow_SSH" {
  security_group_id = aws_security_group.Terraform-CG.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
  tags = {
    name = "Allow_SSH"
    description = "Allow_SSH"
  }
}

resource "aws_vpc_security_group_ingress_rule" "Allow_HTTP" {
  security_group_id = aws_security_group.Terraform-CG.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
  tags = {
    name = "Allow_HTTP"
    description = "Allow_HTTP"
  }
}

resource "aws_vpc_security_group_ingress_rule" "Allow_Jenkins" {
  security_group_id = aws_security_group.Terraform-CG.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 8080
  to_port = 8080
  ip_protocol = "tcp"
    tags = {
    name = "Allow_Jenkins"
    description = "Allow_Jenkins"
  }
}

resource "aws_vpc_security_group_egress_rule" "Allow_All_Outbound" {
  security_group_id = aws_security_group.Terraform-CG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Name        = "Allow_All_Outbound"
    Description = "Allow all outbound traffic"
  }
}


resource "aws_instance" "Terraform-Server" {
  depends_on = [ aws_security_group.Terraform-CG ]
  ami = var.ami_type
  instance_type = var.instance_type
  subnet_id = data.aws_subnets.default_subnet.ids[0]
  key_name = aws_key_pair.Terraform-Server-Key.key_name
  vpc_security_group_ids = [aws_security_group.Terraform-CG.id]
  associate_public_ip_address = true

  tags = {
    Name = "Terraform-Server"
    Description = "Terraform-Server"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
}

output "Terraform-Public-IP" {
  value = aws_instance.Terraform-Server.public_ip
}


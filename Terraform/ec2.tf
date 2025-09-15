resource "aws_key_pair" "terra_aws_key" {
  key_name = "terra_aws_key"
  public_key = file("terra_aws_key.pub")
}

resource "aws_instance" "Docker_Server" {
    depends_on = [ aws_security_group.CustomCG ]
  ami = "ami-021a584b49225376d"
  instance_type = "t2.small"
  key_name = aws_key_pair.terra_aws_key.key_name
  subnet_id = aws_subnet.pub_subnet.id
  vpc_security_group_ids = [aws_security_group.CustomCG.id]
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/main_userdata.sh", {
  docker   = file("${path.module}/install_docker.sh")
  jenkins  = file("${path.module}/install_jenkins.sh")
})

  tags = {
    Name = "Docker_Server"
    Description = "Docker_Server"
  }
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
}

resource "aws_instance" "Production_Server" {
    depends_on = [ aws_security_group.CustomCG ]
  ami = "ami-021a584b49225376d"
  instance_type = "t2.small"
  key_name = aws_key_pair.terra_aws_key.key_name
  subnet_id = aws_subnet.pub_subnet.id
  vpc_security_group_ids = [aws_security_group.CustomCG.id]
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/main_userdata.sh", {
  docker   = file("${path.module}/install_docker.sh")
  jenkins  = file("${path.module}/install_jenkins.sh")
})

  tags = {
    Name = "Production_Server"
    Description = "Production_Server"
  }
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
}

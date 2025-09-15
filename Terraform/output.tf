output "VPC_ID" {
  value = aws_vpc.VPC.id
}

output "VPC_ARN" {
  value = aws_vpc.VPC.arn
}

output "pub_sub_id" {
  value = aws_subnet.pub_subnet.id
}

output "Docker_Server_IP"{
  value = aws_instance.Docker_Server.public_ip
}

output "Production_Server_IP"{
  value = aws_instance.Production_Server.public_ip
}


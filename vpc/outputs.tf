output "vpc_id" {
    value = aws_vpc.web_vpc.id
}

output "subnet_id" {
    value = aws_vpc.subnet-1.id
}
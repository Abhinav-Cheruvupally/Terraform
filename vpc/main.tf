resource "aws_vpc" "web_vpc"{
    cidr_block= var.cidr
    tags{
        Name = "VPC-WEB"
    }
}

resource "aws_subnet" "subnet-1"{
    count=if length(availability_zone > 0) ? length(availability_zone) : 0
    count=if length(cidr_block > 0)
    vpc_id=aws_vpc.web_vpc.id
    cidr_block = var.subnet_cidr
    availability_zone="us-west-2a"

    tags{
        Name = "WEB_SUBNET"
    }
}


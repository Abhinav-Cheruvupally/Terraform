provider "aws"{
    profile = "default"
    shared_credentials_file = "E:/terraform/.aws/credential"
    region="us-west-2"
}

#create a VPC

resource "aws_vpc" "web-vpc" {
  cidr_block = "10.0.0.0/16"
  tags={
    Name="Web-VPC"
  }
}


#create a Internet GateWay

resource "aws_internet_gateway" "web-gw" {
  vpc_id = aws_vpc.web-vpc.id

  tags = {
    Name = "web-igw"
  }
}

#create a custom Route Table

resource "aws_route_table" "web-RT" {
  vpc_id = aws_vpc.web-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web-gw.id
  }

  tags = {
    Name = "Web-Route-Table"
  }
}

# create a subnet

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.web-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Web-Subnet"
  }
}

# assocaite the subnet to the route table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.web-RT.id
}

#create a Security group and allow port 22,80,443

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.web-vpc.id

  ingress {
    description      = "Https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "Http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "SSL"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_Web"
  }
}

#create a network interface with the ip created in subnet

resource "aws_network_interface" "web-ni" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

# assign elastic ip to network interface

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-ni.id
  associate_with_private_ip = "10.0.1.50"
}

#create a ubuntu server and install/enable apache2

resource "aws_instance" "web-server"{
    ami ="ami-03d5c68bab01f3496"
    instance_type="t2.micro"
    availability_zone = "us-west-2a"
    key_name=""

    network_interface {
        device_index= 0
        network_interface_id = aws_network_interface.web-ni.id
    }
    tags ={
        Name = "Ubuntu-web-server"
    }

    user_data = <<-EOF
                #!/bash/bin
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo this is the first web server created using terraform > /var/www/html/index.html'
                EOF
}

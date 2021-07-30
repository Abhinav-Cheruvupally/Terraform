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

resource "aws_route_table" "web-RT-2" {
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

resource "aws_subnet" "subnet-2" {
  vpc_id     = aws_vpc.web-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "Web-Subnet2"
  }
}

# assocaite the subnet to the route table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.web-RT.id
}
resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.web-RT-2.id
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
resource "aws_network_interface" "web-ni-2" {
  subnet_id       = aws_subnet.subnet-2.id
  private_ips     = ["10.0.2.50"]
  security_groups = [aws_security_group.allow_web.id]
}

# assign elastic ip to network interface

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-ni.id
  associate_with_private_ip = "10.0.1.50"
}

resource "aws_eip" "two" {
  vpc                       = true
  network_interface         = aws_network_interface.web-ni-2.id
  associate_with_private_ip = "10.0.2.50"
}
#create a webserver

resource "aws_instance" "web-server"{
    ami ="ami-0cf6f5c8a62fa5da6"
    instance_type="t2.micro"
    availability_zone = "us-west-2a"
    key_name=""

    network_interface {
        device_index= 0
        network_interface_id = aws_network_interface.web-ni.id
    }
    tags ={
        Name = "web-server1"
    }
}

resource "aws_instance" "web-server-2"{
    ami ="ami-0cf6f5c8a62fa5da6"
    instance_type="t2.micro"
    availability_zone = "us-west-2b"
    key_name=""

    network_interface {
        device_index= 0
        network_interface_id = aws_network_interface.web-ni-2.id
    }
    tags ={
        Name = "web-server2"
    }

}

#create a elastic load balancer to distribute the load across 2 servers

resource "aws_lb" "Network-lb" {
  name               = "Network-Load-balancer"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]

  enable_deletion_protection = true

  tags = {
    Name="ELB-Network"
    Environment = "production"
  }
}

#creating a loadbalancer listener

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.Network-lb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-1.arn
  }
   depends_on = ["aws_lb_target_group.lb-1"]
}

#creating a target group

resource "aws_lb_target_group" "lb-1" {
  name     = "tf-lb-network"
  port     = 8080
  protocol = "TCP"
  target_type = "instance"
  vpc_id   = aws_vpc.web-vpc.id
}

output instances1{
  value=aws_instance.webserver.id
  depends_on=[aws_instance.webserver]
}

output instances2{
  value=aws_instance.webserver-2.id
  depends_on=[aws_instance.webserver-2]
}


#attach the target groups

resource "aws_lb_target_group_attachment" "attach-tg" {
  count = var.instance_id
  target_group_arn = aws_lb_target_group.lb-1.arn
  target_id        = element(var.instance_id, count.index)
  port             = 80

  depends_on=[aws_instance.webserver, aws_instance.webserver-2]
}
#resource "aws_lb_target_group_attachment" "attach-tg-2" {
  #target_group_arn = aws_lb_target_group.lb-1.arn
  #target_id        = aws_instance.web-server-2.id
  #port             = 80
#}

#create launch configuration for autoscaling

resource "aws_launch_configuration" "lc" {
  image_id               = "ami-0cf6f5c8a62fa5da6"
  instance_type          = "t2.micro"
  security_groups        = [aws_security_group.allow_web.id]
  user_data = <<-EOF
              #!/bin/bash
              sudo yum install httpd -y
              sudo bash -c 'echo this is a server launched using autoscaling > /var/www/html/index.html'
              sudo systemctl start httpd
              sudo service httpd start
              sudo systemctl enable httpd
              sudo chkconfig httpd on
              sudo systemctl status httpd
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

///
#  create a autoscaling group

resource "aws_autoscaling_group" "asg" {
  name                      = "terraform-asg"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.lc.name
  vpc_zone_identifier       = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]


  tag {
    key                 = "Name"
    value               = "ASG"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}

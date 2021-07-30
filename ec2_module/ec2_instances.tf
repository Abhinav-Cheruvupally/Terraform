resource "aws_instance" "ec2-1"{
    instance_type= var.instancetype
    ami=var.ami
    subnet_id = var.subnet_id
    user_data= var.user_data
}
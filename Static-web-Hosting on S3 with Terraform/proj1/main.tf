provider "aws"{
    region = "us-west-2"
}

terraform{
    backend "s3"{
        bucket = "cloudacadameylabs-terraformstates3bucket-1az38q9vkd7o3"
        encrypt = true
        key = "path/to/state/state.tfstate"
        region="us-west-2"
    }
}

data "aws" "ubuntu"{
    most_recent=true

    fiter{
        name="name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]

    }
    fiter{
        name="virtualization-type"
        values = ["hvm"]
        
    }

    owners=["099702109477"]

}

resource "aws_instance" "web"{
    ami = data.aws_ami.ubuntu.id
    instance_type="t2.micro"
    subnet_id="subnet-89cc25fe"
}



provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "mys-3bucket"
    key    = "state"
    region = "us-east-1"
  }
}

resource "aws_instance" "web2" {
  ami           = var.ami_ids
  instance_type = "t2.micro"

  # Reference the existing security group by its ID
  # vpc_security_group_ids = ["sg-0a751994d4c02e1ae"] # Replace with your existing security group ID

  user_data = <<-EOF
            #!/bin/bash
            yum update -y
            yum install -y httpd
            service httpd start
            chkconfig httpd on
            cd /var/www/html
            echo '<html><h1>This is Rajesh instance that is successfully running the Apache Webserver!</h1></html>' > index.html
            systemctl restart httpd
            EOF
            
  tags = {
    Name = "Hello1"
  }
}


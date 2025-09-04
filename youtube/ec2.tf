# ---------------- Public Bastion Instance ----------------
resource "aws_instance" "bastion" {
  ami                         = "ami-00ca32bbc84273381"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public1.id
  vpc_security_group_ids      = [aws_security_group.main_sg.id]
  key_name                    = "abi"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_s3_instance_profile.name

  tags = {
    Name = "bastion-host"
  }
}

# ---------------- Private Instance-1 with Nginx ----------------
resource "aws_instance" "private_instance_1" {
  ami                         = "ami-00ca32bbc84273381"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private1.id
  vpc_security_group_ids      = [aws_security_group.main_sg.id]
  key_name                    = "abi"
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_s3_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras enable nginx1
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "private-instance-1"
  }
}

# ---------------- Private Instance-2 with Python + Flask ----------------
resource "aws_instance" "private_instance_2" {
  ami                         = "ami-00ca32bbc84273381"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private2.id
  vpc_security_group_ids      = [aws_security_group.main_sg.id]
  key_name                    = "abi"
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_s3_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y python3 python3-pip
              pip3 install Flask mysql-connector-python flask-cors

              mkdir -p /home/ec2-user/flaskapp
              cat <<EOT > /home/ec2-user/flaskapp/app.py
              from flask import Flask
              app = Flask(__name__)

              @app.route('/')
              def hello():
                  return "Hello from Private Instance 2 with Flask!"

              if __name__ == "__main__":
                  app.run(host="0.0.0.0", port=5000)
              EOT

              nohup python3 /home/ec2-user/flaskapp/app.py > /home/ec2-user/flask.log 2>&1 &
              EOF

  tags = {
    Name = "private-instance-2"
  }
}

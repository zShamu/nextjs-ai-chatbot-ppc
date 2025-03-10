provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "my_key" {
  key_name   = "my_key"
  public_key = file("~/.ssh/id_rsa.pub")  # Ruta de tu clave pública
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Permite SSH desde cualquier lugar (INSEGURO)"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # ⚠ Permite acceso desde cualquier IP (muy inseguro)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_guest" {
  ami             = "ami-0c55b159cbfafe1f0"  # Ubuntu 20.04 en us-east-1 (verifica la AMI para tu región)
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.allow_ssh.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo useradd -m guest
              echo 'guest:guestpassword' | sudo chpasswd  # ⚠ Contraseña débil (inseguro)
              sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
              sudo systemctl restart sshd
              EOF

  tags = {
    Name = "EC2-Inseguro-Guest"
  }
}

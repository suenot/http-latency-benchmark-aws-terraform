provider "aws" {
  region = "ap-southeast-1"  # Сингапур
}

# Создание VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Создание подсетей в VPC
resource "aws_subnet" "subnet_1" {
  vpc_id             = aws_vpc.main.id
  cidr_block         = "10.0.1.0/24"  # Первая подсеть
  availability_zone  = "ap-southeast-1a"  # Зона доступности
  tags = {
    Name = "subnet-1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id             = aws_vpc.main.id
  cidr_block         = "10.0.2.0/24"  # Вторая подсеть
  availability_zone  = "ap-southeast-1b"  # Зона доступности
  tags = {
    Name = "subnet-2"
  }
}

# Создание экземпляров EC2
resource "aws_instance" "example" {
  count         = 3  # Количество экземпляров
  ami           = "ami-047126e50991d067b"  # ID образа Debian в регионе Сингапур
  instance_type = "t3.micro"  # Выбор инстанса
  subnet_id     = element([aws_subnet.subnet_1.id, aws_subnet.subnet_2.id], count.index % 2)

  tags = {
    Name = "example-instance-${count.index}"
  }

  # # Прямое копирование файла на инстанс
  # provisioner "file" {
  #   source      = "./suenot-frontrunner"  # Локальный файл
  #   destination = "/home/ubuntu/suenot-frontrunner"  # Путь на инстансе

  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"  # Имя пользователя
  #     host        = self.public_ip  # Получение IP-адреса экземпляра
  #     private_key = file("./my-key-pair.pem")  # Укажите путь к вашему приватному ключу
  #   }
  # }

  # # Сделать файл исполняемым и запустить
  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /home/ubuntu/suenot-frontrunner",  # Сделать файл исполняемым
  #     "/home/ubuntu/suenot-frontrunner &",  # Запустить файл в фоне
  #   ]

  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"  # Имя пользователя
  #     private_key = file("./my-key-pair.pem")  # Укажите путь к вашему приватному ключу
  #     host        = self.public_ip
  #   }
  # }
}

output "instance_ips" {
  value = aws_instance.example[*].public_ip  # Вывод IP-адресов экземпляров
}

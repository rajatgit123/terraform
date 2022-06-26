data "aws_availability_zones" "available_zones" {
  state = "available"
}

data "aws_vpc" "vpc" {
 filter {
    name = "tag:Name"
    values = ["terraform-vpc"]    
		}
}

data "aws_internet_gateway" "gateway" {
 filter {
  name = "tag:Name"
  values = ["terraform"]
  }
}
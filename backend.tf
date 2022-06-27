terraform {
  backend "s3" {
    bucket = "master-instance"
    key = "remote-state"
    region = "us-east-2"
  }
}

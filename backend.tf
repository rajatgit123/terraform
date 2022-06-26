terraform {
  backend "s3" {
    bucket = "remote-backend11"
    key = "remote-state"
    region = "us-east-2"
  }
}

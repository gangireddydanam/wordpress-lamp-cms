terraform {
  backend "s3" {
    bucket = "sensitive-tf-state-env"
    key    = "stage/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
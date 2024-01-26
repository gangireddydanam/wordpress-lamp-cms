variable "vpc_cidr" {
    description = "passing the vpc cidr range"
    default = "10.2.0.0/16"
    type = string
  
}

variable "vpc_name" {
    description = "passing the vpc name"
    default = "stage"
    type = string
  
}

variable "pub_subnet_cidr" {
    description = "pub subnet"
    default = ["10.2.216.0/24","10.2.217.0/24","10.2.218.0/24"]
  
}

variable "app_subnet_cidr" {
    description = "app subnet"
    default = ["10.2.0.0/18","10.2.64.0/18","10.2.128.0/18"]
  
}

variable "data_subnet_cidr" {
    description = "data subnet"
    default = ["10.2.192.0/21","10.2.200.0/21","10.2.208.0/21"]
  
}

 variable "app_subnet" {
    default = "app-subnet"
   
 }

 variable "data_subnet" {
    default = "data-subnet"
   
 }

 variable "pub_subnet" {
    default = "pub-subnet"
   
 }

variable "username" {
    default = "test"
  
}
variable "password" {
    default = "test"
  
}

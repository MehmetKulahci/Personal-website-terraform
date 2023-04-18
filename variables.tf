variable "vpc_cidr_block" {

    default = "10.0.0.0/16"
}

variable "pub_sub1a" {

    default = "10.0.10.0/24"
}

variable "pub_sub1b" {

      default = "10.0.20.0/24"
}

variable "env_prefix" {
  default = "Personal-website"
}

variable "avail_zone" {
      default = "us-east-1a"
}

variable "avail_zone2" {

    default = "us-east-1b"
}

variable "Static_instance_type" {
  default = "t2.micro"
}


variable "Static_key_name" {
  default = "first_key"
}


variable "Static_image_id" {
    
    default = "ami-069aabeee6f53e7bf"
    }

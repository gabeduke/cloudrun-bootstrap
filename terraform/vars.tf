variable "service_name" {
  type = string
}

variable "service_image" {
  type = string
  default = "gcr.io/cloudrun/hello"
}

variable "service_location" {
  type = string
  default = "us-east1"
}


variable "environments" {
  type = list(string)
  description = "The environments to create the network group hierarchy for"
  default = ["dev", "test", "prod"]
}
 variable "network_manager_id" {
  type = string
  description = "The ID of the network manager to create the network group hierarchy for"
}

variable "regions" {
  type = string
  description = "The region to create the network group hierarchy for"
}

variable "name" {
  type = string
  description = "The name of the network group hierarchy"
}






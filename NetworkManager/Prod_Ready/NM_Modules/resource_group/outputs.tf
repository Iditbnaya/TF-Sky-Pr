output "id" {
  description = "The ID of the resource group"
  value       = azapi_resource.this.id
}

output "name" {
  description = "The name of the resource group"
  value       = azapi_resource.this.name
}

output "location" {
  description = "The location of the resource group"
  value       = azapi_resource.this.location
} 
variable "proxmox_endpoint" {
  type        = string
  description = "Địa chỉ Web GUI của node-mini1 (ví dụ: https://192.168.1.50:8006/)"
}

variable "proxmox_api_token" {
  type        = string
  description = "API token format: user@pam!tokenid=secret"
  sensitive   = true
}

variable "proxmox_insecure" {
  type        = bool
  default     = true
  description = "Bỏ qua xác thực SSL tự ký của Proxmox"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key của bạn để bơm vào container để SSH trực tiếp"
}

# 1. Lấy danh sách các node
data "proxmox_virtual_environment_nodes" "available_nodes" {}

# 2. Thăm dò danh sách storage (ổ đĩa) có trên node pve-mini
data "proxmox_virtual_environment_datastores" "pve_datastores" {
  node_name = "pve-mini"
}

# 3. Thăm dò danh sách các VM hiện đang có trên node pve-mini
data "proxmox_virtual_environment_vms" "existing_vms" {
  node_name = "pve-mini"
}

# Ma trận phân tầng storage chuẩn hóa theo mục đích sử dụng (Storage Tiering)
locals {
  storage_tiers = {
    tier1_database  = "local-lvm"    # NVMe (54GB) - Dành riêng cho DB (PostgreSQL, MySQL, Redis, etcd)
    tier2_apps      = "mini-sata"    # SATA SSD (219GB) - Dành cho Prometheus TSDB, Grafana, App containers
    tier3_bulk_data = "cold-archive" # MergerFS (1.1TB) - Dành cho User uploads, Media, Datasets, ISOs
    tier4_backup    = "backup-hdd"   # USB HDD (1TB) - Chuyên trách VZDump backups tự động
  }
}

# Tự động tải Debian 12 LXC Template vào storage local nếu chưa có
resource "proxmox_virtual_environment_download_file" "debian_template" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "pve-mini"
  url          = "http://download.proxmox.com/images/system/debian-12-standard_12.12-1_amd64.tar.zst"
}

resource "proxmox_virtual_environment_container" "app_gateway" {
  description  = "Application Gateway & Static Web Hosting - Managed by Terraform"
  node_name    = "pve-mini"
  vm_id        = 100
  unprivileged = true

  initialization {
    hostname = "app-gateway-01"

    ip_config {
      ipv4 {
        address = "dhcp" # Hoặc IP tĩnh: "192.168.1.100/24", gateway = "192.168.1.1"
      }
    }

    user_account {
      keys = [trimspace(var.ssh_public_key)]
    }
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048 # 2GB RAM
    swap      = 512
  }

  disk {
    datastore_id = local.storage_tiers.tier2_apps # Đặt trên mini-sata (SATA SSD)
    size         = 16                             # 16 GB
  }

  operating_system {
    # Tên file template bạn vừa tải ở Bước 1
    template_file_id = proxmox_virtual_environment_download_file.debian_template.id
    type             = "debian"
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  features {
    nesting = true # Cho phép chạy Docker bên trong nếu sau này cần
  }

  started = true
}

output "app_gateway_ip" {
  description = "IP của Application Gateway Container"
  value       = proxmox_virtual_environment_container.app_gateway.initialization[0].ip_config[0].ipv4[0].address
}

resource "proxmox_virtual_environment_container" "research_hub" {
  description  = "WisdomTree, Local SLM RAG, Document Lab - Managed by Terraform"
  node_name    = "pve-mini"
  vm_id        = 101
  unprivileged = true

  initialization {
    hostname = "research-hub-01"

    ip_config {
      ipv4 {
        address = "dhcp" # Hoặc IP tĩnh nếu muốn cố định: "192.168.1.64/24", gateway = "192.168.1.1"
      }
    }

    user_account {
      keys = [trimspace(var.ssh_public_key)]
    }
  }

  cpu {
    cores = 3
  }

  memory {
    dedicated = 6144 # 6GB RAM (cho Next.js, Postgres + pgvector, và Ollama chạy model 3B)
    swap      = 2048
  }

  disk {
    datastore_id = local.storage_tiers.tier2_apps # mini-sata SSD
    size         = 25                             # 25 GB cho Docker images, tools
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.debian_template.id
    type             = "debian"
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  features {
    nesting = true # BẮT BUỘC: để chạy Docker bên trong LXC
  }

  started = true
}

resource "proxmox_virtual_environment_container" "ci_runner" {
  description  = "GitHub Actions Self-Hosted Runner - Managed by Terraform"
  node_name    = "pve-mini"
  vm_id        = 102
  unprivileged = true

  initialization {
    hostname = "ci-runner-01"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [trimspace(var.ssh_public_key)]
    }
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 3072 # 3GB RAM (đủ cho build Next.js / Vite và sync)
    swap      = 1024
  }

  disk {
    datastore_id = local.storage_tiers.tier2_apps # mini-sata SSD
    size         = 20                             # 20 GB cho toolchains và cache
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.debian_template.id
    type             = "debian"
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  features {
    nesting = true
  }

  started = true
}

resource "proxmox_virtual_environment_container" "monitoring" {
  description  = "Lean Observability (Prometheus, Grafana, Alertmanager) - Managed by Terraform"
  node_name    = "pve-mini"
  vm_id        = 103
  unprivileged = true

  initialization {
    hostname = "monitoring-01"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [trimspace(var.ssh_public_key)]
    }
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048 # 2GB RAM (Prometheus TSDB + Grafana + Alertmanager ăn khoảng 800MB-1.2GB)
    swap      = 1024
  }

  disk {
    datastore_id = local.storage_tiers.tier2_apps # mini-sata SSD (chịu tải ghi time-series liên tục)
    size         = 20                             # 20 GB lưu trữ metrics retention 30-60 ngày
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.debian_template.id
    type             = "debian"
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  features {
    nesting = true # Cho phép chạy Docker Compose bên trong
  }

  started = true
}


resource "proxmox_virtual_environment_container" "media_music" {
  description  = "Navidrome Music Server - Managed by Terraform"
  node_name    = "pve-mini"
  vm_id        = 104
  unprivileged = true

  initialization {
    hostname = "media-music-01"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [trimspace(var.ssh_public_key)]
    }
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 1536 # 1.5GB RAM
    swap      = 512
  }

  disk {
    datastore_id = local.storage_tiers.tier2_apps # mini-sata SSD
    size         = 10                             # 10 GB cho OS và DB thư viện nhạc
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.debian_template.id
    type             = "debian"
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  features {
    nesting = true
  }

  started = true
}

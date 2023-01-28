terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.token
}

# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "jenkins" {
  image    = "ubuntu-22-04-x64"
  name     = "jenkins"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]
}

data "digitalocean_ssh_key" "terraform" {
  name = "terraform"
}

resource "digitalocean_kubernetes_cluster" "desafio3" {
  name   = "desafio3"
  region = "nyc1"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.25.4-do.0"
    
    node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

variable "region" {
    default = "nyc1"
  
}
variable "token" {
    default = ""
  
}

output "jenkins_ip" {
    value = digitalocean_droplet.jenkins.ipv4_address
  
}

resource "local_file" "foo" {
  content  = digitalocean_kubernetes_cluster.desafio3.kube_config.0.raw_config
  filename = "kube_config.yaml"
}
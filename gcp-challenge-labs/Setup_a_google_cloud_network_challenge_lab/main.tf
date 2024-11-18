provider "google" {
  region = "us-central1"  # Replace the region as per the lab
}

# Create the VPC
resource "google_compute_network" "main_vpc" {
  name                    = "vpc-network-wz40"
  auto_create_subnetworks  = false  
  routing_mode            = "REGIONAL"
}

# Create Subnet A
resource "google_compute_subnetwork" "subnet_a" {
  name          = "subnet-a-2qsj"
  region        = "us-central1"
  network       = google_compute_network.main_vpc.id
  ip_cidr_range = "10.10.10.0/24"
  private_ip_google_access = true
}

# Create Subnet B
resource "google_compute_subnetwork" "subnet_b" {
  name          = "subnet-b-6m3o"
  region        = "us-east1"
  network       = google_compute_network.main_vpc.id
  ip_cidr_range = "10.10.20.0/24"
  private_ip_google_access = true
}

# Create firewall rule for SSH (vayc-firewall-ssh)
resource "google_compute_firewall" "vayc_firewall_ssh" {
  name    = "vayc-firewall-ssh"
  network = "vpc-network-wz40"  # Specify your network name
  priority = 1000
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# Create firewall rule for RDP (hfde-firewall-rdp)
resource "google_compute_firewall" "hfde_firewall_rdp" {
  name    = "hfde-firewall-rdp"
  network = "vpc-network-wz40"  # Specify your network name
  priority = 65535
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/24"]
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
}

# Create firewall rule for ICMP (epaw-firewall-icmp)
resource "google_compute_firewall" "epaw_firewall_icmp" {
  name    = "epaw-firewall-icmp"
  network = "vpc-network-wz40"  # Specify your network name
  priority = 1000
  direction = "INGRESS"
  source_ranges = ["10.10.10.0/24", "10.10.20.0/24"]
  allow {
    protocol = "icmp"
  }
}

# Create VM in Subnet A
resource "google_compute_instance" "us_test_01" {
  name         = "us-test-01"
  machine_type = "e2-micro"  # Adjust the instance type as needed
  zone         = "us-central1-a"

  network_interface {
    network    = "default"  # Specify your network name or use the default network
    subnetwork = "subnet-a-2qsj"  # Use the actual subnetwork name for subnet A
    access_config {
      // Allow the VM to have an external IP
    }
  }

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-11"  # Replace with an appropriate image
    }
  }

  tags = ["us-test-01"]  # Network tag to allow traffic in the firewall
}

# Create VM in Subnet B
resource "google_compute_instance" "us_test_02" {
  name         = "us-test-02"
  machine_type = "e2-micro"  # Adjust the instance type as needed
  zone         = "us-east1-b"

  network_interface {
    network    = "default"  # Specify your network name or use the default network
    subnetwork = "subnet-b-6m3o"  # Use the actual subnetwork name for subnet B
    access_config {
      // Allow the VM to have an external IP
    }
  }

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-11"  # Replace with an appropriate image
    }
  }

  tags = ["us-test-02"]  # Network tag to allow traffic in the firewall
}




# Build Infrastructure with Terraform on Google Cloud: Challenge Lab || [GSP345](https://www.cloudskillsboost.google/focuses/42740?parent=catalog) ||

## Solution [here]

### Set Variables ###
```
export BUCKET=tf-bucket-439943
export INSTANCE=tf-instance-584651
export VPC=tf-vpc-475870
export PROJECT_ID=qwiklabs-gcp-00-8bc8b8d46db8
export ZONE=us-central1-f
export REGION=us-central1
export INSTANCE_ID_1=tf-instance-1 
export INSTANCE_ID_2=tf-instance-2
```
### Task 1. Create the configuration files ###

#### Create .tf and other folders ####
```
touch main.tf variables.tf
mkdir modules
cd modules
mkdir instances
cd instances
touch instances.tf outputs.tf variables.tf
cd ..
mkdir storage
cd storage
touch storage.tf outputs.tf variables.tf
cd
```
#### Update the files ####
```
cat > variables.tf <<EOF_END
variable "region" {
 default = "$REGION"
}

variable "zone" {
 default = "$ZONE"
}

variable "project_id" {
 default = "$PROJECT_ID"
}
EOF_END
```
#### add terraform block to main.tf file ####
```
cat > main.tf <<EOF_END
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.53.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

module "instances" {
  source     = "./modules/instances"
}
EOF_END
```
```
terraform init
```
### Task 2. Import infrastructure ###

#### Import the existing instances into the instances module. ####
```
cat > modules/instances/instances.tf <<EOF_END
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "n1-standard-1"
  zone         = "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
 network = "default"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "n1-standard-1"
  zone         =  "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
	  network = "default"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}
EOF_END
```
#### Import Infrastructure ####
```
terraform import module.instances.google_compute_instance.tf-instance-1 $INSTANCE_ID_1
```
```
terraform import module.instances.google_compute_instance.tf-instance-2 $INSTANCE_ID_2
```
```
terraform plan
```
```
terraform apply -auto-approve
```

### Task 3. Configure a remote backend ###
#### Create a Cloud Storage bucket resource inside the storage module ####
```
cat > modules/storage/storage.tf <<EOF_END
resource "google_storage_bucket" "storage-bucket" {
  name          = "$BUCKET"
  location      = "us"
  force_destroy = true
  uniform_bucket_level_access = true
}
EOF_END
```

#### Add the module reference to the main.tf file. ####
```
cat >> main.tf <<EOF_END
module "storage" {
  source     = "./modules/storage"
}
EOF_END
```
```
terraform init
```
```
terraform apply -auto-approve
```
#### Configure this storage bucket as the remote backend inside the main.tf ####
```
cat > main.tf <<EOF_END
terraform {
	backend "gcs" {
		bucket = "$BUCKET"
		prefix = "terraform/state"
	}
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.53.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

module "instances" {
  source     = "./modules/instances"
}

module "storage" {
  source     = "./modules/storage"
}
EOF_END
```
```
terraform init
```
### Task 4. Modify and update infrastructure ###

#### modify the machine type of instances and create additional instance ####
```
cat > modules/instances/instances.tf <<EOF_END
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "e2-standard-2"
  zone         = "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
 network = "default"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "e2-standard-2"
  zone         =  "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
	  network = "default"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}

resource "google_compute_instance" "$INSTANCE" {
  name         = "$INSTANCE"
  machine_type = "e2-standard-2"
  zone         = "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
 network = "default"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}
EOF_END
```
```
terraform init
```
```
terraform apply -auto-approve
```

### Task 5. Destroy resources ###
```
cat > modules/instances/instances.tf <<EOF_END
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "e2-standard-2"
  zone         = "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
 network = "default"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "e2-standard-2"
  zone         =  "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
	  network = "default"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}
EOF_END
```
```
terraform apply -auto-approve
```

### Task 6. Use a module from the Registry ###

#### Create VPC and subnets ####
```
cat >> main.tf <<EOF_END
module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 6.0.0"

    project_id   = "$PROJECT_ID"
    network_name = "$VPC"
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = "$REGION"
        },
        {
            subnet_name           = "subnet-02"
            subnet_ip             = "10.10.20.0/24"
            subnet_region         = "$REGION"
            subnet_private_access = "true"
            subnet_flow_logs      = "true"
            description           = "Hola"
        },
    ]
}
EOF_END
```
```
terraform init
```
```
terraform plan
```
```
terraform apply -auto-approve
```
#### update the configuration resources to connect tf-instance-1 to subnet-01 and tf-instance-2 to subnet-02 ####
```
cat > modules/instances/instances.tf <<EOF_END
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "e2-standard-2"
  zone         = "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
	  network = "$VPC"
    subnetwork = "subnet-01"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "e2-standard-2"
  zone         = "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
	  network = "$VPC"
    subnetwork = "subnet-02"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}
EOF_END
```
```
terraform init
```
```
terraform plan
```
```
terraform apply -auto-approve
```
### Task 7. Configure a firewall ###
```
cat >> main.tf <<EOF_END
resource "google_compute_firewall" "tf-firewall"{
  name    = "tf-firewall"
	network = "projects/$PROJECT_ID/global/networks/$VPC"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_tags = ["web"]
  source_ranges = ["0.0.0.0/0"]
}
EOF_END
```
```
terraform init
```
```
terraform plan
```
```
terraform apply -auto-approve
```

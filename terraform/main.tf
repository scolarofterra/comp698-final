terraform {
 backend "gcs" {
   project = "comp698-tdd1007"
   bucket  = "comp698-tdd1007-terraform-state"
   prefix  = "terraform-state"
 }
}
provider "google" {
  region = "us-central1"
  project = "comp698-tdd1007"
}

resource "google_compute_instance_template" "staging-run" {
  name_prefix  = "stagingrun-"
  machine_type = "f1-micro"
  region       = "us-central1"
  tags = ["http-server"]
  service_account {
    scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_write",
    ]
  }


  // boot disk
  disk {
    source_image = "cos-cloud/cos-stable"
  }
 
  network_interface {
     network = "default"

     access_config {
          // Ephemeral IP
    }
    }

  lifecycle {
    create_before_destroy = true
  }
  metadata {
    gce-container-declaration = <<EOF
spec:
  containers:
  - image: 'gcr.io/comp698-tdd1007/github-scolarofterra-comp698-final:92befc2f9e22bb2ae3e7500364a5f6ddfcd78d38'
    name: service-container
    stdin: false
    tty: false
  restartPolicy: Always
EOF
  }

}

resource "google_compute_instance_group_manager" "Staging" {
  name               = "Staging"
  instance_template  = "${google_compute_instance_template.staging-run.self_link}"
  base_instance_name = "Staging"
  zone               = "us-central1-a"


  target_size        = "1"

}




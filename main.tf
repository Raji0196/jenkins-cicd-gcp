provider "google" {
  project = "ccai-platform-363306"
  region  = "us-central1"
}
resource "google_compute_firewall" "firewall" {
  name    = "externalssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"] 
  target_tags   = ["externalssh"]
}
resource "google_compute_firewall" "webserverrule" {
  name    = "webserver"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80","443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["webserver"]
}
# We create a public IP address for our google compute instance to utilize
resource "google_compute_address" "static" {
  name = "vm-public-address"
  depends_on = [ google_compute_firewall.firewall ]
}
resource "google_compute_instance" "dev1" {
  name         = "devserver1"
  machine_type = "f1-micro"
  zone         = "us-central1-a"
  tags         = ["externalssh","webserver"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
}
  


# Gazduiește o aplicație web pe GCP
# Pași antemergători
# 1. fă un proiect nou în https://cloud.google.com/
# 2. Modifică mai jos ID-ul proiectului
# 3. Fă un bucket pentru a ține starea terraform
# 4. Modifică mai jos numele bucket-ului
terraform {
  backend "gcs" {
    prefix = "state"
    bucket = "terraform"
  }
}

# Mai jos pui proiect, regiune și zonă
# Apoi pentru a executa scriptul:
#   gcloud auth application-default login
#   terraform init
#   terraform apply
locals {
  project = "larkworthy-tester"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}


provider "google" {
  project = local.project
  region  = local.region
}

# un service account pentru VM
resource "google_service_account" "webserver" {
  account_id   = "webserver"
  display_name = "webserver"
}

# Discul pentru VM
resource "google_compute_disk" "webserver" {
  name  = "webserver"
  type  = "pd-standard"
  zone  = local.zone
  image = "cos-cloud/cos-stable"
}

# Adresă IP statică
resource "google_compute_address" "webserver" {
  name   = "webserver-ip"
  region = local.region
}

# VM-ul în sine
resource "google_compute_instance" "webserver" {
  name         = "webserver"
  machine_type = "n1-standard-1"
  zone         = local.zone
  tags         = ["webserver"]

  metadata = {
    enable-oslogin = "TRUE"
  }

  boot_disk {
    auto_delete = false # disk permanent, nu se șterge odată cu VM-ul
    source      = google_compute_disk.webserver.self_link
  }

  network_interface {
    network = google_compute_network.webserver.name
    access_config {
      nat_ip = google_compute_address.webserver.address
    }
  }

  service_account {
    email  = google_service_account.webserver.email
    scopes = ["userinfo-email"]
  }

}

# facem o rețea separată ca să nu poate accesa alte VM-uri
resource "google_compute_network" "webserver" {
  name = "webserver"
}

# facem setările în firewall
resource "google_compute_firewall" "webserver" {
  name    = "webserver"
  network = google_compute_network.webserver.name
  # http și https
  allow {
    protocol = "http"
    ports    = ["80,443"]
  }
  # ICMP (ping)
  allow {
    protocol = "icmp"
  }
  # SSH 
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["webserver"]
}
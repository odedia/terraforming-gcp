resource "google_compute_subnetwork" "pks-subnet" {
  name          = "${var.env_name}-pks-subnet"
  ip_cidr_range = "${var.pks_cidr}"
  network       = "${var.network_name}"
  region        = "${var.region}"
}

resource "google_compute_subnetwork" "pks-services-subnet" {
  name          = "${var.env_name}-pks-services-subnet"
  ip_cidr_range = "${var.pks_services_cidr}"
  network       = "${var.network_name}"
  region        = "${var.region}"
}

// Allow access to PKS HARBOR
resource "google_compute_firewall" "cf-pks-harbor" {
  name    = "${var.env_name}-cf-pks-harbor"
  network = "${var.network_name}"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

}

// ***** PKS harbor instance

// Static IP address for forwarding rule
resource "google_compute_address" "cf-pks-harbor" {
  name = "${var.env_name}-cf-pks-harbor"
}

// TCP target pool
resource "google_compute_target_pool" "cf-pks-harbor" {
  name = "${var.env_name}-cf-pks-harbor"
  //instances = [ ] // leave commented out - not just empty - BOSH will manage thru the tile
}

// TCP forwarding rule
resource "google_compute_forwarding_rule" "cf-pks-harbor" {
  name        = "${var.env_name}-cf-pks-harbor"
  target      = "${google_compute_target_pool.cf-pks-harbor.self_link}"

  port_range  = "443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.cf-pks-harbor.address}"
}

resource "google_dns_record_set" "wildcard-pks-dns-harbor" {
  name = "harbor.pks.${var.dns_zone_dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${var.dns_zone_name}"
  ssl_certificate = "${var.ssl_cert}"

  rrdatas = ["${google_compute_address.cf-pks-harbor.address}"]
}

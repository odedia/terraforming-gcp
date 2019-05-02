resource "google_compute_address" "lb" {
  name = "${var.env_name}-${var.name}-address"

  count = "${var.count}"
}

resource "google_compute_forwarding_rule" "lb" {
  name        = "${var.env_name}-${var.name}-lb-${count.index}"
  ip_address  = "${google_compute_address.lb.address}"
  target      = "${google_compute_target_pool.lb.self_link}"
  port_range  = "${element(var.forwarding_rule_ports, count.index)}"
  ip_protocol = "TCP"

  count = "${var.count > 0 ? length(var.forwarding_rule_ports) : 0}"
}

resource "google_compute_target_pool" "lb" {
  name = "${var.lb_name}"

  health_checks = ["${google_compute_http_health_check.lb.*.name}"]

  count = "${var.count}"
}

resource "google_compute_target_pool" "cf-pks-harbor" {
  name = "${var.env_name}-cf-pks-harbor"
  instances = [ ] // leave commented out - not just empty - BOSH will manage thru the tile
}


resource "google_compute_forwarding_rule" "cf-pks-harbor" {
  name        = "${var.env_name}-cf-pks-harbor"
  target      = "${google_compute_target_pool.cf-pks-harbor.self_link}"

  port_range  = "443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.cf-pks-harbor.address}"
}



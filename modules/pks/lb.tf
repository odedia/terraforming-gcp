module "api" {
  source   = "../load_balancer"
  env_name = "${var.env_name}"
  name     = "api"

  global  = false
  count   = 1
  network = "${var.network_name}"
  ssl_certificate = "${var.ssl_cert}"

  ports                 = ["9021", "8443"]
  lb_name               = "${var.env_name}-pks-api"
  forwarding_rule_ports = ["9021", "8443"]
  health_check          = false
}



module "harbor" {
  source   = "../load_balancer"
  env_name = "${var.env_name}"
  name     = "harbor"

  global  = false
  count   = 1
  network = "${var.network_name}"
  ssl_certificate = "${var.ssl_cert}"

  ports                 = ["443"]
  lb_name               = "${var.env_name}-cf-pks-harbor"
  forwarding_rule_ports = ["443"]
  health_check          = false
}

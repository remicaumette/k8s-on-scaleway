provider "cloudflare" {
}

variable "domain" {
	type = "string"
}

resource "cloudflare_record" "master_www" {
	domain = "${var.domain}"
	name = "www"
	type = "A"
  value = "${scaleway_ip.master_ip.ip}"
	ttl = 3600
	proxied = true
}

resource "cloudflare_record" "worker_www" {
	count = "${scaleway_server.worker.count}"
	domain = "${var.domain}"
	name = "www"
	type = "A"
  value = "${element(scaleway_ip.worker_ip.*.ip, count.index)}"
	ttl = 3600
	proxied = true
}

resource "cloudflare_record" "root" {
	domain = "${var.domain}"
	name = "@"
	type = "CNAME"
  value = "www.${var.domain}"
	ttl = 3600
	proxied = true
}


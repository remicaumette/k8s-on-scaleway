provider "scaleway" {
}

variable "count" {
	type = "string"
	default = 2
}

resource "scaleway_server" "master" {
	name = "master"
	image = "2c493e89-350a-4eac-a29e-0cc7371476df"
	type = "START1-S"
	tags = ["kubernetes", "master"]
}

resource "scaleway_ip" "master_ip" {
  server = "${scaleway_server.master.id}"
}

resource "scaleway_server" "worker" {
	count = "${var.count}"
	name = "worker-${count.index + 1}"
	image = "2c493e89-350a-4eac-a29e-0cc7371476df"
	type = "START1-S"
	tags = ["kubernetes", "worker"]
}

resource "scaleway_ip" "worker_ip" {
	count = 2
  server = "${element(scaleway_server.worker.*.id, count.index)}"
}

data "template_file" "ansible_inventory" {
	template = "${file("${path.module}/hosts.tpl")}"
	vars {	
  	master = "${scaleway_ip.master_ip.ip}"
  	worker = "${join("\n", scaleway_ip.worker_ip.*.ip)}"
	}
}

resource "local_file" "ansible_inventory_file" {
	content = "${data.template_file.ansible_inventory.rendered}"
  filename = "${path.module}/../hosts"
}


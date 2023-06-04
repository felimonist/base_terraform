
resource "yandex_compute_instance" "for-each" {
  depends_on = [yandex_compute_instance.count]

  for_each = { main = {cpu=2, ram=1, fraction=20}, replica = {cpu=4, ram=2, fraction=5} }

  name = "${each.key}"

  platform_id = "standard-v1"
  resources {
    cores         = "${each.value.cpu}"
    memory        = "${each.value.ram}"
    core_fraction = "${each.value.fraction}"
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = join(":", ["ubuntu", file("~/.ssh/id_rsa.pub")])
  }

}
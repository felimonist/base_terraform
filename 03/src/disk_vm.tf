
resource "yandex_compute_disk" "disk" {
  count = 3
  name = "disk-${count.index + 1}"

  type     = "network-hdd"
  size = 1
}

resource "yandex_compute_instance" "disk-vm" {
  name = "storage"

  platform_id = "standard-v1"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.disk
    content {
      disk_id = yandex_compute_disk.disk[secondary_disk.key].id
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
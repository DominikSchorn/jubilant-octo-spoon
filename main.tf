locals {
  test = true
}

resource "random_pet" "this" {
  count = local.test ? 10 : 0
}

resource "null_resource" "this" {
  provisioner "local-exec" {
    command = "echo '192.168.0.1'"
  }
}

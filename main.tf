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

resource "azurerm_storage_account" "this" {
  name                            = "this"
  resource_group_name             = "this"
  location                        = "this"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true
}


resource "azurerm_kubernetes_cluster" "k8s" {
  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
  timeouts {
    create = "90m"
    delete = "90m"
  }

  name                      = "aks-${local.cluster_full_name}"
  location                  = var.location
  resource_group_name       = var.k8s.resource_group_name
  dns_prefix                = local.cluster_full_name
  kubernetes_version        = var.k8s.version
  node_resource_group       = "${var.k8s.resource_group_name}-nodes"
  private_dns_zone_id       = var.privatelink_dns_zone_id
  automatic_channel_upgrade = var.k8s.automatic_channel_upgrade

  // required
  default_node_pool {
    name                        = var.default_node_pool.name == "" ? substr(var.k8s.cluster_name, 0, 12) : var.default_node_pool.name # max length 12 chars
    vnet_subnet_id              = var.k8s.subnet_id
    node_count                  = var.default_node_pool.node_count
    vm_size                     = var.default_node_pool.vm_size
    os_disk_size_gb             = var.default_node_pool.disk_size_in_gb
    node_taints                 = var.default_node_pool.taints
    enable_auto_scaling         = var.default_node_pool.cluster_auto_scaling
    min_count                   = var.default_node_pool.cluster_auto_scaling_min_count
    max_count                   = var.default_node_pool.cluster_auto_scaling_max_count
    max_pods                    = var.default_node_pool.max_pod_size
    type                        = "VirtualMachineScaleSets" // muss gesetzt sein, damit man den AutoScaler aktivieren kann
    zones                       = var.default_node_pool.availability_zones
    tags                        = var.default_node_pool.tags
    temporary_name_for_rotation = var.default_node_pool.temporary_name_for_rotation
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [replace(var.managed_identity.id, "resourcegroups", "resourceGroups")]
  }

  linux_profile {
    admin_username = "k8s-admin"
    ssh_key {
      key_data = var.k8s.ssh_pub_key
    }
  }

  // required to enable network policies
  network_profile {
    network_plugin    = "kubenet"
    network_policy    = "calico"
    load_balancer_sku = "standard"
    outbound_type     = "userDefinedRouting"
  }

  # CSI Blob is requiered for accessing
  # StorageContainer for projects.
  storage_profile {
    blob_driver_enabled = var.blob_driver_enabled
  }

  dynamic "oms_agent" {
    for_each = var.k8s.applications_log_analytics_workspace_id != null ? ["oms_agent"] : []
    content {
      log_analytics_workspace_id = var.k8s.applications_log_analytics_workspace_id
    }
  }

  azure_policy_enabled = true

  # Ohne AzureAD Integration bekommt man über "az aks get-credentials" immer die Admin-kubeconfig !
  azure_active_directory_role_based_access_control {
    managed                = var.azure_active_directory.managed
    azure_rbac_enabled     = false
    admin_group_object_ids = var.azure_active_directory.admin_group_object_ids
    client_app_id          = null
    server_app_id          = null
    server_app_secret      = null
  }

  disk_encryption_set_id  = var.disk_encryption_set.id
  private_cluster_enabled = true

  tags = {
    environment = var.environment
  }
}


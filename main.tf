module "org-data" {
  source = "git@github.com:nordlb-cloud/devops-k8s-modules//schemas?ref=feat%2Fgrafana-n"
  data   = file("${path.module}/setup/org.yaml")
  schema = "org"
}

module "cluster-data" {
  source = "git@github.com:nordlb-cloud/devops-k8s-modules//schemas?ref=v1.0.22"
  data   = file("${path.module}/setup/devops.cluster.yaml")
  schema = "cluster"
}

module "cluster-data" {
  source = "git@github.com:nordlb-cloud/devops-k8s-modules//schemas?ref=incident%2Ffooo"
  data   = file("${path.module}/setup/devops.cluster.yaml")
  schema = "cluster"
}

# EKS Cluster Module
module "eks_cluster" {
  source = "./modules/eks-cluster"

  cluster_name              = var.eks_cluster_name
  cluster_version           = "1.31"
  subnet_ids                = concat(module.vpc.private_subnet_ids, module.vpc.public_subnet_ids)
  cluster_security_group_id = aws_security_group.eks_cluster.id
  endpoint_private_access   = true
  endpoint_public_access    = true
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  partition                 = data.aws_partition.current.partition
  node_group_dependency     = true

  tags = {
    Name = var.eks_cluster_name
  }
}

# EKS Node Group Module
module "eks_node_group" {
  source = "./modules/eks-node-group"

  cluster_name     = module.eks_cluster.cluster_name
  node_group_name  = "${var.eks_cluster_name}-node-group"
  subnet_ids       = module.vpc.private_subnet_ids
  desired_size     = var.eks_node_desired_size
  max_size         = var.eks_node_max_size
  min_size         = var.eks_node_min_size
  instance_types   = var.eks_node_instance_types
  eks_cluster_name = var.eks_cluster_name
  partition        = data.aws_partition.current.partition

  tags = {
    Name = "${var.eks_cluster_name}-node-group"
  }
}
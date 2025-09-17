output "cluster_id" {
  value = aws_eks_cluster.devopsshack.id
}

output "node_group_id" {
  value = aws_eks_node_group.devopsshack.id
}

output "vpc_id" {
  value = aws_vpc.devopsshack_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.devopsshack_subnet[*].id
}


output "cluster_name" {
  value = aws_eks_cluster.devopsshack.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.devopsshack.endpoint
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.devopsshack.certificate_authority[0].data
}


output "cluster_autoscaler_iam_role_arn" {
  value = aws_iam_role.cluster_autoscaler_irsa.arn
}

output "alb_controller_iam_role_arn" {
  value = aws_iam_role.alb_controller_irsa.arn
}


output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.eks.url
}



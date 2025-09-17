provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "nousath_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "nousath-vpc"
  }
}

resource "aws_subnet" "nousath_subnet" {
  count = 2
  vpc_id                  = aws_vpc.nousath_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.nousath_vpc.cidr_block, 8, count.index)
  availability_zone       = element(["ap-south-1a", "ap-south-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "nousath-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "nousath_igw" {
  vpc_id = aws_vpc.nousath_vpc.id

  tags = {
    Name = "nousath-igw"
  }
}

resource "aws_route_table" "nousath_route_table" {
  vpc_id = aws_vpc.nousath_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nousath_igw.id
  }

  tags = {
    Name = "nousath-route-table"
  }
}

resource "aws_route_table_association" "a" {
  count          = 2
  subnet_id      = aws_subnet.nousath_subnet[count.index].id
  route_table_id = aws_route_table.nousath_route_table.id
}

resource "aws_security_group" "nousath_cluster_sg" {
  vpc_id = aws_vpc.nousath_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nousath-cluster-sg"
  }
}

resource "aws_security_group" "nousath_node_sg" {
  vpc_id = aws_vpc.nousath_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nousath-node-sg"
  }
}

resource "aws_eks_cluster" "nousath" {
  name     = "nousath-cluster"
  role_arn = aws_iam_role.nousath_cluster_role.arn

  vpc_config {
    subnet_ids         = aws_subnet.nousath_subnet[*].id
    security_group_ids = [aws_security_group.nousath_cluster_sg.id]
  }
}

resource "aws_eks_node_group" "nousath" {
  cluster_name    = aws_eks_cluster.nousath.name
  node_group_name = "nousath-node-group"
  node_role_arn   = aws_iam_role.nousath_node_group_role.arn
  subnet_ids      = aws_subnet.nousath_subnet[*].id

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  instance_types = ["t2.medium"]

  remote_access {
    ec2_ssh_key = var.ssh_key_name
    source_security_group_ids = [aws_security_group.nousath_node_sg.id]
  }
}

resource "aws_iam_role" "nousath_cluster_role" {
  name = "devopsshack-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "nousath_cluster_role_policy" {
  role       = aws_iam_role.nousath_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "nousath_node_group_role" {
  name = "nousath-node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.nousath_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


resource "aws_iam_role_policy_attachment" "autoscaling_policy" {
  role       = aws_iam_role.nousath_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

resource "aws_iam_role_policy_attachment" "nousath_node_group_cni_policy" {
  role       = aws_iam_role.nousath_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "nousath_node_group_registry_policy" {
  role       = aws_iam_role.nousath_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

 set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.nousath.name
  }

  set {
    name  = "awsRegion"
    value = "ap-south-1"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "image.tag"
    value = "v1.29.0"
  }
}



resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.6.2"

  set {
    name  = "clusterName"
<<<<<<< HEAD
    value = aws_eks_cluster.nousath.name
=======
    value = aws_eks_cluster.devopsshack.name
>>>>>>> 895f931403b2461f7d21e53526f63559da862d7b
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "region"
    value = "ap-south-1"
  }

  set {
    name  = "vpcId"
<<<<<<< HEAD
    value = aws_vpc.nousath_vpc.id
  }
}
=======
    value = aws_vpc.devopsshack_vpc.id
  }
}
>>>>>>> 895f931403b2461f7d21e53526f63559da862d7b

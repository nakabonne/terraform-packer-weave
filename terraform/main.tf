resource "aws_autoscaling_group" "autoscaling_group" {
  name_prefix        = var.cluster_name
  availability_zones = ["ap-northeast-1d"]

  launch_configuration = aws_launch_configuration.weave_cluster_launchconfiguration.name

  # Run a fixed number of instances in the ASG
  min_size         = var.cluster_size
  max_size         = var.cluster_size
  desired_capacity = var.cluster_size

  tag {
    key                 = "Name"
    value               = "weave"
    propagate_at_launch = true
  }
  tag {
    key                 = "weave"
    value               = "enabled"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "weave_cluster_launchconfiguration" {
  name_prefix   = "${var.cluster_name}-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  user_data     = data.template_cloudinit_config.weave_bootstrap.rendered

  security_groups = [aws_security_group.lc_security_group.id]

  iam_instance_profile = aws_iam_instance_profile.weave_instance_profile.name

  lifecycle {
    create_before_destroy = true
  }
}

data "template_cloudinit_config" "weave_bootstrap" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.weave_bootstrap.rendered
  }
}

data "template_file" "weave_bootstrap" {
  template = file("${path.module}/scripts/bootstrap_weave.sh.tpl")
  vars = {
    aws_region = "${var.aws_region}"
  }
}

resource "aws_security_group" "lc_security_group" {
  name_prefix = var.cluster_name
  description = "Security group for the ${var.cluster_name} launch configuration"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Weave TCP for itself"
    from_port   = 6783
    to_port     = 6783
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Weave UDP for itself"
    from_port   = 6783
    to_port     = 6784
    protocol    = "udp"
    self        = true
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8 # Echo Request
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "ssm.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "weave_policy_document" {
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "ec2:DescribeInstances",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "weave_policy" {
  name        = "weave-policy"
  path        = "/"
  description = "Weave EC2 Policy"
  policy      = data.aws_iam_policy_document.weave_policy_document.json
}

resource "aws_iam_role" "weave_instance_role" {
  name               = "weave-instance-role"
  path               = "/"
  description        = "Weave EC2 Role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_instance_profile" "weave_instance_profile" {
  name = "weave-instance-profile"
  role = aws_iam_role.weave_instance_role.name
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.weave_instance_role.name
  policy_arn = aws_iam_policy.weave_policy.arn
}

resource "aws_iam_role_policy_attachment" "weave_server_ssm" {
  role       = aws_iam_role.weave_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name_prefix        = var.cluster_name
  availability_zones = ["ap-northeast-1d"]

  launch_configuration = aws_launch_configuration.launch_configuration.name

  # Run a fixed number of instances in the ASG
  min_size         = var.cluster_size
  max_size         = var.cluster_size
  desired_capacity = var.cluster_size

  tag {
    key                 = "Name"
    value               = "weave"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "launch_configuration" {
  name_prefix   = "${var.cluster_name}-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  user_data     = data.template_cloudinit_config.weave_bootstrap.rendered


  security_groups = concat(
    [aws_security_group.lc_security_group.id],
    [],
  )
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
    foo = "bar"
  }
}

resource "aws_security_group" "lc_security_group" {
  name_prefix = var.cluster_name
  description = "Security group for the ${var.cluster_name} launch configuration"
  #vpc_id      = var.vpc_id

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.lc_security_group.id
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.lc_security_group.id
}


resource "aws_security_group_rule" "allow_tcp_inbound" {
  type        = "ingress"
  from_port   = 0
  to_port     = 6783
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.lc_security_group.id
}

resource "aws_security_group_rule" "allow_udp_inbound_6783" {
  type        = "ingress"
  from_port   = 6783
  to_port     = 6784
  protocol    = "udp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.lc_security_group.id
}


resource "aws_security_group_rule" "allow_icmp_inbound" {
  type        = "ingress"
  from_port   = 8 # Echo Request
  to_port     = 0
  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.lc_security_group.id
}

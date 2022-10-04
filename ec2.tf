# Spot request for the instance considering it's just a throwaway?
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_instance_request


#----- Instance with User Data ------ #
resource "aws_instance" "master_ec2" {
  ami                    = data.aws_ami.aws_linux_ami.id # Base Amazon Linux 2`
  instance_type          = "t3.large"
  key_name               = var.ec2_key
  iam_instance_profile   = "AmazonSSMRoleForInstancesQuickSetup"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  subnet_id              = var.subnet_id
  user_data              = file("./userdata.sh")

  tags = merge({ Name = "${var.naming_prefix}-${data.aws_ami.aws_linux_ami.name}" }, var.tags)
}

#This main file contains all the resources which will be launch after applying the code.
#All the variables ,we will define in a separte tf file to kepp it simple.
#Make sure you have programatic acess for your user and enough permissions to launch resources in aws.
resource "aws_instance" "new_ec2" { 
  ami                  = var.aws_ami 
  instance_type        = var.instance_type 
  availability_zone    = var.availability_zone 
  key_name             = var.key_name 
  security_groups      = var.security_groups 
  subnet_id            = var.subnet_id 
  iam_instance_profile = var.role_name

  root_block_device { 
    volume_type           = var.ebs_type 
    volume_size           = var.ebs_size 
    delete_on_termination = var.ebs_delete 
  } 
  tags = var.tag
# We can add more resources and attach those to the ec2.
#Skip the resources if you don't need them.
  
#add EBS volumes to the ec2.
resource "aws_ebs_volume" "disks" { 
  count             = length(var.vol_list) 
  availability_zone = var.availability_zone 
  size              = lookup(var.vol_size, element(var.vol_list, count.index)) 
  tags              = var.volume_tags 
  encrypted         = true 
}
  
#Attach EBS volumes to the ec2.
resource "aws_volume_attachment" "attach-vol" { 
  count       = length(var.vol_list) 
  device_name = var.vol_list[count.index] 
  volume_id   = aws_ebs_volume.disks[count.index].id
  instance_id = aws_instance.new_ec2.id

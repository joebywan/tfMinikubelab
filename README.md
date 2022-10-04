## Minikube lab in Terraform IaC
I'm learning Kubernetes, and the machine I'm working on had issues, so I figured this is a good opportunity to keep sharp on Terraform, and dig more into bash + userdata peculiarities.

I've set it up to use SSM connect, so SSH isn't required.  You can use it if you like, just add 22 to the security_group_ports variable in variables.tf

## Pre-requisites:

* AWS Account
* VPC & subnet setup with internet gateway

## How to:
Build a terraform.tfvars with the following variables in it:

aws_account    = "awsaccountid"

role_to_assume = "rolename(case sensitive)"

subnet_id      = "subnetid"

vpc_id         = "vpcid"

### optional entries:
tags           = { "key" : "value" } <- map of tags to use on all of the infra

naming_prefix  = "prefix" <- If you want a prefix to be on all of the infra created

ec2_key        = "sshkeyname" <- Only if you think you'll be logging in via ssh.

### Commands:
Standard terraform init, plan, apply.  Give it a couple minutes to spin up and you should be able to connect & test with sudo systemctl status minikube.

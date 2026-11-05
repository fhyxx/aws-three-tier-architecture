module "network" {
  source = "./modules/network"
}

module "security_groups" {
  source     = "./modules/security-groups"
  vpc_id     = module.network.vpc_id
  admin_cidr = var.admin_cidr
}

module "compute" {
  source                = "./modules/compute"
  ami_id                = var.ami_id
  subnet_id             = module.network.public_subnet_ids[0]
  security_group_ids    = [module.security_groups.test_web_security_group_id]
  instance_profile_name = var.instance_profile_name
  user_data             = file("${path.module}/modules/compute/user_data.sh")
}

terraform {
  required_version = ">= 0.14.2"
}

variable "password" {}
variable "nb_users" {}
variable "node_count" {}
variable "email" {}

module "openstack" {
  source         = "git::https://github.com/ComputeCanada/magic_castle.git//openstack?ref=11.0"
  config_git_url = "https://github.com/ComputeCanada/puppet-magic_castle.git"
  config_version = "main"

  cluster_name = "spark"
  domain       = "calculquebec.cloud"
  image        = "CentOS-7-x64-2020-09"

  instances = {
    mgmt   = { type = "p4-7.5gb", tags = ["puppet", "mgmt", "nfs"], count = 1 }
    login  = { type = "p2-3.75gb", tags = ["login", "public", "proxy"], count = 1 }
    node   = { type = "p2-3.75gb", tags = ["node"], count = var.node_count }
  }

  volumes = {
    nfs = {
      home     = { size = 10, type = "volumes-ssd" }
      project  = { size = 50, type = "volumes-ssd" }
      scratch  = { size = 50, type = "volumes-ssd" }
    }
  }

  generate_ssh_key = true

  public_keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtK+7I+alsG4rJvg96ycHCl9Cjugww4D+UnPXCm1qi+kwq/SHyc3dXdPt1ls47jerAj3jfWx39zFovN3eyRsxG0PyMLyl2xpeYxT9BKWVqClijYKfUBj74fFsOj9ma7rw6Y7ksNXA4zL1VVhRH7vIhgjWZZO1VH1f6GYrB6sVBsjodKYQLAF+TLPJsONYOOQe8iKxdOCob/9D5nWRgIARTNGWc4m2EQAciDoZ2Qmoy0BSFs7amhMqytmFk80Ww83K2Fa4lqn/27rMb4NZlbzYKWfmnPXefzW/oa85WmFM+al95Lwg55kXWWTgOCBj1atYizLCQwZ1KSVPcn6fQVB3Yw== felix",
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQ6jCA+PeFQ3Mimz4sM7I198PYBODyBy6Pe23yz+gCbFVbZs9xwzZ/8UUC3uDJeQCOMmBcxqkH2J9EZJy+3dMPr6J8/94iizde7ouzmHP63SJ1NSg98VcqQwIQGpb16rIjV5CSWv87mkcuKC4JGA0ILeaHsKGFd7IOK/wOrywzOeIAValJsyLx/eWkOtQ/pEYHjxzePKQh1s2/OwXLUFZVLsEwu+fh//jRpuh+egKCGF85g6smVLg47ArOpTkDLSAyXO3kP+ZQxNFzA+mOu1fjK9DcQ2+hKe3tJyN3ZqGTpkbJWv8PY3W+mPNudYAMgwZVtJaq4i5QkDs8Qk06+HNb4tFt4r3ECb2Gt0QW9CebDdE4ndAHHxZ9P2TZNBLpAUb9PKQye1A7D3vuUhqAW43zeV9z+1I07QKe3oV0qDZvt2wC+pvtFF4z2Xr02CAW6sUycPFAtdHZO8ZPBPmgKE7x8fofIBBAZRtt1DANmqU0xUGk+FAneuz86SXr/y++ugDPvhZWC7+49fe0c8S8C5N78Nn4/hYMR+e0IDHF/CLkcafbnSeJGHJd2nh4VaTXc9vtJzd9EFiioyHoFMUkozgk3G2FKLpLu5JTTylW4webpsnpeHieRzewCaGIPQhaYRjv4EWAjgB0bWqaT2aW8fKeMy+JLBH+FB5x7BSa15WA/Q== charles@alfheim",
  ]

  nb_users = var.nb_users
  # Shared password, randomly chosen if blank
  guest_passwd = var.password
}

## Uncomment to register your domain name with CloudFlare
module "dns" {
  source           = "git::https://github.com/ComputeCanada/magic_castle.git//dns/cloudflare?ref=11.0"
  email            = var.email
  name             = module.openstack.cluster_name
  domain           = module.openstack.domain
  public_instances = module.openstack.public_instances
  ssh_private_key  = module.openstack.ssh_private_key
  sudoer_username  = module.openstack.accounts.sudoer.username
}

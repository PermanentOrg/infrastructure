# infrastructure

The infrastructure configuration, written using [Terraform](https://www.terraform.io), [Packer](https://www.packer.io) and [Ansible](https://www.ansible.com/).

## Install

Install [Terraform](https://www.terraform.io/downloads.html), [Packer](https://www.packer.io/downloads) and [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-debian) to get started with infrastructure provisioning.

```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update
sudo apt install terraform packer
sudo pip3 install ansible
```

Ansible can also be installed with your preferred local package manager (e.g. apt).

## Create Images
The easiest way to create an image is to use the ["Build Image" Github Action](https://github.com/PermanentOrg/infrastructure/actions?query=workflow%3A%22Build+Dev+Image%22). Image creation can also be done manually on your local machine.

```
cp .env.template .env # add your AWS access credentials
source .env && cd images && packer build dev.json
```

For Permanent employees: use the AWS access keys associated with the `build` IAM user, not the keys associated with your personal AWS account.

## Deploy Images

If you've never run Terraform before:

```
cd instances
terraform init
```

After initializing the plugins, run Terraform.

```
terraform apply
```

This command will first show you what actions it plans to execution, and then ask for confirmation. Terraform only manages resources that were created with Terraform.

## Deploy Code

New code can be deployed to the dev environment by manually triggering the ["Deploy code" Github Action](https://github.com/PermanentOrg/infrastructure/actions?query=workflow%3A%22Deploy+code+to+dev%22).

## Manage SSH access

To onboard a new user with ssh access, create a file in the `ssh` directory. The file name should be the new user's Linux username, and the file contents should be their public key(s).

To offboard a user, remove their ssh file.

In both cases, the AMI needs to be rebuilt and deployed.

```
source .env
cd images/
packer build dev.json
cd ../instances/
terraform apply
```

## Quirks

Q: Why is `ANSIBLE_PIPELINING=True` for the deploy provisioner?
A: Because `aws s3 cp` must be run as the appropriately-credentialed `deployer` user. Running an Ansible command as a non-root user requires using Ansible's `become_user`. Ansible normally writes files to a temporary filesystem initially, which requires root, but with pipelining enabled, there is no need to write to this temporary filesystem. If this sounds confusing, that's because it is. See here for more info: https://docs.ansible.com/ansible/latest/user_guide/become.html#risks-of-becoming-an-unprivileged-user

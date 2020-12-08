# infrastructure

The infrastructure configuration, written using [Terraform](https://www.terraform.io), [Packer](https://www.packer.io) and [Ansible](https://www.ansible.com/).

## Image Modification Workflow

This is the general workflow for provisioning and deploying a new images. Reasons to deploy a new image include: new operating system packages, webserver modifications, filesystem changes, onboarding a new user with SSH access, etc.

1. Create a branch with your changes to the provisioners or image builders.
2. Push your changes up to Github, and open a pull request.
3. Navigate to ["Build Images" Github Action](https://github.com/PermanentOrg/infrastructure/actions?query=workflow%3A%22Build+Images%22) and click "Run workflow", specifying your branch in the dropdown. Once you've verified that all of the images were built without issue, add a reviewer to your PR and get approval.
4. When your change is merged, head over to our [Terraform Workspaces](https://app.terraform.io/app/PermanentOrg/workspaces) and select the workspace where you would like to deploy the newly built AMIs.
5. Click "Queue plan" in the top right corner, and confirm once the workflow reaches the "Plan Finished" state.
6. Repeat steps 4-5 for each workspace once the new configuration has been rolled out across the entire fleet.

## Infrastructure Modification Worflow

The `instances` directory contains the Terraform configuration. You would want to make changes to Terraform to modify the infrastructure layout or hardware (e.g. new autoscaling groups, larger or more EC2 instances, etc). Our Terraform configuration currently manages all Permanent AMIs, EC2 instances, Autoscaling Groups, Launch Configurations, and Target Groups for the Load Balacers. Terraform does NOT manage: the Load Balancer itself, S3 buckets, SQS queues, VPCs, Security Groups, subnets, IAM, etc. To make changes to the infrastructure, push your changes to a branch, open a PR, and get a code review. Once the PR is merged, the change (depending on the directory they are in), should queue a `terraform plan` job our [Terraform Cloud organization](https://app.terraform.io/app/PermanentOrg/workspaces). Review the plan, and approve the changes if they look good. Terraform will then roll-out the new infrastructure.

## Local development
### Install required software

Install [Terraform](https://www.terraform.io/downloads.html), [Packer](https://www.packer.io/downloads) and [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-debian) to get started with infrastructure provisioning.

```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update
sudo apt install terraform packer
sudo pip3 install ansible
```
Ansible can also be installed with your preferred local package manager (e.g. apt).

### Create Images
The easiest way to create an image is to use the ["Build Images" Github Action](https://github.com/PermanentOrg/infrastructure/actions?query=workflow%3A%22Build+Dev+Image%22).
Image creation can also be done manually on your local machine. The following example illustrates the steps for building the cron image.

```
cp .env.template .env # add your AWS access credentials
source .env && cd images && packer build -var-file=cron.json image.json
```

For Permanent employees: use the AWS access keys associated with the `build` IAM user, not the keys associated with your personal AWS account.

### Deploy Images

Images should generally only be deployed using [Terraform Cloud](https://app.terraform.io/app/PermanentOrg/workspaces). If you'd like to bring up a single image for a small test, do so using the AWS console.

## Deploy Code

Code deployment can be initiated by manually triggering the ["Deploy code" Github Action](https://github.com/PermanentOrg/infrastructure/actions?query=workflow%3A%22Deploy+code+to+dev%22).

## Manage SSH access

To onboard a new user with ssh access, create a file in the `ssh` directory. The file name should be the new user's Linux username, and the file contents should be their public key(s).

To offboard a user, remove their ssh file.

In both cases, the AMIs needs to be rebuilt and deployed. See [Workflow](#Workflow) for more details.

## Debian Version

We use the latest Debian base image published [here](https://wiki.debian.org/Cloud/AmazonEC2Image/Buster) for our builds.

## Autoscaling

There was an initial attempt to configure autoscaling for the staging and production deployments. That attempt can be found in the [staging Terraform configuration in the "autoscaling" branch](https://github.com/PermanentOrg/infrastructure/blob/autoscaling/instances/staging/main.tf#L58). There are [several open issues](https://github.com/PermanentOrg/infrastructure/projects/1) that are prerequisites for the rollout of autoscaling.

The current configuration simply brings up regular EC2 instances directly.

## Quirks

Q: Why is `ANSIBLE_PIPELINING=True` for the deploy provisioner?
A: Because `aws s3 cp` must be run as the appropriately-credentialed `deployer` user. Running an Ansible command as a non-root user requires using Ansible's `become_user`. Ansible normally writes files to a temporary filesystem initially, which requires root, but with pipelining enabled, there is no need to write to this temporary filesystem. If this sounds confusing, that's because it is. See here for more info: https://docs.ansible.com/ansible/latest/user_guide/become.html#risks-of-becoming-an-unprivileged-user

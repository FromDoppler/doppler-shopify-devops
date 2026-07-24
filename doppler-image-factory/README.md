# Image Factory w/Ansible and Packer

## Prerequisites

The server configuration is automated with Ansible and the image creation is automated with Packer.

Install these tools before running the workflow:

- `ansible`
- `packer`
- `aws cli`
- `python3`
- `python3-venv`
- `git`

After installing Packer, also install the required plugins:

```bash
packer plugins install github.com/hashicorp/amazon
packer plugins install github.com/hashicorp/ansible
```

Clone the repository on your desired folder:

```bash
git clone git@github.com:FromDoppler/doppler-shopify-devops.git
cd doppler-shopify-devops/doppler-image-factory
```

## Variables that need to be exported

- `AWS_ACCOUNT`: account where the image will be created.
- `AWS_REGION`: region where the image will be created.
- `AWS_PROFILE`: AWS CLI profile with permission to assume `automation_role`.
- `VAULT_SECRET`: Ansible secret used to decrypt the encrypted vault.

```bash
export AWS_ACCOUNT='12345678'
export AWS_REGION='us-west-2'
export AWS_PROFILE='my-profile'
export VAULT_SECRET='DummyV4uL7S3cR37'
```

## Python environment for `ami`

The `ami` helper uses Python 3 and `boto3`. On recent Linux distributions, `boto3` is usually easier to manage inside a virtual environment.

Example:

```bash
python3 -m venv ~/doppler-ami-venv
source ~/doppler-ami-venv/bin/activate
pip install boto3
```

With the virtual environment active, run the helper as:

```bash
python ./ami list base
python ./ami list siab
```

## Directory structure

- `ansible`: roles and playbooks to configure the servers used by this platform.
- `helpers`: tools and scripts to handle AWS AMIs.
- `packer`: configuration files and playbooks used by Packer to build server images.

## Workflow

We use wrappers around Packer and AWS to create images and promote them between environments in a controlled way.

1. Add or update your Ansible roles in `ansible/roles`.
2. If needed, reference community roles in `ansible/requirements.yml`.
3. Update the main Packer playbook `packer/playbook.yml`, including the required roles and vars.
4. Commit and push your changes.
5. Build the base image:

```bash
./packer_base.sh base
```

6. Validate that the base image was created:

```bash
python ./ami list base
```

7. Build the SIAB image:

```bash
./packer.sh siab
```

8. List the generated SIAB image:

```bash
python ./ami list siab
```

9. Promote the AMI so it can be approved for the target environment:

```bash
python ./ami promote UUID_DE_LA_IMAGEN qa
```

10. After promotion, use Terraform to apply that approved image in the target environment.

Promoting an AMI does not make an existing instance start using it automatically. The new image is used after Terraform updates the infrastructure and the corresponding instance is replaced or rotated.

## Image baseline

The current base image for this repository is built on Ubuntu 22.04.

For the Shopify environment:

- PHP target version is `8.2`
- `xmlrpc` is not part of the installed PHP package set

## Troubleshooting

- `ami list` or `ami promote` can fail if the AWS credentials behind `AWS_PROFILE` cannot assume `automation_role`. Make sure the profile has permission to call `sts:AssumeRole` for that role.

## AMI types we created for this project

| AMI type | Description                                         | Usage                                                                                                             |
| -------- | --------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `siab`   | Stack-in-a-box servers, including app and databases | Terraform uses this image to create standalone all-in-one servers for smaller environments such as `dev` and `qa` |

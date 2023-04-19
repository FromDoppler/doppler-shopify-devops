# Image Factory w/Ansible and Packer

## Install Ansible

The server configuration has been automated using Ansible. You can download it from [here](https://www.ansible.com/).

The images creation has been automated using Packer. You can download it [here](https://www.packer.io/downloads.html).

- Download these tools packages for your OS.
- Clone this repo below on your desired folder.

```bash
git git@github.com:FromDoppler/doppler-shopify-devops.git
cd doppler-shopify-devops
```

## Variables that need to be exported

- AWS_ACCOUNT - Account in where we will be working on.
- AWS_REGION - Region in where we will be working on.
- AWS_PROFILE - AWS cli profile with the proper trusted relationship to assume automation_role
- VAULT_SECRET - Ansible secret to decrypt the encrypted vault.

```
export AWS_ACCOUNT='12345678'
export AWS_REGION='us-west-2'
export AWS_PROFILE='my-profile'
export VAULT_SECRET='DummyV4uL7S3cR37'
```

## Directory structure

- ansible: roles and playbooks to configure any type of server needed for this platform.
- helpers: tools and scripts to handle AWS AMIS.
- packer: configuration files and main playbooks for Packer to build server images.

## Workflow

We have developed some wrappers around Packer and AWS to allow us to create the images in a safe way, including the promotion of these artifacts between the different environments. Typical steps to end up with an AMI for a new type of server would be something like this:

1. Add your Ansible roles to `ansible/roles`
2. You could also make use of community roles by referencing them in `ansible/requirements.yml`
3. Add your new host definition to the main Packer playbook `packer/playbook.yml`, including roles and vars.
4. Commit and push
5. Create your new server image. For example, this will create a new AMI for the SIAB type of server:

```bash
./packer_base.sh base (to build base image)
./packer.sh siab
```

6. See the image you just created in a list:

```bash
./ami list siab

+--------------------------------------+-----------------+-----------------------+----------+----------------------+--------------+
| UUID                                 | Name            | us-east-2             | Approved | Date                 | Commit       |
+--------------------------------------+-----------------+-----------------------+----------+----------------------+--------------+
| ED818119-43B2-4035-828F-FCF7CEA11A58 | siab-1629852160 | ami-00b1dccea2f8a5d62 | qa       | 2021-08-25T00:42:40Z | 342e34c-dirty|
+--------------------------------------+-----------------+-----------------------+----------+----------------------+--------------+
Total: 1 row/s
```

7. Promote the AMI so it can be used in the environment you need:

```bash
./ami promote 691BE40D-81F1-4021-89C1-B1BAA4382C45 dev
```

8. Your AMI is now ready to be used by your Terraform code

## AMI types we created for this project

| AMI type | Description                                       | Usage                                                                                                         |
| -------- | ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| siab     | For Stack-in-a-box servers, including app and dbs | Terraform will use this image to create standalone, all-in-one server for minor environments, like DEV and QA |

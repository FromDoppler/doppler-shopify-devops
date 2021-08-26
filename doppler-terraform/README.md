# Terraform

## Install Terraform

The AWS infrastructure has been automated using Terraform, you can download from [here](https://www.terraform.io/).

- Download installation package for your OS. Recommended version = 0.10.7.
- Clone this repo on your desired folder.

```bash
git git@github.com:FromDoppler/doppler-shopify-devops.git
cd doppler-shopify-devops
```

## Prerequisites

Before running these commands, Terraform assumes you have an AWS user on your home directory ~/.aws configured with enough rights to run.

## Build

With the following commands you will be able to build the whole environment at AWS:

```
./terraform.sh init ${ENVIRONMENT} ${STACK}
./terraform.sh plan ${ENVIRONMENT} ${STACK}
./terraform.sh apply ${ENVIRONMENT} ${STACK}
```

When running the first time, follow this order:

1. operations / vpc
2. operations / iam

Then other environments, for example:

1. production / siab
2. qa / siab

Example:

```
./terraform.sh init operations vpc
./terraform.sh init operations iam
```

## What is "siab"

"siab" is the acronym of Stack in a Box, this is intended to keep as simple and smallest as this is needed to avoid higest AWS costs.

If any modification is required, you will need to run the same commands again after making your changes and push the code to the repo.

## Resource Targeting

The `-target` option can be used to focus Terraform's attention on only a subset of resources during plan. Example:

```
./terraform.sh plan qa siab -target='aws_instance.siab'
```

## Destroy

DO NOT DO THIS!!! It will delete everything on AWS for ever.

```
terraform destroy
```

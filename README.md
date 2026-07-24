# doppler-shopify-devops

## Repository structure

```
 ./
  |- .gitignore
  |- README.md
  |- doppler-image-factory/
  |- doppler-terraform/
```

This repository is split into two operational areas:

- [Doppler - Image Factory](https://github.com/FromDoppler/doppler-shopify-devops/tree/main/doppler-image-factory): build and promote AMIs with Packer and Ansible.
- [Doppler - Terraform](https://github.com/FromDoppler/doppler-shopify-devops/tree/main/doppler-terraform): apply the infrastructure that consumes those images in AWS.

Use each subdirectory README as the source of truth for its workflow:

- `doppler-image-factory/README.md` for AMI build and promotion.
- `doppler-terraform/README.md` for infrastructure initialization, planning, and apply flows.

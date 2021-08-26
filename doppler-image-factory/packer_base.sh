#!/usr/bin/env bash
set -e


usage() {
  echo "Uso: $0 <image> [args...]"
  echo " e.g.: $0 base"
  echo "Requiere la variable AWS_PROFILE y VAULT_SECRET seteadas"
  exit 1
}

if [ -z "$1" ];then
  usage
fi

if [ -z "$AWS_PROFILE" ];then
  echo "La variable AWS_PROFILE no está seteada..."
  usage
fi

if [ -z "$VAULT_SECRET" ];then
  echo "La variable VAULT_SECRET no está seteada"
  usage
fi

export IMAGE=$1
shift 1

ACCOUNT=129106826746
export AWS_REGION="${AWS_REGION:-us-east-1}"

get_git_describe_with_dirty() {
  # produces abbrev'ed SHA1 of HEAD with possible -dirty suffix

  local D=$(git describe --all --dirty)
  local SHA1=$(git show-ref -s --abbrev refs/${D%-dirty})
  echo ${D/${D%-dirty}/$SHA1}
}

: ${BUILD_UUID:=$(uuidgen)}
GIT_COMMIT=$(get_git_describe_with_dirty)


run_packer() {
  set -x
  local UUID=$1 GIT_COMMIT=$2; shift 2
  packer build \
      -var "git_commit=$GIT_COMMIT" \
      -var "build_uuid=$UUID" \
      -var "image_name=$IMAGE" \
      packer/aws_base.json
  set +x
}

run_packer $BUILD_UUID $GIT_COMMIT "$@"

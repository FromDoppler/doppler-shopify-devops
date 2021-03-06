#!/usr/bin/env bash
set -e

WORKSPACE_ROOT="workspace"
ENVIRONMENT_ROOT="environment"

usage() {
  echo "Usage: $0 <action> <environment> <stack> [args...]"
  echo " e.g.: $0 plan integration"
  echo " "
  echo "    <action> = init|plan|plan-destroy|apply"
  exit 1
}

if [ ${#} -lt 3 ]; then
 usage
fi

if [ -z "$AWS_PROFILE" ];then
  if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ];then
    echo "AWS_PROFILE or access keys (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) are not set"
    usage
  fi  
fi

export ACTION=$1
export CONFIG=$2
export STACK=$3

shift 3

set_backend_variables() {
  REGION=$(awk -F\" '/aws_region/{print $2}'  "environment/$CONFIG.tfvars")
  ACCOUNT=$(awk -F\" '/account/{print $2}'  "environment/$CONFIG.tfvars")
  ENVIRONMENT=$(awk -F\" '/environment /{print $2}'  "environment/$CONFIG.tfvars" | tr -d '\n')
  BUCKET="$(awk -F\" '/^tf_bucket/{print $2}'  "environment/$CONFIG.tfvars")"
  echo "Using bucket [$BUCKET] for account [$ACCOUNT]"
}

set_backend_variables
WORKDIR="$WORKSPACE_ROOT/$ACCOUNT-$REGION-$ENVIRONMENT-$STACK"
DEBUG_OUT="Environment: $ENVIRONMENT Region: $REGION"

export AWS_REGION=$REGION

case ${ACTION} in
init)
  if [ -e "$WORKDIR" ]
  then
    echo "Re-Inititializing $DEBUG_OUT"
    cd "$WORKDIR"
    terraform init \
      -backend-config "bucket=$BUCKET" \
      -backend-config "key=$REGION/$ENVIRONMENT/$STACK/terraform.tfstate" \
      -backend-config "region=${REGION}"
  else
    echo "Inititializing $DEBUG_OUT"
    mkdir -p "$WORKDIR"
    cd "$WORKDIR"
    terraform init  \
      -backend-config "bucket=$BUCKET" \
      -backend-config "key=$REGION/$ENVIRONMENT/$STACK/terraform.tfstate" \
      -backend-config "region=${REGION}" \
      "../../terraform/$STACK/"
  fi
  ;;
clean)
  echo "Cleaning workspace for $DEBUG_OUT"
  rm -rf "$WORKDIR"
  ;;
plan)
  [ -e "$WORKDIR" ] || {
      echo >&2 "Please run init first"
      exit 1
  }
  echo "Planning for $DEBUG_OUT"

  cp "$ENVIRONMENT_ROOT/$CONFIG.tfvars" "$WORKDIR/terraform.tfvars"
  rsync -ar --no-links "terraform/$STACK/" "$WORKDIR/"
  cd "$WORKDIR"
  terraform plan -out "$ENVIRONMENT.tfplan" "$@"
  ;;
plan-destroy)
  echo "Planning destruction of $DEBUG_OUT"
  [ -e "$WORKDIR" ] || {
      echo >&2 "Please run init first"
      exit 1
  }
  cp "$ENVIRONMENT_ROOT/$CONFIG.tfvars" "$WORKDIR/terraform.tfvars"
  rsync -ar --no-links "terraform/$STACK/" "$WORKDIR/"
  cd "$WORKDIR"
  terraform plan -destroy -out "$ENVIRONMENT.tfplan" "$@"
  ;;
apply)
  [ -e "$WORKDIR/$ENVIRONMENT.tfplan" ] || {
      echo >&2 "No $ENVIRONMENT.tfplan found - please run plan or plan-destroy mode first"
      exit 1
  }
  echo "Applying for $DEBUG_OUT"
  cd "$WORKDIR"
  terraform apply "$ENVIRONMENT.tfplan"
  ;;
esac

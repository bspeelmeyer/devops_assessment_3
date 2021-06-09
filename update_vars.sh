#!/bin/bash
####
# commands to retieve cluster vpc_id and subnet ids
####
vpc_id=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=rmit.k8s.local --query Vpcs[*].VpcId --output text)
subnet_id0=$(aws ec2 describe-subnets --filters Name=tag:KubernetesCluster,Values=rmit.k8s.local --query Subnets[0].SubnetId --output text)
subnet_id1=$(aws ec2 describe-subnets --filters Name=tag:KubernetesCluster,Values=rmit.k8s.local --query Subnets[1].SubnetId --output text)

####
# commands to update variables in the terraform vars file
####
cd infra
sed -i 's/<<vpc_id>>/'"$vpc_id"'/g' terraform.tfvars
sed -i 's/<<subnet_id_0>>/'"$subnet_id0"'/g' terraform.tfvars
sed -i 's/<<subnet_id_1>>/'"$subnet_id1"'/g' terraform.tfvars
cd ..

####
# command to get terraform output
####
ecr_repo=$(cd bootstrap && terraform output repository-url)

####
# command to split terraform output to insert into circle ci config file
####
IFS='/'
read -a strarr <<< $ecr_repo
cd .circleci
sed -i 's/<<ECR>>/'${strarr[0]}\"'/g' config.yml
sed -i 's/<<reponame>>/'\"${strarr[1]}'/g' config.yml

####
# command to get terraform output
####
x=$(cd ../bootstrap && terraform output kops_state_bucket_name)
####
# command to remove qoutes from output
####
tmp="${x%\"}"
kops_bucket="${tmp#\"}"
####
# command to update kops state bucket name in circle ci config file
####
sed -i 's/<<kops_bucket_name>>/'$kops_bucket'/g' config.yml

####
# command to get infra state bucket and state lock files
####

y=$(cd ../bootstrap && terraform output tf_state_bucket)
tmp1="${y%\"}"
tf_state_bucket="${tmp1#\"}"

z=$(cd ../bootstrap && terraform output dynamoDb_lock_table_name)
tmp2="${z%\"}"
tf_state_lock="${tmp2#\"}"

####
# command to update infra state bucket and state lock files
####
cd ../infra
sed -i 's/<<state-file>>/'$tf_state_bucket'/g' Makefile
sed -i 's/<<state-lock>>/'$tf_state_lock'/g' Makefile


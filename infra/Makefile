up:
	terraform apply --auto-approve -var environment=${ENV}

down:
	terraform destroy --auto-approve -var environment=${ENV}

init:
	terraform init --backend-config="key=state/${ENV}.tfstate" --backend-config="dynamodb_table=rmit-tfstate-h1tmw7" --backend-config="RMIT-locktable-h1tmw7"

# AWS SSO Configuration Variables
AWS_PROFILE_NAME = cdubs-storage
AWS_SSO_START_URL = https://d-9067d61c22.awsapps.com/start/
AWS_SSO_REGION = us-east-1
AWS_SSO_ACCOUNT_ID = 729403197604
AWS_SSO_ROLE_NAME = Administrator
AWS_REGION = us-east-1
AWS_OUTPUT = json

# AWS Configuration Paths
AWS_CONFIG_DIR = ~/.aws
AWS_CONFIG_FILE = $(AWS_CONFIG_DIR)/config

# Add AWS SSO profile to ~/.aws/config
add-aws-sso-profile:
	@echo "Adding AWS SSO profile to $(AWS_CONFIG_FILE)..."
	@mkdir -p $(AWS_CONFIG_DIR)
	@if [ ! -f $(AWS_CONFIG_FILE) ]; then \
		touch $(AWS_CONFIG_FILE); \
		echo "Created new $(AWS_CONFIG_FILE) file"; \
	fi
	@if grep -q "\[profile $(AWS_PROFILE_NAME)\]" $(AWS_CONFIG_FILE); then \
		echo "AWS SSO profile $(AWS_PROFILE_NAME) already exists"; \
	else \
		echo "" >> $(AWS_CONFIG_FILE); \
		echo "[profile $(AWS_PROFILE_NAME)]" >> $(AWS_CONFIG_FILE); \
		echo "sso_start_url = $(AWS_SSO_START_URL)" >> $(AWS_CONFIG_FILE); \
		echo "sso_region = $(AWS_SSO_REGION)" >> $(AWS_CONFIG_FILE); \
		echo "sso_account_id = $(AWS_SSO_ACCOUNT_ID)" >> $(AWS_CONFIG_FILE); \
		echo "sso_role_name = $(AWS_SSO_ROLE_NAME)" >> $(AWS_CONFIG_FILE); \
		echo "region = $(AWS_REGION)" >> $(AWS_CONFIG_FILE); \
		echo "output = $(AWS_OUTPUT)" >> $(AWS_CONFIG_FILE); \
		echo "AWS SSO profile $(AWS_PROFILE_NAME) added successfully"; \
	fi


create-ssh-key:
	ssh-keygen -t ed25519 -C "christopher@kali"
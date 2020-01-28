# File in which we expect the Ansible Vault password
CRYPT_SECRET ?= $(ROOT_DIR)/.ansible-vault-password

# Ansible Vault command shortcut
ANSIBLE_VAULT = ansible-vault

# This will decrypt any .env targets automatically (requires there is a .env.enc available).
%/.env: %/.env.enc | $(CRYPT_SECRET)
	$(__DECRYPT)

## .ansible-vault-password: Creates the Ansible Vault secret file
$(CRYPT_SECRET):
	@exec < /dev/tty && \
	echo -n "Please input Ansible Vault password: " && \
	read -s response && \
	echo $$response > $@ && \
	exec <&-

# Helpers

__DECRYPT = \
	$(info Decrypting $< to $@) \
	$(ANSIBLE_VAULT) decrypt --vault-id $(CRYPT_SECRET) --output $@ $<

__CRYPT = \
	$(info Encrypting $< to $@) \
	$(ANSIBLE_VAULT) encrypt --vault-id $(CRYPT_SECRET) --output $@ $<

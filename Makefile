.PHONY: build

docker-build:
	docker build -t bulletin-board:latest .

docker-run:
	docker run -d -p 8080:8080 --name bulletin-board

docker-stop:
	docker stop bulletin-board

setup-roles:
	ansible-galaxy install -r requirements.yml --force

lint:
	ansible-playbook -i inventory.ini application-playbook.yml --vault-password-file ./vault_pass.txt  --syntax-check
	@echo "---------------"
	ansible-playbook -i inventory.ini observability-playbook.yml --vault-password-file ./vault_pass.txt --syntax-check

smoke:
	ansible all -i inventory.ini -m ping --vault-password-file ./vault_pass.txt
	ansible webservers -i inventory.ini -m shell -a "curl -fsS http://127.0.0.1/ >/dev/null" --vault-password-file ./vault_pass.txt
	ansible webservers -i inventory.ini -m shell -a "curl -fsS http://127.0.0.1:{{ actuator_port }}/actuator/health >/dev/null" --vault-password-file ./vault_pass.txt
	ansible monitoring -i inventory.ini -m shell -a "curl -fsS http://127.0.0.1:{{ prometheus_port }}/-/healthy" --vault-password-file ./vault_pass.txt
	ansible monitoring -i inventory.ini -m shell -a "curl -fsS http://127.0.0.1:{{ loki_port }}/ready" --vault-password-file ./vault_pass.txt
	ansible monitoring -i inventory.ini -m shell -a "curl -fsS http://127.0.0.1:{{ grafana_port }}/api/health" --vault-password-file ./vault_pass.txt

deploy:
	ansible-playbook -i inventory.ini application-playbook.yml --vault-password-file ./vault_pass.txt

observ:
	ansible-playbook -i inventory.ini observability-playbook.yml --vault-password-file ./vault_pass.txt

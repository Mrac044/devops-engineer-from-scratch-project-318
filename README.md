### Hexlet tests and linter status:
[![Actions Status](https://github.com/Mrac044/devops-engineer-from-scratch-project-318/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/Mrac044/devops-engineer-from-scratch-project-318/actions)

## Команды запуска

`make setup-roles` - устанавливает необходимые ansible-роли (применить до запуска плейбука и деплоя)

`make deploy` - запускает плейбук на всех хостах из inventory.ini, настраивает сервер (устанавливает сервер, применяет стандартные сетевые политики безопасности), разворачивает контейнеры с приложением, кластером Postgres, nginx в режиме reverse proxy.

### Стандарный адрес сервера

IPv4: 158.160.224.83
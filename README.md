### Hexlet tests and linter status:
[![Actions Status](https://github.com/Mrac044/devops-engineer-from-scratch-project-318/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/Mrac044/devops-engineer-from-scratch-project-318/actions)

### Команды запуска

`make setup-roles` - устанавливает необходимые ansible-роли (применить до запуска плейбука и деплоя)

`make deploy` - запускает плейбук на всех хостах из inventory.ini, настраивает сервер (устанавливает сервер, применяет стандартные сетевые политики безопасности), разворачивает контейнеры с приложением, кластером Postgres, nginx в режиме reverse proxy.

### Стандарный адрес сервера

IPv4: 158.160.224.83

### Необходимые метрики node_exporter

| **Группа** | **Основные метрики** |
| :---: | --- |
| **CPU** | `node_cpu_seconds_total`, `node_load1`, `node_load5`, `node_load15`
| **Память** | `node_memory_MemTotal_bytes`, `node_memory_MemAvailable_bytes`, `node_memory_SwapFree_bytes`
| **Диски** | `node_filesystem_avail_bytes`, `node_filesystem_size_bytes`, `node_disk_read_bytes_total`, `node_disk_written_bytes_total`, `node_disk_io_time_seconds_total`
| **Сеть** | `node_network_receive_bytes_total`, `node_network_transmit_bytes_total`, `node_network_receive_errs_total`, `node_network_transmit_errs_total`
| **Процессы** | `node_procs_running`, `node_procs_blocked`, `node_forks_total`
| **Системные сервисы** | `node_systemd_unit_state`, `node_systemd_units`
| **Доступность exporter** | `up`

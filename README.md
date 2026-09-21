### Hexlet tests and linter status:
[![Actions Status](https://github.com/Mrac044/devops-engineer-from-scratch-project-318/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/Mrac044/devops-engineer-from-scratch-project-318/actions)


## Infrastructure

### Команды запуска

`make setup-roles` - устанавливает необходимые ansible-роли (применить до запуска плейбука и деплоя)

`make deploy` - настройка application сервера, стандартные сетевые политики, развёртывание приложения и сервисов

`make observ` - настройка monitoring сервера, стандартные сетевые политики, развёртывание сервисов мониторинга (метрики, логи)

### Общая архитектура

```
+-------------------------------+        +-------------------------------+
|          App VM (YC)          |        |       Monitoring VM (YC)      |
|-------------------------------|        |-------------------------------|
| Spring service (Docker)       |        | Prometheus                    |
| PostgreSQL                    |        | Grafana                       |
| Nginx reverse proxy           |        | Loki                          |
| Actuator :9090                |        | Grafana Alerting              |
| Node Exporter                 |        |                               |
| nginx-prometheus-exporter     |        |                               |
| Promtail                      |        |                               |
+-------------------------------+        +-------------------------------+
               |                                        |
               +----------- private network ------------+

Потоки данных:

* Prometheus ← метрики: Actuator, Node Exporter, nginx-prometheus-exporter
* Loki ← логи: Promtail собирает JSON-логи приложения и Nginx
* Grafana → дашборды и LogQL-запросы поверх Prometheus и Loki
* Alerting → уведомления в выбранный канал (почта, ntfy, Telegram)
```

### Backend

#### Архитектура предполагает наличие двух серверов:

- Application-server: spring app, postgresql, nginx reverse proxy, actuator:9090, node exporter, nginx-prometheus-exporter, promtail.

- Monitoring-server: prometheus, grafana, loki, grafana alerting.

#### И одно object storage

- S3-storage: application pictures

#### Требования к ресурсам:

- OS: Ubuntu 24.04 LTS
- CPU: 2+
- RAM: 2GB+
- DISK: 20GB+

### Переменные окружения

*Большая часть определена при запуске контейнеров*

### Переменные vault:

- db_password: "<пароль базы данных>"
- s3_bucket: "<имя S3>"
- s3_id: "<идентификатор S3>"
- s3_secret_key: "<приватный ключ S3>"
- s3_region: "<регион S3>" 
- admin_email: "<адрес электронной почты>"
- metrics_password: "<пароль метрик приложения>"
- grafana_admin_password: "<пароль входа grafana>"
- smtp_password: "<пароль для внешних приложений>"


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

### Observability endopoints

`/actuator/prometheus` - метрики в формате Prometheus
`/actuator/metrics` - доступные метрики
`/actuator/health/liveness` - жив ли сервис
`/actuator/health/readiness` - готов ли сервис принимать трафик

### Проверка метрик приложения

`curl http://<app-host>:9090/actuator/prometheus`

### Prometheus web interface

`http://84.201.147.72:9090`
*Закрыт от внешнего доступа, для доступа к monitoring используйте grafana*

### Grafana web interface

`http://84.201.147.72:3000`

Grafana login: `admin`

### Подключение почты для алертов

Для указания почты используются переменные окружения, которые должны быть проброшены в контейнер grafana, который запускается в observability-playbook.yml:
  ```yml
  # Укажите smtp сервер вашей почты, в примере использован mail.ru, не забудьте указать порт
  GF_SMTP_HOST: "smtp.mail.ru:465"
  # Адрес вашей почты в формате "example@mail.com", в данном случае подставляется через переменную
  GF_SMTP_USER: "{{ admin_email }}"
  # Сгенерируйте токен доступа для внешний приложений в своей почте и добавьте его в vault.yml, или используйте иные способы хранения секретов
  GF_SMTP_PASSWORD: "{{ smtp_password }}"
  # От этого имени будут приходить алерты
  GF_SMTP_FROM_ADDRESS: "{{ admin_email }}"
  ```

### Просмотр alert rules и тестовый alert

- Для просмотра alert rules в веб-интерфейсе grafana в контекстном меню: 

    **Alerting --> Alert rules --> Grafana-managed**

    *Тут собраны правила, которые контролируются grafana, также могут быть другие источники, данное приложение включает в себя prometheus-rules*

- Для отправки тестового алерта:

    **Alerting --> Manage contact points**

    Нажмите `edit` у канала, который хотите протестировать, или создайте собственный. 

    За отправку тестового сообщения отвечает кнопка `Test`.

### Nginx exporter

- Проверка статуса nginx

  На application-сервере: `curl localhost:80/stub_status`

## Деплой "с нуля"

### 1. Клонирование репозитория

Репозиторий с ansible-плейбуками должна находится внутри репозитория приложения.

`git clone https://github.com/Mrac044/project-devops-deploy.git && cd project-devops-deploy`

`git clone https://github.com/Mrac044/devops-engineer-from-scratch-project-318.git`

### 2. Подготовка ВМ

Подготовьте, минимум, две ВМ с указанными выше рекомендоваными ресурсами.

Добавьте их IP в inventory.ini и внутренные адреса в group_vars/all/monitoring

> Сетевой доступ между ними обеспечивается по приватным адресам VPC.

### 3. Подготовка ssh-доступа

Сгенерируйте ssh ключ и скопируйте публичный на оба сервера.

`ssh-keygen -t ed25519`

`ssh-copy-id <user>@<app-server-ip>`
`ssh-copy-id <user>@<monitoring-server-ip>`

В invenroty.ini укажите путь до приватного ключа для каждой записи

`ansible_ssh_private_key_file=~/.ssh/id_ed25519`

### 4. Создание vault

Создайте файл с секретами

`ansible-vault create group_vars/all/vault.yml`

Добавьте требуемые переменные:

```yml
db_password: "..."
s3_bucket: "..."
s3_id: "..."
s3_secret_key: "..."
s3_region: "..."
admin_email: "..."
metrics_password: "..."
grafana_admin_password: "..."
smtp_password: "..."
```

### 5. Установка зависимостей

Установка нужных ansible ролей
> Выполнить до deployment.

`make setup-roles`

### 6. Доставка приложения

`make deploy`

- Настраивает сервер
- Устанавливает сетевые политики
- Устанавливает системные компоненты
- Устанавливает демон node_exporter
- Запускает контейнер PostgreSQL-db
- Запускает контейнер приложения
- Запускает контейнер и конфигурацию nginx
  - Запускает контейнер nginx-prometheus-exporter
- Запускает контейнер promtail

### 7. Настройка observability

`make observ`

- Устанавливает сетевые политики
- Запускает контейнер Prometheus
- Запускает контейнер Grafana
- Запускает контейнер Loki

### Проверка

`make smoke`

- Проверяет доступность серчеров через ping
- Проверяет доступность:
  - Приложения
  - Prometheus
  - Loki
  - Grafana
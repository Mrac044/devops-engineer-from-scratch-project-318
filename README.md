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

### Observability endopoint

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

    *Тут собраны правила, которые контролируются grafana, также могут быть у другие источники, данное приложение включает в себя prometheus-rules*

- Для отправки тестового алерта:

    **Alerting --> Manage contact points**

    Нажмите `edit` у канала, который хотите протестировать, или создайте собственный. 

    За отправку тестового сообщения отвечает кнопка `Test`.
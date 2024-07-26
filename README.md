 # Задание можно посмотреть по ссылке:
### [Задание Дипломной работы](https://github.com/netology-code/sys-diplom)

# 1. Для развертки инфраструкты используем Terraform:
### [Конфигурационный файл Terraform main.tf](https://github.com/ZetIxzet/sys-diplom/blob/main/diplom/terraform/main.tf)
### [Файл с настройками пользователя meta.txt](https://github.com/ZetIxzet/sys-diplom/blob/main/diplom/terraform/meta.yml)

### Созданная инфраструктура на yandex.cloud:
![yandex.cloud](https://github.com/ZetIxzet/sys-diplom/blob/main/image/ya%20cloud%20all.png)
![yandex.cloud](https://github.com/ZetIxzet/sys-diplom/blob/main/image/ya%20cloud%20vm.png)
![yandex.cloud](https://github.com/ZetIxzet/sys-diplom/blob/main/image/ya%20cloud%20router.png)
![yandex.cloud](https://github.com/ZetIxzet/sys-diplom/blob/main/image/ya%20cloud%20tg%20group.png)
![yandex.cloud](https://github.com/ZetIxzet/sys-diplom/blob/main/image/ya%20cloud%20balancer.png)
![yandex.cloud](https://github.com/ZetIxzet/sys-diplom/blob/main/image/ya%20cloud%20backend-group.png)

### Было созданно 6 виртуальных машин на базе Ubuntu, Балансировщик, Target Group, Backend Group, HTTP-router

# 2. С помощью Ansible(развёрнут на bastion-vm) устанавливаем и настраиваем нужные нам сервисы на хостах:

### [Конфигурационный файлы Ansible](https://github.com/ZetIxzet/sys-diplom/tree/main/diplom/ansible)

# 3. Проверяем доступность сайта (curl -v <публичный IP балансера>)

Адрес сайта: 
http://51.250.40.222:80/

![web1](https://github.com/ZetIxzet/sys-diplom/blob/main/image/curl%20web1.png)
![web2](https://github.com/ZetIxzet/sys-diplom/blob/main/image/curl%20web2.png)

## 4. Мониторинг Zabbix
![Zabbix](https://github.com/ZetIxzet/sys-diplom/blob/main/image/zabbix.png)

Zabbix доступен по ссылке:
http://89.169.131.26:8080/zabbix.php?action=dashboard.view&dashboardid=346&from=now-1h&to=now

# 5. Логи Kibana и Elasticsearch

![Kibana](https://github.com/ZetIxzet/sys-diplom/blob/main/image/kibana.png)

Адрес kibana:
http://89.169.140.230:5601/app/discover#/?_a=(columns:!(),filters:!(),index:'filebeat-*',interval:auto,query:(language:kuery,query:''),sort:!(!('@timestamp',desc)))&_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-15m,to:now))

# 6. Backup

![Backup](https://github.com/ZetIxzet/sys-diplom/blob/main/image/backup.png)

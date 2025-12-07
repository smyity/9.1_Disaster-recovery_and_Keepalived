# Домашнее задание к занятию 1 «Disaster recovery и Keepalived»

[Подробное описание решения домашнего задания в GoogleDocs](ссылка)

### Задание 1

- Дана [схема](1/hsrp_advanced.pkt) для Cisco Packet Tracer, рассматриваемая в лекции.
- На данной схеме уже настроено отслеживание интерфейсов маршрутизаторов Gi0/1 (для нулевой группы)
- Необходимо аналогично настроить отслеживание состояния интерфейсов Gi0/0 (для первой группы).
- Для проверки корректности настройки, разорвите один из кабелей между одним из маршрутизаторов и Switch0 и запустите ping между PC0 и Server0.
- На проверку отправьте получившуюся схему в формате pkt и скриншот, где виден процесс настройки маршрутизатора.

### Решение 1

Дана следующая схема:

![](ссылка на картинку PIC001)

Настройки **Router1**

````
Router0>enable
Router0#show standby brief
                     P indicates configured to preempt.
                     |
Interface   Grp  Pri P State    Active          Standby         Virtual IP
Gig0/0      0    105 P Active   local           192.168.0.3     192.168.0.1    
Gig0/1      1    50    Standby  192.168.1.3     local           192.168.1.1    

Router0#show running-config | section GigabitEthernet0/0
interface GigabitEthernet0/0
 ip address 192.168.0.2 255.255.255.0
 duplex auto
 speed auto
 standby version 2
 standby 0 ip 192.168.0.1
 standby priority 105
 standby preempt
 standby 0 track GigabitEthernet0/1
Router0#show running-config | section GigabitEthernet0/1
 standby 0 track GigabitEthernet0/1
interface GigabitEthernet0/1
 ip address 192.168.1.2 255.255.255.0
 duplex auto
 speed auto
 standby version 2
 standby 0 ip 192.168.1.1
 standby priority 50
````

Настройки **Router2**

````
Router1>enable
Router1#show standby brief
                     P indicates configured to preempt.
                     |
Interface   Grp  Pri P State    Active          Standby         Virtual IP
Gig0/0      0    100 P Standby  192.168.0.2     local           192.168.0.1    
Gig0/1      1    100 P Active   local           192.168.1.2     192.168.1.1    

Router1#show running-config | section GigabitEthernet0/0
interface GigabitEthernet0/0
 ip address 192.168.0.3 255.255.255.0
 duplex auto
 speed auto
 standby version 2
 standby 0 ip 192.168.0.1
 standby preempt
 standby 0 track GigabitEthernet0/1
Router1#show running-config | section GigabitEthernet0/1
 standby 0 track GigabitEthernet0/1
interface GigabitEthernet0/1
 ip address 192.168.1.3 255.255.255.0
 duplex auto
 speed auto
 standby version 2
 standby 0 ip 192.168.1.1
 standby preempt
````

Настройка для отслеживания состояния интерфейсов Gi0/0

**Router1**

````
Router0>enable
Router0#configure terminal
Router0 (config)#interface GigabitEthernet0/1
Router0 (config-if)#standby 1 preempt
Router0 (config-if)#standby 1 track GigabitEthernet0/0
Router0 (config-if)#exit
Router0 (config)#exit
Router0#
````

``1`` — группа

``GigabitEthernet0/0`` — интерфейс, который будет отслеживаться

``GigabitEthernet0/1`` — настраиваемый интерфейс

Интерфейс, **на котором** настраивается **отслеживание** должен отличаться от того интерфейса, **который отслеживается**.

**Router2**

````
Router1>enable
Router1#configure terminal
Router1 (config)#interface GigabitEthernet0/1
Router1 (config-if)#standby 1 track GigabitEthernet0/0
Router1 (config-if)#exit
Router1 (config)#exit
Router1#
````

Теперь настройки имеют следующий вид:

**Router1**

````
Router0#show standby
GigabitEthernet0/0 - Group 0 (version 2)
  State is Active
    7 state changes, last state change 00:00:19
  Virtual IP address is 192.168.0.1
  Active virtual MAC address is 0000.0C9F.F000
    Local virtual MAC address is 0000.0C9F.F000 (v2 default)
  Hello time 3 sec, hold time 10 sec
    Next hello sent in 0.263 secs
  Preemption enabled
  Active router is local
  Standby router is 192.168.0.3
  Priority 105 (configured 105)
    Track interface GigabitEthernet0/1 state Up decrement 10
  Group name is hsrp-Gig0/0-0 (default)
GigabitEthernet0/1 - Group 1 (version 2)
  State is Standby
    7 state changes, last state change 00:00:38
  Virtual IP address is 192.168.1.1
  Active virtual MAC address is 0000.0C9F.F001
    Local virtual MAC address is 0000.0C9F.F001 (v2 default)
  Hello time 3 sec, hold time 10 sec
    Next hello sent in 1.93 secs
  Preemption enabled
  Active router is 192.168.1.3
  Standby router is local
  Priority 50 (configured 50)
    Track interface GigabitEthernet0/0 state Up decrement 10
  Group name is hsrp-Gig0/1-1 (default)
````

**Router2**

````
Router1#show standby
GigabitEthernet0/0 - Group 0 (version 2)
  State is Standby
    9 state changes, last state change 00:00:37
  Virtual IP address is 192.168.0.1
  Active virtual MAC address is 0000.0C9F.F000
    Local virtual MAC address is 0000.0C9F.F000 (v2 default)
  Hello time 3 sec, hold time 10 sec
    Next hello sent in 0.342 secs
  Preemption enabled
  Active router is 192.168.0.2
  Standby router is local
  Priority 100 (default 100)
    Track interface GigabitEthernet0/1 state Up decrement 10
  Group name is hsrp-Gig0/0-0 (default)
GigabitEthernet0/1 - Group 1 (version 2)
  State is Active
    7 state changes, last state change 00:00:28
  Virtual IP address is 192.168.1.1
  Active virtual MAC address is 0000.0C9F.F001
    Local virtual MAC address is 0000.0C9F.F001 (v2 default)
  Hello time 3 sec, hold time 10 sec
    Next hello sent in 2.227 secs
  Preemption enabled
  Active router is local
  Standby router is 192.168.1.2
  Priority 100 (default 100)
    Track interface GigabitEthernet0/0 state Up decrement 10
  Group name is hsrp-Gig0/1-1 (default)
````

#### Разрыв связей

**Сценарий 1**

Удалена связь между **Router2** и **Switch0**.

![](ссылка на картинку PIC002)

Дальше роутеров дело не продвигается.

Поменял на **Router1** HSRP **Priority** на **95**. В обычной ситуации схема следующая:

![](ссылка на картинку PIC003)

При удалении связи между **Router2** и **Switch0**, ping работает.

![](ссылка на картинку PIC004)

**Priority** интерфейса Gi0/1 на **Router2** снизилась на 10, с 100 до 90

![](ссылка на картинку PIC005)

**Сценарий 2**

При удалении связи между **Router1** и **Switch0**, ping всё также работает.

![](ссылка на картинку PIC006)

**Priority** интерфейса Gi0/1 на **Router1** снизилась на 10, с 95 до 85

![](ссылка на картинку PIC007)

------


### Задание 2

- Запустите две виртуальные машины Linux, установите и настройте сервис Keepalived как в лекции, используя пример конфигурационного [файла](1/keepalived-simple.conf).
- Настройте любой веб-сервер (например, nginx или simple python server) на двух виртуальных машинах
- Напишите Bash-скрипт, который будет проверять доступность порта данного веб-сервера и существование файла index.html в root-директории данного веб-сервера.
- Настройте Keepalived так, чтобы он запускал данный скрипт каждые 3 секунды и переносил виртуальный IP на другой сервер, если bash-скрипт завершался с кодом, отличным от нуля (то есть порт веб-сервера был недоступен или отсутствовал index.html). Используйте для этого секцию vrrp_script
- На проверку отправьте получившейся bash-скрипт и конфигурационный файл keepalived, а также скриншот с демонстрацией переезда плавающего ip на другой сервер в случае недоступности порта или файла index.html

### Решение 2

Создано 2 виртуальные машины и установлен **Keepalived** на них:

````
sudo apt install keepalived
````
На первой машине с IP-адресом 192.168.122.121

````
sudo nano /etc/keepalived/keepalived.conf
````

[Ссылка на keepalived.conf с отслеживанием скрипта](здесь должна быть ссылка)

````
sudo systemctl start keepalived
````

![](ссылка на картинку PIC008)

На второй машине с IP-адресом 192.168.122.122

````
sudo nano /etc/keepalived/keepalived.conf
````

[Ссылка на keepalived.conf BACKUP статус](здесь должна быть ссылка)

````
sudo systemctl start keepalived
````

![](ссылка на картинку PIC009)

На обеих машинах установлен **Nginx**.

Создан скрипт, который будет проверять доступность порта данного веб-сервера и существование файла index.html в root-директории данного веб-сервера на машине MASTER [192.168.122.121]. Скрипт находится в директории /etc/keepalived

[Ссылка на скрипт check_nginx.sh](здесь должна быть ссылка)

````
sudo chown root:root check_nginx.sh
sudo chmod 700 check_nginx.sh
````

**ПРОВЕРКА**

Первая машина [192.168.122.121] [MASTER]:

![](ссылка на картинку PIC010)

Вторая машина [192.168.122.122] [BACKUP]:

![](ссылка на картинку PIC011)

Отключил сервис Nginx на первой машине [MASTER]

````
sudo systemctl stop nginx.service
````

![](ссылка на картинку PIC012)

Статус второй машины после отключения Nginx:

![](ссылка на картинку PIC013)

------
 
### Задание 3

- Изучите дополнительно возможность Keepalived, которая называется vrrp_track_file
- Напишите bash-скрипт, который будет менять приоритет внутри файла в зависимости от нагрузки на виртуальную машину (можно разместить данный скрипт в cron и запускать каждую минуту). Рассчитывать приоритет можно, например, на основании Load average.
- Настройте Keepalived на отслеживание данного файла.
- Нагрузите одну из виртуальных машин, которая находится в состоянии MASTER и имеет активный виртуальный IP и проверьте, чтобы через некоторое время она перешла в состояние SLAVE из-за высокой нагрузки и виртуальный IP переехал на другой, менее нагруженный сервер.
- Попробуйте выполнить настройку keepalived на третьем сервере и скорректировать при необходимости формулу так, чтобы плавающий ip адрес всегда был прикреплен к серверу, имеющему наименьшую нагрузку.
- На проверку отправьте получившийся bash-скрипт и конфигурационный файл keepalived, а также скриншоты логов keepalived с серверов при разных нагрузках

### Решение 3

Файл конфигурации: [Ссылка на keepalived.conf отслеживающий состояние файла](здесь должна быть ссылка)

[Ссылка на скрипт check_laodavg.sh](здесь должна быть ссылка)

````
sudo crontab -e
````

Добавлена строка для запуска скрипта каждую минуту:

``* * * * * /etc/keepalived/check_laodavg.sh``

Запуск на машине стресс-теста

````
/etc/keepalived$ stress-ng --cpu 0
````

![](ссылка на картинку PIC014)

Для чтобы плавающий ip адрес всегда был прикреплен к серверу, имеющему наименьшую нагрузку можно использовать % загрузки процессора, преобразуя его в целое число и вычитать из **priority**.

[Ссылка на скрипт cpu_percent.sh](здесь должна быть ссылка)

Схема использования:

|**машина**|**priority**|
|:-:|:-:|
|MASTER|254|
|BACKUP1|253|
|BACKUP2|252|

С помощью **crontab** задать исполнение скрипта на каждой машине с интервалом 1 минута. Тем самым значение использования **CPU** будет вычитаться из **priority** и менее нагруженная машина будет выполнять роль MASTER, не нарушая иерархию.

![](ссылка на картинку PIC015)

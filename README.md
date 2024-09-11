# pam
Домашнее задание

Описание домашнего задания
Запретить всем пользователям кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников


Для данного задания создаем пользователей:
```
sudo useradd alex
sudo useradd wekx
sudo useradd days
```
Меняем им пароль:
```
echo "alex:252525" | sudo chpasswd
echo "wekx:252525" | sudo chpasswd
echo "days:252525" | sudo chpasswd
```
Далее, чтобы одни могли заходить в выходные другие нет, создаем группы.
```
Группа admins - можно всегда заходить
Группа weekends - вход только по выходным.
```
```
sudo groupadd admins
sudo groupadd weekends
```
```
Далее добавляем пользователей в группы, пользователь days не состоит ни в одной из групп.
Также добавляем в группу admins пользователя vagrant:
```
```
sudo usermod -G admins alex
sudo usermod -G weekends wekx
sudo usermod -G admins vagrant
```
```
Итак пользователи созданы и добавлены в группы, теперь нужно создать скрипт, который будет ограничивать вход.
Который выясняет, входит ли пользователь в группу admins или weekends, получает день недели и принимает решение о завершении с кодом 0 или 1:
```
```
#!/bin/bash
echo "PAM_USER"$PAM_USER
if id -nG $PAM_USER | grep -qw "admins"; then
        echo "group admins"
        exit 0
else
        if [ $(date +%a) = "Sat" ] || [ $(date +%a) = "Sun" ]; then
                        if id -nG $PAM_USER | grep -qw "weekends"; then
                                echo "group weekends"
                                exit 0
                        else
                echo "Sa-Su other group"
                exit 1
                        fi
        else
                echo "Mo-Fri all users"
                exit 0
        fi
fi
```
Меняем /etc/pam.d/sshd для прохождения дополнительной аутентификации через модуль pam_exec:
```
sudo sed  -i -E "s/account.+required.+pam_nologin.so/account    required     pam_nologin.so\naccount    required    pam_exec.so    \/usr\/local\/bin\/is-admin.sh/" /etc/pam.d/sshd
```
```
Итак собираем все в стенд.
Немного забегая вперед возникла ситуация, что при сдвиге даты гостевая машина откатывала ее назад.
Пришлось добавить правки в Vagrantfile:
```
```
timedatectl set-local-rtc 0
sudo timedatectl set-ntp 1
sudo hwclock --systohc
sudo timedatectl set-ntp 0
```
После этого при изменении даты машина держит ее до перезагрузки.
```
После применения стенда, заходим сначала без изменения даты:
Для примера возьмем пользователя alex который состоит  в группе admins(можно в любой день).
Пользователя wekx - он не состоит в группе admins, но ему можно заходить по выходным.
И пользователя days, который не состоит ни в одной из групп. При изменении даты он не должен заходить в выходные.
```
Итак текущая дата:  Thu Sep 12 12:35:31 PM UTC 2024

```
root@testvm:/home/pam2# ssh alex@192.168.56.110
alex@192.168.56.110's password:
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-92-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

  System information as of Thu Sep 12 12:35:31 PM UTC 2024

  System load:  0.03564453125      Processes:             146
  Usage of /:   12.9% of 30.34GB   Users logged in:       0
  Memory usage: 25%                IPv4 address for eth0: 10.0.2.15
  Swap usage:   0%                 IPv4 address for eth1: 192.168.56.110


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento

```
```
root@testvm:/home/pam2# ssh wekx@192.168.56.110
wekx@192.168.56.110's password:
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-92-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

  System information as of Thu Sep 12 12:35:31 PM UTC 2024

  System load:  0.03564453125      Processes:             146
  Usage of /:   12.9% of 30.34GB   Users logged in:       0
  Memory usage: 25%                IPv4 address for eth0: 10.0.2.15
  Swap usage:   0%                 IPv4 address for eth1: 192.168.56.110


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento

```
```
root@testvm:/home/pam2# ssh days@192.168.56.110
days@192.168.56.110's password:
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-92-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

  System information as of Thu Sep 12 12:35:31 PM UTC 2024

  System load:  0.03564453125      Processes:             146
  Usage of /:   12.9% of 30.34GB   Users logged in:       0
  Memory usage: 25%                IPv4 address for eth0: 10.0.2.15
  Swap usage:   0%                 IPv4 address for eth1: 192.168.56.110


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
```
```
Меняем дату на машине:
```
```
sudo date 082712302022.00
Sat Aug 27 12:30:00 PM UTC 2022
```
Пробуем также заходить:
```
root@testvm:/home/pam2# ssh alex@192.168.56.110
alex@192.168.56.110's password:
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-92-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

  System information as of Thu Sep 12 12:35:31 PM UTC 2024

  System load:  0.03564453125      Processes:             146
  Usage of /:   12.9% of 30.34GB   Users logged in:       0
  Memory usage: 25%                IPv4 address for eth0: 10.0.2.15
  Swap usage:   0%                 IPv4 address for eth1: 192.168.56.110


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
```
```
root@testvm:/home/pam2# ssh wekx@192.168.56.110
wekx@192.168.56.110's password:
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-92-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

  System information as of Thu Sep 12 12:35:31 PM UTC 2024

  System load:  0.03564453125      Processes:             146
  Usage of /:   12.9% of 30.34GB   Users logged in:       0
  Memory usage: 25%                IPv4 address for eth0: 10.0.2.15
  Swap usage:   0%                 IPv4 address for eth1: 192.168.56.110


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
```
root@testvm:/home/pam2# ssh days@192.168.56.110
days@192.168.56.110's password:
/usr/local/bin/is-admin.sh failed: exit code 1
Connection closed by 192.168.56.110 port 22
```

Что и требовалось, так как days не входит ни в одну из групп!







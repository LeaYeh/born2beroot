# Born2beroot

## Notes about the project
> System: Linux-Debian@12.1.0

#### User group setting

將 `USER_NAME` 加入 sudo 群組
```sh
usermod -aG sudo <USER_NAME>
```

確認有哪些 user 在 sudo 群組中
```sh
getent group sudo
```

編輯 sudoers 文件，該文件包含了 sudo 命令的設置和權限信息
```sh
sudo visudo
```

用戶可以以任何用戶身份（ALL）和在任何主機上（ALL）執行任何命令（ALL）
這樣的配置可以用於給特定用戶授予完整的 sudo 權限，使該用戶可以執行系統上的任何操作。
```
<USER_NAME>    ALL=(ALL) ALL
```

#### SSH service

安裝並確認 ssh service 狀態
```sh
sudo apt install openssh-server
sudo systemctl status ssh
```

重啟 ssh service
```sh
service ssh restart
```

PermitRootLogin：這是一個 SSH 伺服器的設定項，它規定是否允許 root 用戶通過 SSH 登錄到系統。

prohibit-password：這是 PermitRootLogin 的一個可能的值之一。prohibit-password 表示 root 用戶可以使用密碼（password）方式進行登錄，但這種方式在安全性上不推薦，因為可能會受到密碼猜測攻擊。

no：這是將 PermitRootLogin 設置為的新值。no 表示禁止 root 用戶通過 SSH 使用任何方式（包括密碼和密鑰）登錄系統。

所以，這個設定的作用是將 SSH 伺服器的 PermitRootLogin 設置從允許 root 用戶以密碼登錄改為不允許 root 用戶進行 SSH 登錄。這樣一來，root 用戶就不能直接通過 SSH 連接到系統，這是系統安全性的一個良好實踐，因為通常建議使用普通用戶登錄，然後再使用 sudo 或其他特權升級方式來執行特權操作
```sh
sudo vim /etc/ssh/sshd_config
===
1. 將 ssh port 改為 4242
#Port 22 -> Port 4242
2. root 不允許以任何形式登入
#PermitRootLogin prohibit-password -> PermitRootLogin no
```

#### Firewall setting

安裝並啟用防火牆
```sh
apt-get install ufw
sudo ufw enable
```

顯示當前 UFW 防火牆的規則，並按照編號的方式列出。每條規則都有一個編號，你可以使用這些編號來刪除特定的規則或者做其他相關的操作。
```sh
sudo ufw status numbered
sudo ufw delete
```

允許使用 ssh access with 4242 port
```sh
sudo ufw allow ssh
sudo ufw allow 4242
```

#### Password policy

安裝套件包
```sh
sudo apt-get install libpam-pwquality
```

- 基本密碼規則設定
    1. `pam_unix.so` 模組，它是用於進行基本的 UNIX 密碼驗證
    2. [success=2 default=ignore]：這是控制流程的條件控制，表示如果這個模組返回成功，則跳過下面兩個模組，否則繼續進行後續驗證
    3. obscure：這個選項要求密碼必須包含非字母數字符號，增強密碼安全性
    4. sha512：指定使用 SHA-512 作為密碼的雜湊算法
    5. minlen=10：這個選項要求密碼的最小長度為 10 個字符
    6. requisite：這個選項指定了此模組的必要性，如果這個模組返回失敗，則不再進行後續的密碼驗證，並立即拒絕更改密碼
    7. pam_pwquality.so：用於進行密碼規則的檢查和安全性設置
    8. retry=3：這個選項指定在密碼不符合規則時的重試次數
    9. lcredit=-1：要求密碼中至少包含一個小寫字母
    10. ucredit=-1：要求密碼中至少包含一個大寫字母
    11. dcredit=-1：要求密碼中至少包含一個數字
    12. maxrepeat=3：限制密碼中字符的最大重複次數
    13. usercheck=0：禁用用戶名與密碼相似性的檢查
    14. difok=7：設定至少有 7 個字符與上一個密碼不同
    15. enforce_for_root：強制 root 用戶也遵循這些規則
```sh
sudo vim /etc/pam.d/common-password
===
> password [success=2 default=ignore] pam_unix.so obscure - sha512 minlen=10
> password    requisite         pam_pwquality.so retry=3 lcredit =-1 ucredit=-1 dcredit=-1 maxrepeat=3 usercheck=0 difok=7 enforce_for_root
```

密碼時效設定
```sh
sudo vim /etc/login.defs
===
PASS_MAX_DAYS 30
PASS_MIN_DAYS 2
PASS_WARN_AGE 7
```

```sh
sudo reboot
```

##### Create user and assign into group
新增群組
```sh
sudo groupadd <GROUP_NAME>
```

新增用戶
```sh
sudo adduser <USER_NAME>
```

將用戶加入對應群組
```sh
sudo usermod -aG <GROUP_NAME> <USER_NAME>
```

確認用戶使否在群組中
```sh
getent group <GROUP_NAME>
```

列出所有群組
```sh
groups
```

顯示特定用戶的帳戶資訊，包括密碼的更改情況、密碼過期日期等
```sh
chage -l <USER_NAME>
```

##### Configuring sudoers group

```sh
sudo vim /etc/sudoers
===
1. 新增密碼輸入錯誤時的提示訊息
Defaults     badpass_message="Password is wrong, please try again!"

2. 將 sudo command 相關紀錄紀錄在指定檔案位置
Defaults	logfile="/var/log/sudo/sudo.log"
Defaults	log_input,log_output

3. 指定在使用 sudo 命令時必須在真實的控制台（tty）環境下執行，而不能在非交互式的環境下執行，這樣設定的好處包括：
    - 安全性提高：
        在真實的控制台環境下執行 sudo 命令可以避免非授權的程序或腳本以非交互式的方式執行 sudo，從而提高安全性。
    - 限制特權使用：
        該設定確保只有實際物理上位於系統的用戶可以執行擁有特權的操作，限制了特權操作的使用範圍。
    - 避免遠程攻擊：
        阻止在遠程或非交互式會話中執行 sudo，這樣可以避免潛在的遠程攻擊或自動化攻擊。
    - 降低潛在風險：
        當特權操作需要進行敏感的操作時，確保這些操作是由實際操作系統的人員執行，而不是由自動化程序執行。
Defaults        requiretty

4. 限制 sudo 命令在特權模式下可執行的程序的搜索路徑
- 控制可執行程序的路徑：
    限制了 sudo 命令在特權模式下可以執行的程序，僅限於指定的安全路徑內。這樣可以防止非法程序或惡意腳本被執行。
- 降低系統風險：
    限制了系統上可以執行的特權程序，減少了系統被攻擊的風險，特別是針對擁有特權的命令進行非授權執行的風險。
- 防止 Path 環境變數被劫持：
    避免了恶意攻击者通過修改 PATH 環境變數來導致 sudo 命令執行不安全程序或惡意程序的情況。
Defaults   secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
```

##### Hostname setting

顯示該主機狀態
```shell
hostnamectl
```

如何完整變更 hostname
```shell
hostnamectl set-hostname <NEW_HOSTNAME>

or

sudo vim /etc/hostname
```

```
sudo vim /etc/hosts
===
127.0.0.1       localhost
127.0.0.1       <NEW_HOSTNAME>
```

Need to reboot to apply the setting

##### Crontab configuration

安裝 netstat tools
```sh
sudo apt-get install -y net-tools
```

Place `monitoring.sh` in /usr/local/bin/
```bash
```

允許特定用戶在不需要密碼的情況下以特權執行 /usr/local/bin monitoring.sh 
```sh
sudo visudo
<USER_NAME> ALL=(ALL) NOPASSWD: /usr/local/bin/monitoring.sh
```

編輯 root 用戶的 crontab（定時任務表）
```sh
sudo crontab -u root -e
===
*/10 * * * * /usr/local/bin/monitoring.sh
```

---- 

## Commands notes

**`getent`**

```sh
getent [database] [name]
```

database：要查詢的名字服務數據庫，如 passwd、group、hosts 等。
name：要查詢的名稱，如用戶名、組名、主機名等

**`systemctl`**


systemctl 是一個用於控制 systemd 系統和服務管理器的命令行工具
```sh
sudo systemctl [start|stop|restart|status|enable|disable|show] service_name
```

**`wall`**

（write to all）是一個用於向系統中的所有用戶發送消息的命令。它可以用來向所有已登錄的用戶發送通知、警告或消息。

wall 指令後接要發送的消息，然後按 Ctrl + D 保存並發送消息。
所有當前登錄的用戶將收到你發送的消息。

**例子**
假設你想向所有用戶發送一條消息：

```sh
wall "系統將於10分鐘後重啟，請儘快保存工作並退出。"
```

這條消息將被發送到所有當前登錄的用戶，提醒他們系統將在10分鐘後重啟。

請注意，wall 命令需要有足夠的權限才能發送消息。通常，只有系統管理員或具有特定權限的用戶可以使用 wall 命令。






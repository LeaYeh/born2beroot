# Born2beroot

## Notes about the project
> System: Linux-Debian@12.1.0
#### Hostname setting

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

---- 

## Commands notes
**wall（write to all）** 是一個用於向系統中的所有用戶發送消息的命令。它可以用來向所有已登錄的用戶發送通知、警告或消息。

wall 指令後接要發送的消息，然後按 Ctrl + D 保存並發送消息。
所有當前登錄的用戶將收到你發送的消息。

**例子**
假設你想向所有用戶發送一條消息：

```sh
wall "系統將於10分鐘後重啟，請儘快保存工作並退出。"
```

這條消息將被發送到所有當前登錄的用戶，提醒他們系統將在10分鐘後重啟。

請注意，wall 命令需要有足夠的權限才能發送消息。通常，只有系統管理員或具有特定權限的用戶可以使用 wall 命令。






# Server Status Plasmoid

## About
Applet for KDE Plasma 5 showing a status of the servers defined by user.

Written by Maciej Gierej - http://makg.eu

## Installation
```
plasmapkg2 -i package
```

Use additional `-g` flag to install plasmoid globally, for all users.

## Features
- Add as many servers as you want
- Customize font size and icons
- 4 server checking methods: ping, ping for IPv6 addresses, HTTP 200 OK response, custom command
- Automatic update of server status
- Manual refresh by clicking on the server name

## Custom command
You can define your custom command which will be executed on each server update. The plasmoid interprets exit code 0 as the server being online. Any other exit code will result in offline status. You can use `%hostname%` string in the command definition to pass particular server's hostname as an argument or option.

## Screenshots
![Bitcoin Price Plasmoid](https://raw.githubusercontent.com/MakG10/plasma-applet-server-status/master/server-status-plasmoid.png)

![Bitcoin Price Plasmoid (Panel)](https://raw.githubusercontent.com/MakG10/plasma-applet-server-status/master/server-status-panel.png)

![Bitcoin Price Plasmoid (Configuration)](https://raw.githubusercontent.com/MakG10/plasma-applet-server-status/master/server-status-config.png)

![Bitcoin Price Plasmoid (Configuration)](https://raw.githubusercontent.com/MakG10/plasma-applet-server-status/master/server-status-item.png)

![Bitcoin Price Plasmoid (Configuration)](https://raw.githubusercontent.com/MakG10/plasma-applet-server-status/master/server-status-appearance.png)

## Changelog

### 1.0
Initial release

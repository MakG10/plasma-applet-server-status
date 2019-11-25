/***************************************************************************
 *   Copyright (C) 2017 by MakG <makg@makg.eu>                             *
 ***************************************************************************/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
	id: root
	
	property int lastRefreshAt: 0
	property int statusSummary: 1
	
	Layout.fillWidth: true
	Layout.fillHeight: true
	width: 250
	height: 300
	
// 	Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
	Plasmoid.toolTipTextFormat: Text.RichText
	
	ServersModel {
		id: serversModel
	}
	
	Component.onCompleted: {
		reloadServerModel();
		
		plasmoid.setAction("refreshAll", i18n("Refresh all"), "view-refresh")
	}
	
	Connections {
		target: plasmoid.configuration
		
		onServersChanged: {
			reloadServerModel();
		}
	}
	
	Plasmoid.compactRepresentation: Item {
		PlasmaCore.IconItem {
			anchors.fill: parent
			source: statusSummary == 1 ? plasmoid.configuration.iconOnline : plasmoid.configuration.iconOffline
		}
		
		
		MouseArea {
			id: mouseArea
			anchors.fill: parent
			
			onClicked: {
				plasmoid.expanded = !plasmoid.expanded
			}
		}
	}
	
	Plasmoid.fullRepresentation: Item {
		Layout.preferredWidth: 300
		Layout.preferredHeight: 300
		
		ListView {
			id: serversListView
			anchors.fill: parent
			model: serversModel
			delegate: Row {
				height: nameText.paintedHeight * 1.5
				
				PlasmaCore.IconItem {
					id: icon
					
					width: parent.height
					height: parent.height
					source: model.status == 1 ? plasmoid.configuration.iconOnline : plasmoid.configuration.iconOffline
					opacity: model.refreshing ? 0.2 : 1.0
				}
				
				PlasmaComponents.BusyIndicator {
					width: parent.height
					height: parent.height
					//anchors.horizontalCenter: icon.horizontalCenter
					running: model.refreshing
					visible: model.refreshing
				}
// 				PlasmaComponents.Label {
// 					id: timeText
// 					
// 					anchors.left: icon.right
// 					anchors.leftMargin: 10
// 					
// 					text: time
// 					height: parent.height
// 					verticalAlignment: Text.AlignVCenter
// 					font.pointSize: 12
// 				}
				PlasmaComponents.Label {
					id: nameText
					
					//anchors.left: icon.right
					//anchors.leftMargin: 10
					
					height: parent.height
					text: model.name.length == 0 ? model.hostname : model.name
					verticalAlignment: Text.AlignVCenter
					font.pointSize: plasmoid.configuration.fontSize
				}
				
				MouseArea {
					id: mouseArea
					
					//anchors.top: icon.top
					//anchors.right: nameText.right
					//anchors.bottom: icon.bottom
					//anchors.left: icon.left
					hoverEnabled: true
					onClicked: {
						refreshServer(model.index)
					}
				}
			}
		}
		
		PlasmaComponents.Button {
			anchors.centerIn: parent
			text: i18n("Configure...")
			visible: serversModel.count == 0
			onClicked: plasmoid.action("configure").trigger();
		}
	}
	
	Timer {
		id: serversTimer
		interval: 1 * 1000
		running: false
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			lastRefreshAt = new Date().getTime() / 1000;
			
			for(var i = 0; i < serversModel.count; i++) {
				if(!serversModel.get(i).refreshing && lastRefreshAt - serversModel.get(i).lastRefreshAt >= serversModel.get(i).refreshRate) {
					refreshServer(i);
				}
			}
		}
	}
	
	PlasmaCore.DataSource {
		id: executableDS
		engine: "executable"
		connectedSources: []
		property variant cmdMap: ({})
		
		onNewData: {
				parseResponse(cmdMap[sourceName], data["exit code"], data.stdout)
				
				exited(sourceName, data.stdout)
				disconnectSource(sourceName)
		}
		
		function exec(cmd, serverIndex) {
				cmdMap[cmd] = serverIndex
				
				connectSource(cmd)
		}
		signal exited(string sourceName, string stdout)
	}
	
	PlasmaCore.DataSource {
		id: notifyExecDS
		engine: "executable"
		connectedSources: []
		
		onNewData: {
				exited(sourceName, data.stdout)
				disconnectSource(sourceName)
		}
		
		function exec(cmd) {
				connectSource(cmd)
		}
		signal exited(string sourceName, string stdout)
	}
	
	function reloadServerModel() {
// 		serversModel.clear();
// 		
// 		var servers = JSON.parse(plasmoid.configuration.servers);
// 		
// 		for(var i = 0; i < servers.length; i++) {
// 			if(servers[i].active) {
// 				servers[i].refreshing = false;
// 				servers[i].lastRefreshAt = 0;
// 				servers[i].status = 0;
// 				
// 				serversModel.append(servers[i]);
// 			}
// 		}
		
		serversTimer.restart();
	}
	
	function refreshServer(index) {
		serversModel.setProperty(index, "refreshing", true);
		
		var command = '';
		
		switch(serversModel.get(index).method) {
			case 1: // PINGV6
				command = 'ping6 -c 1 ' + serversModel.get(index).hostname;
				break;
				
			case 2: // HTTP 200 OK
				command = 'curl -sL -w "%{http_code}" "' + serversModel.get(index).hostname + '" -o /dev/null';
				break;
				
			case 3: // COMMAND
				command = serversModel.get(index).extraOptions.command.replace(/\%hostname\%/g, serversModel.get(index).hostname); 
				break;
				
			case 0: // PING
			default:
				command = 'ping -c 3 ' + serversModel.get(index).hostname;
				break;
		}
		
		executableDS.exec(command, index);
	}
	
	function parseResponse(index, exitCode, stdout) {
		var status = 0;
		
		switch(serversModel.get(index).method) {
			case 1: // PINGV6
				status = exitCode == 0 ? 1 : 0;
				break;
				
			case 2: // HTTP 200 OK
				status = stdout.indexOf("200") !== -1 ? 1 : 0;
				break;
				
			case 3: // COMMAND
				status = exitCode == 0 ? 1 : 0;
				break;
				
			case 0: // PING
			default:
				status = exitCode == 0 ? 1 : 0;
				break;
		}
		
		if(serversModel.get(index).status != status) {
			notify(index, status);
		}
		
		serversModel.setProperty(index, "status", status);
		serversModel.setProperty(index, "refreshing", false);
		serversModel.setProperty(index, "lastRefreshAt", new Date().getTime() / 1000);
		
		updateStatusSummary();
	}
	
	function updateStatusSummary() {
		var status = 1;
		
		for(var i = 0; i < serversModel.count; i++) {
			if(serversModel.get(i).status != 1) {
				status = 0;
				break;
			}
		}
		
		statusSummary = status;
	}
	
	function notify(serverIndex, status) {
		var notification = status === 0 ? plasmoid.configuration.notificationDown : plasmoid.configuration.notificationUp;
		notification = JSON.parse(notification);
		
		switch(notification.action) {
			case 1: // Play sound
				break;
				
			case 2: // System notification
				var title = serversModel.get(serverIndex).name;
				var text = status === 0 ?
					'Server ' + serversModel.get(serverIndex).name + ' is offline.' :
					'Server ' + serversModel.get(serverIndex).name + ' is online';
					
				var command = 'notify-send "' + title.replace(/"/, '\"') + '" "' + text.replace(/"/, '\"') + '"';
				
				notifyExecDS.exec(command);
				break;
				
			case 3: // Command
				var command = notification.extraOptions.command
					.replace(/\%hostname\%/g, serversModel.get(index).hostname)
					.replace(/\%name\%/g, serversModel.get(index).name);
					
				notifyExecDS.exec(command);
				break;
				
			case 0: // Nothing
				break;
		}
	}
	
	function action_refreshAll() {
		for(var i = 0; i < serversModel.count; i++) {
			refreshServer(i);
		}
	}
}

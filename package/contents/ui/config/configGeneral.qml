import QtQuick 2.1
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents

import ".."

Item {
	id: configGeneral
	Layout.fillWidth: true
	
	property string cfg_servers: plasmoid.configuration.servers
	
	property int dialogMode: -1
	
	ServersModel {
		id: serversModel
	}
	
	Component.onCompleted: {
		serversModel.clear();
		
		var servers = JSON.parse(cfg_servers);
		
		for(var i = 0; i < servers.length; i++) {
			serversModel.append(servers[i]);
		}
	}

	RowLayout {
		anchors.fill: parent
		
		Layout.alignment: Qt.AlignTop | Qt.AlignRight
		
		TableView {
			id: serversTable
			model: serversModel
			
			anchors.top: parent.top
			anchors.right: buttonsColumn.left
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.rightMargin: 10
			
			TableViewColumn {
				role: "active"
				width: 20
				delegate: CheckBox {
					checked: model.active
					onClicked: {
						model.active = checked;
						
						cfg_servers = JSON.stringify(getServersArray());
					}
				}
			}
			
			TableViewColumn {
				role: "name"
				title: "Name"
			}
			
			onDoubleClicked: {
				editServer();
			}
			
			onActivated: {
				moveUp.enabled = row > 0;
				moveDown.enabled = row < serversTable.model.count - 1;
			}
		}
		
		ColumnLayout {
			id: buttonsColumn
			
			anchors.top: parent.top
			
			PlasmaComponents.Button {
				text: "Add..."
				iconSource: "list-add"
				
				onClicked: {
					addServer();
				}
			}
			
			PlasmaComponents.Button {
				text: "Edit"
				iconSource: "edit-entry"
				
				onClicked: {
					editServer();
				}
			}
			
			PlasmaComponents.Button {
				text: "Remove"
				iconSource: "list-remove"
				
				onClicked: {
					if(serversTable.currentRow == -1) return;
					
					serversTable.model.remove(serversTable.currentRow);
					
					cfg_servers = JSON.stringify(getServersArray());
				}
			}
			
			PlasmaComponents.Button {
				id: moveUp
				text: i18n("Move up")
				iconSource: "go-up"
				enabled: false
				
				onClicked: {
					if(serversTable.currentRow == -1) return;
					
					serversTable.model.move(serversTable.currentRow, serversTable.currentRow - 1, 1);
					serversTable.selection.clear();
					serversTable.selection.select(serversTable.currentRow - 1);
				}
			}
			
			PlasmaComponents.Button {
				id: moveDown
				text: i18n("Move down")
				iconSource: "go-down"
				enabled: false
				
				onClicked: {
					if(serversTable.currentRow == -1) return;
					
					serversTable.model.move(serversTable.currentRow, serversTable.currentRow + 1, 1);
					serversTable.selection.clear();
					serversTable.selection.select(serversTable.currentRow + 1);
				}
			}
		}
	}
	
	
	Dialog {
		id: serverDialog
		visible: false
		title: "Server"
		standardButtons: StandardButton.Save | StandardButton.Cancel
		
		onAccepted: {
			var itemObject = {
				name: serverName.text,
				hostname: serverHostname.text,
				refreshRate: serverRefreshRate.value,
				method: serverMethod.currentIndex,
				active: serverActive.checked,
				extraOptions: {
					command: serverCommand.text
				}
			};
			
			if(dialogMode == -1) {
				serversModel.append(itemObject);
			} else {
				serversModel.set(dialogMode, itemObject);
			}
			
			cfg_servers = JSON.stringify(getServersArray());
		}

		ColumnLayout {
			GridLayout {
				columns: 2
				
				PlasmaComponents.Label {
					text: "Name:"
				}
				
				TextField {
					id: serverName
					Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 40
				}
				
				
				PlasmaComponents.Label {
					text: "Host name:"
				}
				
				TextField {
					id: serverHostname
					Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 40
				}
				
				
				PlasmaComponents.Label {
					text: i18n("Refresh rate:")
				}
				
				SpinBox {
					id: serverRefreshRate
					suffix: i18n(" seconds")
					minimumValue: 1
					maximumValue: 3600
				}
				
				
				PlasmaComponents.Label {
					text: i18n("Check method:")
				}
				
				ComboBox {
					id: serverMethod
					model: ["Ping", "PingV6", "HTTP 200 OK", "Command"]
					Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 15
					onActivated: {
						if(index == 3)
							commandGroup.visible = true
						else
							commandGroup.visible = false
					}
				}
				
				
				PlasmaComponents.Label {
					text: ""
				}
				
				CheckBox {
					id: serverActive
					text: i18n("Active")
				}
			}
			
			GroupBox {
				id: commandGroup
				title: "Command"
				visible: false
				
				anchors.left: parent.left
				anchors.right: parent.right
					
				TextField {
					id: serverCommand
					width: parent.width
				}
				
				PlasmaComponents.Label {
					anchors.top: serverCommand.bottom
					width: parent.width
					wrapMode: Text.WordWrap
					text: i18n("Use %hostname% to pass server's hostname as an argument or option to the executable.")
				}
			}
		}
	}
	
	function addServer() {
		dialogMode = -1;
		
		serverName.text = ""
		serverHostname.text = ""
		serverRefreshRate.value = 60
		serverMethod.currentIndex = 0
		serverActive.checked = true
		
		serverDialog.visible = true;
		serverName.focus = true;
	}
	
	function editServer() {
		dialogMode = serversTable.currentRow;
		
		serverName.text = serversModel.get(dialogMode).name
		serverHostname.text = serversModel.get(dialogMode).hostname
		serverRefreshRate.value = serversModel.get(dialogMode).refreshRate
		serverMethod.currentIndex = serversModel.get(dialogMode).method
		serverActive.checked = serversModel.get(dialogMode).active
		
		serverDialog.visible = true;
		serverName.focus = true;
	}
	
	function getServersArray() {
		var serversArray = [];
		
		for(var i = 0; i < serversModel.count; i++) {
			serversArray.push(serversModel.get(i));
		}
		
		return serversArray;
	}
}

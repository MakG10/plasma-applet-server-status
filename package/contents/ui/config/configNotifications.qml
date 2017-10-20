import QtQuick 2.1
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
	id: configNotifications
	Layout.fillWidth: true
	
	property string cfg_notificationUp: plasmoid.configuration.notificationUp
	property string cfg_notificationDown: plasmoid.configuration.notificationDown
	
	Component.onCompleted: {
		var notificationUp = JSON.parse(cfg_notificationUp);
		
		notifyUpAction.currentIndex = notificationUp.action;
		notifyUpCommand.text = notificationUp.extraOptions.command;
		
		
		var notificationDown = JSON.parse(cfg_notificationDown);
		
		notifyDownAction.currentIndex = notificationDown.action;
		notifyDownCommand.text = notificationDown.extraOptions.command;
	}
	
	ColumnLayout {
		anchors.left: parent.left
		anchors.right: parent.right
		
		GroupBox {
			id: notificationUpGroup
			title: "When server goes online"
			visible: true
			
			anchors.left: parent.left
			anchors.right: parent.right
				
			GridLayout {
				columns: 2
				
				PlasmaComponents.Label {
					text: i18n("Action:")
				}
				
				ComboBox {
					id: notifyUpAction
					model: ["Nothing", "System notification", "Command"]
					Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 20
					onCurrentIndexChanged: {
						updateData();
						
						if(currentIndex == 2) {
							notifyUpCommandLabel.visible = true
							notifyUpCommand.visible = true
						} else {
							notifyUpCommandLabel.visible = false
							notifyUpCommand.visible = false
						}
					}
				}
				
				PlasmaComponents.Label {
					id: notifyUpCommandLabel
					text: i18n("Command:")
					visible: false
				}
				
				TextField {
					id: notifyUpCommand
					Layout.minimumWidth: parent.width
					visible: false
					onEditingFinished: updateData
				}
			}
		}
		
		GroupBox {
			id: notificationDownGroup
			title: "When server goes offline"
			visible: true
			
			anchors.left: parent.left
			anchors.right: parent.right
				
			GridLayout {
				columns: 2
				
				PlasmaComponents.Label {
					text: i18n("Action:")
				}
				
				ComboBox {
					id: notifyDownAction
					model: ["Nothing", "System notification", "Command"]
					Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 20
					onCurrentIndexChanged: {
						updateData();
						
						if(currentIndex == 2) {
							notifyDownCommandLabel.visible = true
							notifyDownCommand.visible = true
						} else {
							notifyDownCommandLabel.visible = false
							notifyDownCommand.visible = false
						}
					}
				}
				
				PlasmaComponents.Label {
					id: notifyDownCommandLabel
					text: i18n("Command:")
					visible: false
				}
				
				TextField {
					id: notifyDownCommand
					Layout.minimumWidth: parent.width
					visible: false
					onEditingFinished: updateData
				}
			}
		}
	}
	
	function updateData() {
		var notificationUp = {
			action: notifyUpAction.currentIndex,
			extraOptions: {
				command: notifyUpCommand.text
			}
		};
		
		cfg_notificationUp = JSON.stringify(notificationUp);
		
		
		var notificationDown = {
			action: notifyDownAction.currentIndex,
			extraOptions: {
				command: notifyDownCommand.text
			}
		};
		
		cfg_notificationDown = JSON.stringify(notificationDown);
	}
}

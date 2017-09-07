import QtQuick 2.1
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
	id: configAppearance
	Layout.fillWidth: true
	
	property alias cfg_fontSize: fontSize.value
	property string cfg_iconOnline: plasmoid.configuration.iconOnline
	property string cfg_iconOffline: plasmoid.configuration.iconOffline
	
	GridLayout {
		columns: 2
		
		PlasmaComponents.Label {
			text: i18n("Font size:")
		}
		
		SpinBox {
			id: fontSize
			suffix: i18n(" pt")
			minimumValue: 1
			maximumValue: 128
		}
		
		
		PlasmaComponents.Label {
			text: i18n("Online icon:")
		}
		
		IconPicker {
			currentIcon: cfg_iconOnline
			defaultIcon: "security-high"
			onIconChanged: cfg_iconOnline = iconName
			enabled: true
		}
		
		
		PlasmaComponents.Label {
			text: i18n("Offline icon:")
		}
		
		IconPicker {
			currentIcon: cfg_iconOffline
			defaultIcon: "security-low"
			onIconChanged: cfg_iconOffline = iconName
			enabled: true
		}
	}
}

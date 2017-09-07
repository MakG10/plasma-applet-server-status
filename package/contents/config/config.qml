import QtQuick 2.0

import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: i18n("General")
         icon: "preferences-system-windows"
         source: "config/configGeneral.qml"
    }
    ConfigCategory {
         name: i18n("Appearance")
         icon: "preferences-desktop-color"
         source: "config/configAppearance.qml"
    }
}

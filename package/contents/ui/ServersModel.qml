import QtQuick 2.0

ListModel {
	id: serversModel
	
	ListElement {
		name: "Example"
		hostname: "example.com"
		method: 0
		active: false
		refreshRate: 60
		refreshing: false
		lastRefreshAt: 0
		status: 1
	}
}

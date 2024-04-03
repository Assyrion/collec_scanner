import QtQuick 6.3
import QtQuick.Controls 6.3

import "../utils"

TreeView {
    id: root

    signal showGameRequired(int idx)
    signal movingChanged(bool moving)

    Component.onCompleted: {
        model = dbManager.currentProxyModel // initial DB
    }

    // update model when pointing to new DB
    Connections {
        target: dbManager
        function onDatabaseChanged() {
            model = dbManager.currentProxyModel
        }
    }

    highlightMoveDuration: 0
    spacing: 5

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AlwaysOn
        width: 10
    }
    delegate: GameListDelegate {
        width:  root.width - 10
        height: 50
        onClicked: root.showGameRequired(index)
    }
    onMovingChanged: root.movingChanged(moving)
}


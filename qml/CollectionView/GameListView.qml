import QtQuick 6.2
import QtQuick.Controls 6.2

import "../utils"

ListView {
    id: root

    signal showGameRequired(int idx)
    signal movingChanged(bool moving)

    model: dbManager.currentProxyModel

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


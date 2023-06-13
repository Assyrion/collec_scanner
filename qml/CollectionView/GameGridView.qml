import QtQuick 6.2
import QtQuick.Controls 6.2

import "../utils"
import "../utils/PlatformSelector.js" as Platforms

GridView {
    id: root

    signal showGameRequired(int idx)
    signal movingChanged(bool moving)

    Component.onCompleted: {
        model = dbManager.currentProxyModel
        highlightMoveDuration = 0
    }

    cellWidth: Math.min((width-5)/4, 169)
    cellHeight: cellWidth / Platforms.list[platformName].coverRatio

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AlwaysOn
        width: 10
    }
    delegate: GameGridDelegate {
        width: root.cellWidth - 5
        height: root.cellHeight - 5
        onClicked: root.showGameRequired(index)
    }
    onMovingChanged: root.movingChanged(moving)
}


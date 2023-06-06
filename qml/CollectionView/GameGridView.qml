import QtQuick 6.2
import QtQuick.Controls 6.2

import "../utils"

GridView {
    id: root

    signal showGameRequired(int idx)
    signal movingChanged(bool moving)

    Component.onCompleted: {
        model = sortFilterProxyModel
        highlightMoveDuration = 0
    }

    cellWidth: Math.min((width-5)/4, 169)
    cellHeight: cellWidth * 1.23

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


import QtQuick 6.2
import QtQuick.Controls 6.2
import GameData 1.0
import "utils"

PinchArea {
    onPinchUpdated: {
        var diff = pinch.scale
                - pinch.previousScale
        if(diff < 0) {
            gridView.scaleSize
                    = Math.max(gridView.scaleSize-0.03, 0.4)
        } else if(diff > 0){
            gridView.scaleSize
                    = Math.min(gridView.scaleSize+0.03, 1.0)
        }
    }

    GridView {
        id: gridView
        property real scaleSize: 1.0

        cellWidth: width/4 * gridView.scaleSize
        cellHeight: 108 * gridView.scaleSize // hardcoded...

        model: sqlTableModel
        width : parent.width-5
        height: parent.height-10
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.top: parent.top
        anchors.topMargin: 5
        highlightRangeMode:
            GridView.StrictlyEnforceRange
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOn
            interactive: false
            width: 10
        }
        delegate: GameGridDelegate {
            width: gridView.cellWidth - 10
            onClicked: {
                var arr = [tag, title, full_title, platform,
                           publisher,  developer, release_date,
                           info]
                var game = GameDataMaker.createComplete(arr)
                showGameData(game, index)
            }
        }
    }
}

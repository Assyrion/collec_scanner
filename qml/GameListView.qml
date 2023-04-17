import QtQuick 6.2
import QtQuick.Controls 6.2
import GameData 1.0
import "utils"

PinchArea {
    onPinchUpdated: {
        var diff = pinch.scale
                - pinch.previousScale
        if(diff < 0) {
            listView.scaleHeight
                    = Math.max(listView.scaleHeight-0.03, 0.4)
        } else if(diff > 0){
            listView.scaleHeight
                    = Math.min(listView.scaleHeight+0.03, 1.0)
        }
    }
    ListView {
        id: listView
        property real scaleHeight: 1.0

        model: sqlTableModel
        width : parent.width-5
        height: parent.height-10
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.top: parent.top
        anchors.topMargin: 5
        spacing: 5 * scaleHeight
        highlightRangeMode:
            ListView.StrictlyEnforceRange
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOn
            width: 10
        }
        delegate: GameListDelegate {
            width:  listView.width - 10
            height: listView.scaleHeight * 46.2
            onClicked: function() {
                var arr = [tag, title, full_title, platform,
                           publisher,  developer, release_date,
                           info]
                var game = GameDataMaker.createComplete(arr)
                showGameData(game, index)
            }
        }
    }
}

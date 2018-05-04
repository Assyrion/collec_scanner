import QtQuick 2.8
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import GameData 1.0
import "utils"

Pane {
    id: root
    signal backToMenuRequired

    padding: 0

    PinchArea {
        anchors.fill: parent
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
            snapMode: ListView.SnapToItem
            highlightRangeMode:
                ListView.StrictlyEnforceRange
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOn
                interactive: false
                width: 10
            }
            delegate: DelegateGameList {
                width:  listView.width - 10
                height: listView.scaleHeight * 46.2
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

    Image {
        id: addGameBtn
        Component.onCompleted: {
            visible = true // fix bug on android
        }
        visible: false
        sourceSize.width: 55
        sourceSize.height: 55
        source: "qrc:/add_notag"
        Drag.active: maBtn.drag.active
        Drag.hotSpot.x: width/2
        Drag.hotSpot.y: height/2
        x: Math.random()*maBtn.drag.maximumX
        y: Math.random()*maBtn.drag.maximumY
        layer.enabled: maBtn.pressed
        layer.effect: BrightnessContrast {
            brightness: 0.5
            contrast: 0.5
        }
        MouseArea {
            id: maBtn
            anchors.fill: parent
            drag.target: parent
            drag.minimumX: 0
            drag.maximumX: root.width
                           -parent.width
            drag.minimumY: 0
            drag.maximumY: root.height
                           -parent.height
            onClicked: {
                showNewGameData()
            }
        }
    }

    DrawerConfig {
        id: drawer
        width: 1*parent.width/2
        height: parent.height
    }


    function showGameData(game, index) {
        gameDataLoader.setSource("ViewGameData.qml",
                                 {"game": game,
                                     "row" : index})
    }
    function showNewGameData() {
        gameDataLoader.setSource("ViewGameData.qml",
                                 {"editMode": true,
                                     "manuMode": true})
    }

    Loader {
        id: gameDataLoader
        anchors.fill: parent
        Connections {
            target: gameDataLoader.item
            onClosed: {
                gameDataLoader.sourceComponent
                        = undefined
            }
        }
    }
}

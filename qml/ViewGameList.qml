import QtQuick 2.8
import QtQuick.Controls 2.2
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
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOn
                interactive: false
                width: 10
            }
            delegate: Rectangle {
                width:  listView.width - 10
                height: listView.scaleHeight * 46.2
                radius: 5
                gradient: Gradient {
                    GradientStop {
                        position: 0.0;
                        color: ma.pressed ? "#bbbbbb"
                                          : "#4e4e4e";
                    }
                    GradientStop {
                        position: 0.5;
                        color: ma.pressed ? "#bbbbbb"
                                          : "#585858";
                    }
                    GradientStop {
                        position: 1.0;
                        color: ma.pressed ? "#bbbbbb"
                                          : "#4e4e4e";
                    }
                }
                Image {
                    id: frontPicImg
                    height: parent.height
                    anchors.left: parent.left
                    anchors.leftMargin: parent.radius
                    anchors.verticalCenter: parent.verticalCenter
                    source: imageManager.getFrontPic(tag)
                    fillMode: Image.PreserveAspectFit
                    cache: false
                }
                Text {
                    id: titleText
                    text: title
                    anchors.left:
                        parent.horizontalCenter
                    anchors.leftMargin: -root.width/4-20
                    anchors.right: platformText.left
                    anchors.rightMargin: 10
                    anchors.verticalCenter:
                        parent.verticalCenter
                    elide: Text.ElideRight
                    font.pointSize: 17*listView.scaleHeight
                    font.family: "Calibri"
                    color: "white"
                }
                Text {
                    id: platformText
                    anchors.right: parent.right
                    anchors.rightMargin: parent.radius
                    anchors.verticalCenter:
                        parent.verticalCenter
                    text: platform
                    font.pointSize: titleText.font.pointSize
                    font.family: "Calibri"
                    color: "white"
                }
                MouseArea {
                    id: ma
                    anchors.fill: parent
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
    }

    Rectangle {
        id: addGameBtn
        width: 55
        height: width
        radius: width/2
        visible: false
        color: maBtn.pressed ? "#00ff49"
                             : "#00be49"
        border.color: "black"
        border.width: 3
        Drag.active: maBtn.drag.active
        Drag.hotSpot.x: width/2
        Drag.hotSpot.y: height/2
        x: Math.random()*maBtn.drag.maximumX
        y: Math.random()*maBtn.drag.maximumY
        Component.onCompleted: {
            visible = true // fix bug on android
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

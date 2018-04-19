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
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOn
                interactive: false
                width: 10
            }
            delegate: Item {
                width:  listView.width - 10
                height: listView.scaleHeight * 46.2

                Item {
                    id: frontPicImg
                    anchors.fill: parent
                    Image {
                        sourceSize.width :
                            parent.width + 20
                        anchors.top: parent.top
                        anchors.topMargin:
                            -implicitHeight/3
                        anchors.horizontalCenter:
                            parent.horizontalCenter
                        source: imageManager.getFrontPic(tag)
                        fillMode: Image.PreserveAspectCrop
                        antialiasing: true
                        cache: false
                        mipmap: true
                        smooth: true
                    }
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width : frontPicImg.width
                            height: frontPicImg.height
                            radius: 10
                        }
                    }
                }
                CSGlowText {
                    id: titleText
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter:
                        parent.verticalCenter
                    anchors.right: platformText.left
                    anchors.rightMargin: 10
                    font.pointSize: 17*listView.scaleHeight
                    text: title
                }
                CSGlowText {
                    id: platformText
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter:
                        parent.verticalCenter
                    font.pointSize: 17*listView.scaleHeight
                    text: platform
                }
                MouseArea {
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

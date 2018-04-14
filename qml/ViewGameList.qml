import QtQuick 2.8
import QtQuick.Controls 2.2
import GameData 1.0
import "utils"

Pane {
    id: root
    signal backToMenuRequired

    padding: 0
    ListView {
        id: listView
        model: sqlTableModel
        anchors.fill: parent
        spacing: -7
        delegate: RoundButton {
            implicitWidth:  parent.width
            implicitHeight: root.height/9
            readonly property int rowIdx : index
            radius: 5
            onClicked: {
                var arr = [tag, title, platform, publisher,
                           developer, release_date]
                var game = GameDataMaker.createComplete(arr)
                showGameData(index, game)
            }
            Image {
                id: frontPicImg
                height: parent.height-13
                anchors.left: parent.left
                anchors.leftMargin: 10
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
                font.pointSize: 17
                font.family: "Calibri"
                color: "white"
            }
            Text {
                id: platformText
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter:
                    parent.verticalCenter
                text: platform
                font.pointSize: 17
                font.family: "Calibri"
                color: "white"
            }
        }
    }

    function showGameData(index, game) {
        gameDataLoader.setSource("ViewGameData.qml",
                                 {"game": game,
                                  "row" :index})
    }

    Loader {
        id: gameDataLoader
        anchors.fill: parent
        Connections {
            target: gameDataLoader.item
            onClosed: {
                gameDataLoader.sourceComponent = undefined
            }
        }
    }
}

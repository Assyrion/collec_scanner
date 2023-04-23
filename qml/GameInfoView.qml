import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects
import GameData 1.0
import "utils"

Pane {
    id: root

    signal closed

    property var currentGame: GameDataMaker.createEmpty()

    property bool editMode: false
    property int currentGameIndex: -1

    Component.onCompleted: showContent()

    function showContent() {
        if(currentGameIndex < 0)
            contentLoader.showNewGameData()
        else
            contentLoader.showGameData()
    }

    Loader {
        id: contentLoader

        anchors.top: parent.top
        anchors.bottom: btnRow.top
        width: parent.width

        function showGameData() {
            setSource("GameSwipeView.qml",
                      {"game": currentGame,
                       "anchors.fill": parent})
        }
        function showNewGameData() {
            setSource("GameSwipeDelegate.qml",
                      {"editMode": editMode,
                       "game": currentGame,
                       "anchors.fill": parent})
        }
    }

    RowLayout {
        id: btnRow
        height: 50
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        anchors.horizontalCenter:
            parent.horizontalCenter
        spacing: 15
        Button {
            text: qsTr("close")
            onClicked: {
                closed()
            }
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignCenter
        }
        Button {
            text: editMode ? qsTr("save")
                           : qsTr("edit")
            onClicked: {
                if(editMode) {
                    writeGame()
                    closed()
                } else {
                    root.editMode = true
                }
            }
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignCenter
        }
        Button {
            text: qsTr("delete")
            visible: currentGameIndex >= 0
            onClicked: {
                popupLoader.loadConfirmDelete()
            }
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignCenter
        }
    }

    Loader {
        id: popupLoader
        function loadSnapshotPopup(img) {
            popupLoader.setSource("TakeSnapshotPopup.qml",
                             { "boundImg": img,
                                 "width" : 2*root.width/3,
                                 "height": root.height/2,
                                 "x"     : root.width/6-12,
                                 "y"     : root.height/3-40})
        }
        function loadConfirmDelete() {
            popupLoader.setSource("ConfirmDeletePopup.qml",
                             {   "width" : 2*root.width/3,
                                 "height": root.height/3,
                                 "x"     : root.width/6-12,
                                 "y"     : root.height/4+20})
        }
        Connections {
            target: popupLoader.item
            ignoreUnknownSignals: true
            function onAccepted() {
                removeGame()
                closed()
            }
        }
    }

    MouseArea {
        id: globalMa
        anchors.fill: parent
        enabled : false
    }
}

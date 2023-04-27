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
    signal saveRequired(int index, GameData game)

    property bool editMode: false

    property string currentGameTag: ""
    property int currentGameIndex: -1

    Component.onCompleted: {
        showContent()
        editMode = Qt.binding(() => { // bind once item exists
            return contentLoader.item.editMode
        })
    }

    function showContent() {
        if(currentGameIndex < 0)
            contentLoader.showNewGameData()
        else
            contentLoader.showGameData()
    }

    Loader {
        id: contentLoader

        anchors.fill: parent

        function showGameData() {
            setSource("GameSwipeView.qml",
                      {"currentTag": currentGameTag,
                       "currentIndex": currentGameIndex,
                       "width": parent.width,
                       "height": parent.height})
        }
        function showNewGameData() {
            setSource("GameSwipeDelegate.qml",
                      {"editMode": editMode,
                       "currentTag": currentGameTag,
                       "width": parent.width,
                       "height": parent.height})
        }
    }

    RowLayout {
        id: btnRow
        height: 50
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter:
            parent.horizontalCenter
        spacing: 15
        Button {
            text: editMode ? qsTr("cancel")
                           : qsTr("close")
            onClicked: {
                if(editMode) {
                    contentLoader.item.editMode = false
                } else {
                    closed()
                }
            }
            Layout.preferredWidth: 110
            Layout.alignment: Qt.AlignCenter
        }
        Button {
            text: editMode ? qsTr("save")
                           : qsTr("edit")
            onClicked: {
                if(editMode) {
                    contentLoader.item.editMode = false
                    contentLoader.item.saveGame()
                    closed()
                } else {
                    contentLoader.item.editMode = true
                }
            }
            Layout.preferredWidth: 110
            Layout.alignment: Qt.AlignCenter
        }
        Button {
            text: qsTr("delete")
            visible: currentGameIndex >= 0
            onClicked: {
                popupLoader.loadConfirmDelete()
            }
            Layout.preferredWidth: 110
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
                contentLoader.item.removeGame()
                closed()
            }
        }
    }
}

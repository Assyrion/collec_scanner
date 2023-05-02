import QtQuick 6.2
import QtQuick.Layouts 6.2
import QtQuick.Controls 6.2
import QtQuick.Dialogs

import GameData 1.0

import "../utils"

Pane {
    id: root

    // Pane has a default padding non null
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

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

    function showConfirmDelete() {
        var cpt = Qt.createComponent("../utils/CSActionPopup.qml")
        if (cpt.status === Component.Ready) {
            var obj = cpt.createObject(root, {"contentText" : qsTr("Are you sure ?"),
                                 "width" : 2*root.width/3,
                                 "height": root.height/4,
                                 "x"     : root.width/6,
                                 "y"     : root.height/4+20})
            obj.accepted.connect(function() {
                contentLoader.item.removeGame()
                closed()
            })
        }
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
        anchors.bottomMargin: 15
        anchors.horizontalCenter:
            parent.horizontalCenter
        spacing: 15
        Button {
            text: editMode ? qsTr("cancel")
                           : qsTr("close")
            onClicked: {
                if(editMode) {
                    contentLoader.item.editMode = false
                    contentLoader.item.cancelGame()
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
                    contentLoader.item.saveGame()
                    closed() // important to do it (maybe make a new feature just to avoid it)
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
                showConfirmDelete()
            }
            Layout.preferredWidth: 110
            Layout.alignment: Qt.AlignCenter
        }
    }
}

import QtQuick 6.2
import QtQuick.Layouts 6.2
import QtQuick.Controls 6.2

Item {
    id: root

    signal closed
    signal saved(string tag)

    property string tag: ""

    GameSwipeDelegate {
        id: newGameContent
        anchors.fill: parent
        currentTag: tag
        editMode: true
        index: -1
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
            text: newGameContent.editMode
                  ? qsTr("cancel")
                  : qsTr("close")
            onClicked: {
                if(newGameContent.editMode) {
                    newGameContent.editMode = false
                    newGameContent.cancelGame()
                } else {
                    closed()
                }
            }
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: btnRow.children.reduce(function(prev, curr) {
                    return curr.implicitWidth > prev ? curr.implicitWidth : prev;
                }, 100)
        }
        Button {
            text: newGameContent.editMode
                  ? qsTr("save")
                  : qsTr("edit")
            onClicked: {
                if(newGameContent.editMode) {
                    newGameContent.saveGame()
                    saved(newGameContent.currentTag)
                } else {
                    newGameContent.editMode = true
                }
            }
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: btnRow.children.reduce(function(prev, curr) {
                    return curr.implicitWidth > prev ? curr.implicitWidth : prev;
                }, 100)
        }
    }
}

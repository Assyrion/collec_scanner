import QtQuick 6.3
import QtQuick.Layouts 6.3
import QtQuick.Controls 6.3

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
        isOwned: true
        index: -1
    }

    RowLayout {
        id: btnRow
        height: 50
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter:
            parent.horizontalCenter
        spacing: 20
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
            leftPadding: 12
            rightPadding: 12

            font.pointSize: 11
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: btnRow.children.reduce(function(prev, curr) {
                    return curr.implicitWidth > prev ? curr.implicitWidth : prev;
                }, 80)
            Behavior on Layout.preferredWidth { NumberAnimation { duration: 150 } }
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
            leftPadding: 12
            rightPadding: 12

            font.pointSize: 11
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: btnRow.children.reduce(function(prev, curr) {
                    return curr.implicitWidth > prev ? curr.implicitWidth : prev;
                }, 80)
            Behavior on Layout.preferredWidth { NumberAnimation { duration: 150 } }
        }
    }
}

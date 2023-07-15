import QtQuick 6.2
import QtQuick.Controls 6.2

Item {
    id: root

    property alias name:     labelName.text
    property alias entry:    textField.text
    property alias editable: textField.enabled

    function reset() {
        while(textField.canUndo) {
            textField.undo() // reset text to origin
        }
    }

    Label {
        id: labelName
        width: parent.width/3
        height: parent.height
        verticalAlignment:
            Label.AlignVCenter
        font.family: "Roboto"
        font.pointSize: 14
        font.bold: true
        color: "lightgray"
    }
    TextField {
        id: textField
        height: parent.height
        topPadding: 3
        bottomPadding: 3
        font.pointSize: 13
        anchors.right: parent.right
        anchors.left: labelName.right
        anchors.verticalCenter:
            labelName.verticalCenter
        verticalAlignment:
            TextField.AlignVCenter
        wrapMode: Text.WordWrap
        color: "white"
        background: Rectangle {
            color: root.editable ? "transparent" : "burlywood"
            border.width: root.editable ? 1 : 0
            border.color: root.editable ? "burlywood" : "transparent"
            opacity: root.editable ? 1 : 0.1
            radius: 8
        }
    }
}

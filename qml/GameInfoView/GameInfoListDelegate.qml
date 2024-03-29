import QtQuick 6.2
import QtQuick.Controls 6.2

Item {
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
        color: "white"
    }
    TextField {
        id: textField
        height: parent.height
        topPadding: 3; bottomPadding: 3
        font.pointSize: 13
        anchors.right: parent.right
        anchors.left: labelName.right
        anchors.verticalCenter:
            labelName.verticalCenter
        verticalAlignment:
            TextField.AlignVCenter
        wrapMode: Text.WordWrap
    }
}

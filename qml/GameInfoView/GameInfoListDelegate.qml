import QtQuick 6.2
import QtQuick.Controls 6.2

Item {
    property alias name:     labelName.text
    property alias entry:    textField.text
    property alias editable: textField.enabled

    Label {
        id: labelName
        width: parent.width/3
        height: parent.height
        verticalAlignment:
            Label.AlignVCenter
        font.family: "Roboto"
        font.pixelSize: 20
        font.bold: true
        color: "white"
    }
    TextField {
        id: textField
        height: implicitBackgroundHeight
        topInset: 5; bottomInset: 5
        anchors.right: parent.right
        anchors.left: labelName.right
        anchors.verticalCenter:
            labelName.verticalCenter
        verticalAlignment:
            TextField.AlignVCenter
        wrapMode: Text.WordWrap
    }
}

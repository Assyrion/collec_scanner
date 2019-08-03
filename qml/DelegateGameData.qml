import QtQuick 2.8
import QtQuick.Controls 2.2

Item {
    property alias entry: textField.text

    Label {
        id: labelName
        width: parent.width/3
        height: parent.height
        verticalAlignment:
            Label.AlignVCenter
        text: name
        font.family: "Roboto"
        font.pixelSize: 20
        font.bold: true
        color: "white"
    }
    TextField {
        id: textField
        height: parent.height
        anchors.right: parent.right
        anchors.left: labelName.right
        anchors.verticalCenter:
            labelName.verticalCenter
        verticalAlignment:
            Label.AlignBottom
        enabled: editable
    }
}
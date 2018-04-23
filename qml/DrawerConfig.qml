import QtQuick 2.8
import QtQuick.Controls 2.2

Drawer {
    edge: Qt.LeftEdge

    Text {
        id: title
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter:
            parent.horizontalCenter
        text: "Filter"
        font.family: "Calibri"
        font.underline: true
        font.pixelSize: 20
        font.bold: true
        color: "white"
    }
}

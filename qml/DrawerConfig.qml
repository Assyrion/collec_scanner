import QtQuick 2.8
import QtQuick.Controls 2.2

Drawer {
    edge: Qt.LeftEdge
    onClosed: {
        filterName.clear()
    }

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
    TextField {
        id: filterName
        anchors.top: title.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        placeholderText: "Search by name"
    }
    Button {
        id: applyFilterBtn
        anchors.top: filterName.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter:
            filterName.horizontalCenter
        text: filterName.text == "" ? "X" : "OK"
        onClicked: {
            sqlTableModel.filterByTitle(filterName.text)
            close()
        }
    }
}

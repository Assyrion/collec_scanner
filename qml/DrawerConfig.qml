import QtQuick 2.8
import QtQuick.Controls 2.2

Drawer {
    id: root

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
        font.family: "Roboto"
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
    Button {
        id: saveDBBtn
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.horizontalCenter:
            parent.horizontalCenter
        text: "save DB"
        onClicked: {
            loader.loadConfirmSaveDB()
        }
    }
    Loader {
        id: loader
        function loadConfirmSaveDB() {
            loader.setSource("PopupConfirmSaveDB.qml",
                             {   "width" : 2*mainWindow.width/3,
                                 "height": mainWindow.height/3,
                                 "x"     : mainWindow.width/6,
                                 "y"     : mainWindow.height/4+50})
        }
        Connections {
            target: loader.item
            onAccepted: {
                sqlTableModel.saveDBToFile(fileManager)
                close()
            }
        }
    }
}

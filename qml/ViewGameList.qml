import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Controls 1.4 as Old
import "utils"

Pane {
    signal backToMenuRequired

//    CSButton {
//        id: returnBtn
//        anchors.top: parent.top
//        anchors.topMargin: 20
//        anchors.left: parent.left
//        anchors.leftMargin: 20
//        text: "Menu"
//        onClicked: {
//            backToMenuRequired()
//        }
//    }

    Old.TableView {
        anchors.fill: parent
        model: sqlTableModel
        headerVisible: true
//        backgroundVisible : false
        headerDelegate: Rectangle {
            width: parent.width
            height: 50
            color: "red"
            Text {
                text: "frrrrrrf"
                color: "white"
            }
        }
    }
}

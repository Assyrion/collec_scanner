import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.2

Window {
    id: root
    visible: true
    visibility: Window.AutomaticVisibility
    //    title: qsTr("Hello World")
    height:1000
    width: 1000

    Rectangle {
        id: bckgnd
        anchors.fill: parent
        color: "black"
    }

    Component {
        id: vbsCpt
        ViewBarcodeScanner {
            onNewGameCreationRequired: {
                stackView.push(vcgCpt)
            }
            onBackToMenuRequired: {
                stackView.pop()
            }
        }
    }

    Component {
        id: vcgCpt
        ViewCreateGame {
            onBackToMenuRequired: {
                stackView.pop()
            }
        }
    }

    StackView {
        id: stackView
        anchors.fill: bckgnd

        initialItem: vcgCpt/*Item {
            Row {
                anchors.centerIn: parent
                spacing: 20
                Button {
                    id: scanBtn
                    text: "scan barcode"
                    onClicked: {
                        stackView.push(vbsCpt)
                    }
                }
                Button {
                    id: showListBtn
                    text: "show list"
                }
            }
        }*/
    }
}

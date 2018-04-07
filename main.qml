import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import "qml"
import "qml/utils"

Window {
    id: root
    visible: true
    visibility: Window.AutomaticVisibility

    height:1280
    width: 720

    Component {
        id: vbsCpt
        ViewBarcodeScanner {
            onNewGameCreationRequired: {
                stackView.replace(vcgCpt, {"tag": tag})
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
        anchors.fill: parent

        initialItem: Pane {
            id: menu
            Row {
                anchors.centerIn: parent
                spacing: 50
                CSButton {
                    id: scanBtn
                    text: qsTr("scan barcode")
                    onClicked: {
                        stackView.push(vbsCpt)
                    }
                }
                CSButton {
                    id: showListBtn
                    text: qsTr("show list")
                }
            }
        }
    }
}

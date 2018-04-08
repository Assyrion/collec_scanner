import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import GameData 1.0
import "qml"
import "qml/utils"

Window {
    id: mainWindow
    visible: true
    visibility: Window.AutomaticVisibility

    height: 568
    width : 360

    Component {
        id: vbsCpt
        ViewBarcodeScanner {
            onNewGameCreationRequired: {
                var game = {tag: tag,
                title: "", platform: "ps3",
                publisher: "", developer: ""}

                stackView.replace(vcgCpt, {"editMode"    : true,
                                           "initial_game": game})
            }
            onBackToMenuRequired: {
                stackView.pop()
            }
        }
    }

    Component {
        id: vcgCpt
        ViewGameData {
            onClosed: {
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
                width: implicitWidth
                anchors.centerIn: parent
                spacing: 25
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

    Text {
        id: debug
        anchors.left: parent.left
        anchors.leftMargin: 20
        font.family: "Calibri"
        font.pointSize: 20
        color: "white"
    }
}

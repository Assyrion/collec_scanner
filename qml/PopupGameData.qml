import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs.qml 1.0
import GameData 1.0
import "utils"

Popup {
    id: root

    property bool editMode: false

    function show(game) {
        tagTextField.text       = game.tag
        titleTextField.text     = game.title
        platformTextField.text  = game.platform
        publisherTextField.text = game.publisher
        developerTextField.text = game.developer

        open()
    }

    padding: 0

    modal: true
    closePolicy: Popup.NoAutoClose

    contentItem : Pane {
        GridLayout {
            id: columnLayout
            width: 2/3 * parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 20
            enabled: root.editMode
            columns: 2
            columnSpacing: 50
            rowSpacing: 20

            Label {
                text: qsTr("Tag")
                font.family: "Calibri"
                font.pixelSize: 20
                font.bold: true
                color: "white"
                bottomPadding: 10
                Layout.alignment: Qt.AlignRight
            }
            TextField {
                id: tagTextField
                enabled: false
                leftPadding: 10
                Layout.fillWidth: true
            }
            Label {
                text: qsTr("Title")
                font.family: "Calibri"
                font.pixelSize: 20
                font.bold: true
                color: "white"
                bottomPadding: 10
                Layout.alignment: Qt.AlignRight
            }
            TextField {
                id: titleTextField
                leftPadding: 10
                Layout.fillWidth: true
            }
            Label {
                text: qsTr("Platform")
                font.family: "Calibri"
                font.pixelSize: 20
                font.bold: true
                color: "white"
                bottomPadding: 10
                Layout.alignment: Qt.AlignRight
            }
            TextField {
                id: platformTextField
                leftPadding: 10
                Layout.fillWidth: true
            }
            Label {
                text: qsTr("Publisher")
                font.family: "Calibri"
                font.pixelSize: 20
                font.bold: true
                color: "white"
                bottomPadding: 10
                Layout.alignment: Qt.AlignRight
            }
            TextField {
                id: publisherTextField
                leftPadding: 10
                Layout.fillWidth: true
            }
            Label {
                text: qsTr("Developer")
                font.family: "Calibri"
                font.pixelSize: 20
                font.bold: true
                color: "white"
                bottomPadding: 10
                Layout.alignment: Qt.AlignRight
            }
            TextField {
                id: developerTextField
                leftPadding: 10
                Layout.fillWidth: true
            }
        }
        Row {
            anchors.top: columnLayout.bottom
            anchors.horizontalCenter: columnLayout.horizontalCenter
            anchors.topMargin: 20
            spacing: 20
            Button {
                width: 100
                text: qsTr("close")
                onClicked: {
                    close()
                }
            }
            Button {
                width: 100
                text: qsTr("edit")
                onClicked: {
                    root.editMode = true
                }
            }
            Button {
                width: 100
                text: qsTr("save")
                enabled: root.editMode
                onClicked: {
                    close()
                }
            }
        }
    }
}

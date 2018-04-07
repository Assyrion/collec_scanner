import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs.qml 1.0
import GameData 1.0
import "utils"

Pane {
    id: root

    signal backToMenuRequired
    property alias tag: tagTextField.text

    GameData {
        id: game
        tag       : root.tag
        title     : titleTextField.text
        platform  : platformComboBox.currentText
        publisher : publisherTextField.text
        developer : developerTextField.text
    }

    ColumnLayout {
        id: columnLayout
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: parent.width / 2
        spacing: 20
        anchors.topMargin: 20

        TextField {
            id: tagTextField
            enabled: false
            leftPadding: 10
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBaseline
            readOnly: true
        }

        TextField {
            id: titleTextField
            leftPadding: 10
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBaseline
            placeholderText: qsTr("Title")
        }

        TextField {
            id: publisherTextField
            leftPadding: 10
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBaseline
            placeholderText: qsTr("Publisher")
        }

        TextField {
            id: developerTextField
            leftPadding: 10
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBaseline
            placeholderText: qsTr("Developer")
        }

        ComboBox {
            id: platformComboBox
            currentIndex: 2
            textRole: qsTr("")
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBaseline

            model: ["ps1", "ps2", "ps3", "ps4"]
        }

        Button {
            id: okBtn
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            text: "ok"
            onClicked: {
                dbManager.addEntry(game)
                backToMenuRequired()
            }
        }
        CSButton {
            id: cancelBtn
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            text: "cancel"
            onClicked: {
                backToMenuRequired()
            }
        }
    }
}

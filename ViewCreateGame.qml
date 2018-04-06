import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs.qml 1.0

Item {
    id: root

    signal backToMenuRequired

    ColumnLayout {
        id: columnLayout
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: parent.width / 2
        spacing: 20
        anchors.topMargin: 20

        TextField {
            id: tagTextField
            text: qsTr("")
            Layout.fillWidth: true
            enabled: false
            font.family: "Calibri"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBaseline
            readOnly: true
            background: Rectangle {
                color: "white"
                opacity: 0.5
            }
        }

        TextField {
            id: titleTextField
            topPadding: 10
            leftPadding: 10
            Layout.fillWidth: true
            renderType: Text.NativeRendering
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBaseline
            placeholderText: qsTr("Title")
            background: Rectangle {
                color: "white"
                opacity: 0.5
            }
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
            }
        }
        Button {
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

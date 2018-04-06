import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs.qml 1.0
import GameData 1.0

Popup {
    id: popup

    function show(game) {
        tagTextField.text       = game.tag
        titleTextField.text     = game.title
        platformTextField.text  = game.platform
        publisherTextField.text = game.publisher
        developerTextField.text = game.developer

        open()
    }

    modal: true
    closePolicy: Popup.NoAutoClose

    contentItem : Pane {
        id: root

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
            }

            TextField {
                id: titleTextField
                leftPadding: 10
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBaseline
            }

            TextField {
                id: platformTextField
                leftPadding: 10
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBaseline
            }

            TextField {
                id: publisherTextField
                leftPadding: 10
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBaseline
            }

            TextField {
                id: developerTextField
                leftPadding: 10
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBaseline
            }

            Button {
                id: okBtn
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                text: "ok"
                onClicked: {
                    close()
                }
            }
        }
    }
}

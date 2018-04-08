import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs.qml 1.0
import QtGraphicalEffects 1.0
import GameData 1.0
import "utils"

Popup {
    id: root

    property bool editMode: false

    onClosed: {
        editMode = false
        game.clear()
    }

    function show(game) {
        tagTextField.text       = game.tag
        titleTextField.text     = game.title
        platformTextField.text  = game.platform
        publisherTextField.text = game.publisher
        developerTextField.text = game.developer
        picFrontImg.source      = imageManager.getFrontPicGrab(game.tag)
        picBackImg.source       = imageManager.getBackPicGrab(game.tag)
        open()
    }

    GameData {
        id: game
        tag       : tagTextField.text
        title     : titleTextField.text
        platform  : platformTextField.text
        publisher : publisherTextField.text
        developer : developerTextField.text
    }

    padding: 0

    modal: true
    closePolicy: Popup.NoAutoClose

    contentItem : Pane {
        Row {
            id : picRow
            anchors.top: parent.top
            anchors.horizontalCenter:
                parent.horizontalCenter
            anchors.topMargin: 20
            spacing: 50
            height: root.height/5
            enabled: root.editMode

            CSGlowImage {
                id : picFrontImg
                height: parent.height
                width: implicitWidth
                onClicked: {
                    loader.loadSnapshotPopup(this)
                }
            }
            CSGlowImage {
                id : picBackImg
                height: parent.height
                width: implicitWidth
                onClicked: {
                    loader.loadSnapshotPopup(this)
                }
            }
        }
        GridLayout {
            id: columnLayout
            width: 2/3 * parent.width
            anchors.horizontalCenter:
                parent.horizontalCenter
            anchors.top: picRow.bottom
            anchors.topMargin: 50
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
            anchors.topMargin: 50
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
                    imageManager.saveFrontPicGrab(game.tag, picFrontImg.grabResult)
                    imageManager.saveBackPicGrab( game.tag, picBackImg.grabResult)
                    dbManager.editEntry(game)
                    close()
                }
            }
        }
    }
    Loader {
        id: loader
        function loadSnapshotPopup(img) {
            loader.setSource("PopupTakeSnapshot.qml",
                             { "boundImg": img,
                                 "width" : root.width/2,
                                 "height": root.height/2,
                                 "x"     : root.width/4,
                                 "y"     : root.height/4})
        }
    }
}

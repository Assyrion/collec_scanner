import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs.qml 1.0
import QtGraphicalEffects 1.0
import GameData 1.0
import "utils"

Pane {
    id: root

    signal closed
    property bool editMode: false
    property var initial_game

    Component.onCompleted:  {
        picFrontImg.source = imageManager.getFrontPicGrab(new_game.tag)
        picBackImg.source  = imageManager.getBackPicGrab( new_game.tag)
    }

    GameData {
        id: new_game
        tag       : tagTextField.text
        title     : titleTextField.text
        platform  : platformTextField.text
        publisher : publisherTextField.text
        developer : developerTextField.text
    }

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
            text: initial_game.tag
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
            text: initial_game.title
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
            text: initial_game.platform
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
            text: initial_game.publisher
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
            text: initial_game.developer
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
                closed()
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
                imageManager.saveFrontPicGrab(new_game.tag, picFrontImg.grabResult)
                imageManager.saveBackPicGrab( new_game.tag, picBackImg.grabResult)

                dbManager.writeEntry(new_game)
                closed()
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

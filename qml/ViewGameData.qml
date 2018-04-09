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
    property var game

    Component.onCompleted:  {
        // for initial game
        tagTextField.text       = game.tag
        titleTextField.text     = game.title
        platformTextField.text  = game.platform
        publisherTextField.text = game.publisher
        developerTextField.text = game.developer
        picFrontImg.source      = imageManager.getFrontPicGrab(game.tag)
        picBackImg.source       = imageManager.getBackPicGrab( game.tag)

        // binding modifs
        game.title     = Qt.binding(function(){return titleTextField.text})
        game.platform  = Qt.binding(function(){return platformTextField.text})
        game.publisher = Qt.binding(function(){return publisherTextField.text})
        game.developer = Qt.binding(function(){return developerTextField.text})
    }

    ScrollView {
        anchors.top: parent.top
        anchors.bottom: btnRow.top
        anchors.bottomMargin: 25
        contentWidth: parent.width
        ScrollBar.vertical.policy:
            ScrollBar.AlwaysOff

        Row {
            id : picRow
            anchors.top: parent.top
            anchors.horizontalCenter:
                parent.horizontalCenter
            spacing: 25
            height : root.height/4
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
            anchors.top: picRow.bottom
            anchors.topMargin: 25
            width: parent.width
            enabled: root.editMode
            columns: 2
            columnSpacing: 20
            rowSpacing: 20

            Label {
                text: qsTr("Tag")
                font.family: "Calibri"
                font.pixelSize: 20
                font.bold: true
                color: "white"
                bottomPadding: 10
                width: parent.width/3
                Layout.alignment: Qt.AlignRight
            }
            TextField {
                id: tagTextField
                enabled: false
                leftPadding: 10
                Layout.fillWidth: true
//                text: initial_game.tag
            }
            Label {
                text: qsTr("Title")
                font.family: "Calibri"
                font.pixelSize: 20
                font.bold: true
                color: "white"
                bottomPadding: 10
                width: parent.width/3
                Layout.alignment: Qt.AlignRight
            }
            TextField {
                id: titleTextField
                leftPadding: 10
                Layout.fillWidth: true
//                text: initial_game.title
            }
            Label {
                text: qsTr("Platform")
                font.family: "Calibri"
                font.pixelSize: 20
                font.bold: true
                color: "white"
                bottomPadding: 10
                width: parent.width/3
                Layout.alignment: Qt.AlignRight
            }
            TextField {
                id: platformTextField
                leftPadding: 10
                Layout.fillWidth: true
//                text: initial_game.platform
            }
            Label {
                text: qsTr("Publisher")
                font.family: "Calibri"
                font.pixelSize: 20
                font.bold: true
                color: "white"
                bottomPadding: 10
                width: parent.width/3
                Layout.alignment: Qt.AlignRight
            }
            TextField {
                id: publisherTextField
                leftPadding: 10
                Layout.fillWidth: true
//                text: initial_game.publisher
            }
            Label {
                text: qsTr("Developer")
                font.family: "Calibri"
                font.pixelSize: 20
                font.bold: true
                color: "white"
                bottomPadding: 10
                width: parent.width/3
                Layout.alignment: Qt.AlignRight
            }
            TextField {
                id: developerTextField
                leftPadding: 10
                Layout.fillWidth: true
//                text: initial_game.developer
            }
        }
    }
    Row {
        id: btnRow
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -20
        anchors.horizontalCenter:
            parent.horizontalCenter
        spacing: 10
        scale: 0.77
        CSButton {
            text: qsTr("close")
            onClicked: {
                closed()
            }
        }
        CSButton {
            text: qsTr("edit")
            onClicked: {
                root.editMode = true
            }
        }
        CSButton {
            text: qsTr("save")
            enabled: root.editMode
            onClicked: {
                imageManager.saveFrontPicGrab(game.tag, picFrontImg.grabResult)
                imageManager.saveBackPicGrab( game.tag, picBackImg.grabResult)

                dbManager.writeEntry(game)
                closed()
            }
        }
    }

    Loader {
        id: loader
        function loadSnapshotPopup(img) {
            loader.setSource("PopupTakeSnapshot.qml",
                             { "boundImg": img,
                                 "width" : 2*root.width/3,
                                 "height": 2*root.height/3,
                                 "x"     : (2*root.width/3)-root.width/2,
                                 "y"     : (2*root.height/3)-root.height/2})
        }
    }
}

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

    function readGame() {
        dataRepeater.itemAt(0).entry = game.tag
        dataRepeater.itemAt(1).entry = game.title
        dataRepeater.itemAt(2).entry = game.platform
        dataRepeater.itemAt(3).entry = game.publisher
        dataRepeater.itemAt(4).entry = game.developer
        picFrontImg.source = imageManager.getFrontPicGrab(game.tag)
        picBackImg.source  = imageManager.getBackPicGrab( game.tag)
    }

    function writeGame() {
        game.title     = dataRepeater.itemAt(1).entry
        game.platform  = dataRepeater.itemAt(2).entry
        game.publisher = dataRepeater.itemAt(3).entry
        game.developer = dataRepeater.itemAt(4).entry
        imageManager.saveFrontPicGrab(game.tag, picFrontImg.grabResult)
        imageManager.saveBackPicGrab( game.tag, picBackImg.grabResult)
        dbManager.writeEntry(game)
    }

    Component.onCompleted:  {
        readGame()
    }

    ScrollView {
        id: scrollView
        anchors.top: parent.top
        height: parent.height-btnRow.height
        contentWidth: parent.width
        enabled: root.editMode

        ScrollBar.vertical.policy:
            ScrollBar.AlwaysOff

        Row {
            id : picRow
            anchors.top: parent.top
            anchors.horizontalCenter:
                parent.horizontalCenter
            spacing: 25
            height : root.height/4

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

        Column {
            id: dataColumn
            width: parent.width
            anchors.top: picRow.bottom
            anchors.topMargin: 25
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 25
            spacing: 5
            Repeater {
                id: dataRepeater
                model: ListModel {
                    ListElement { name: qsTr("Tag");       editable: false }
                    ListElement { name: qsTr("Title");     editable: true  }
                    ListElement { name: qsTr("Platform");  editable: true  }
                    ListElement { name: qsTr("Publisher"); editable: true  }
                    ListElement { name: qsTr("Developer"); editable: true  }
                }
                delegate: Item {
                    property alias entry: tagTextField.text

                    width: parent.width
                    height: parent.height
                            /dataRepeater.count

                    Label {
                        id: labelName
                        width: parent.width/3
                        height: parent.height
                        verticalAlignment:
                            Label.AlignVCenter
                        text: name
                        font.family: "Calibri"
                        font.pixelSize: 20
                        font.bold: true
                        color: "white"
                    }
                    TextField {
                        id: tagTextField
                        width: 2*parent.width/3
                        height: parent.height
                        anchors.left: labelName.right
                        anchors.verticalCenter:
                            labelName.verticalCenter
                        verticalAlignment:
                            Label.AlignBottom
                        enabled: editable
                    }
                }
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
                writeGame()
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

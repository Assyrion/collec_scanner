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
    property int row: -1

    function readGame() {
        dataRepeater.itemAt(0).entry = game.tag
        dataRepeater.itemAt(1).entry = game.title
        dataRepeater.itemAt(2).entry = game.platform
        dataRepeater.itemAt(3).entry = game.publisher
        dataRepeater.itemAt(4).entry = game.developer
        dataRepeater.itemAt(5).entry = game.info
        picFrontImg.source = imageManager.getFrontPic(game.tag)
        picBackImg.source  = imageManager.getBackPic( game.tag)
    }

    function writeGame() {
        game.title     = dataRepeater.itemAt(1).entry
        game.platform  = dataRepeater.itemAt(2).entry
        game.publisher = dataRepeater.itemAt(3).entry
        game.developer = dataRepeater.itemAt(4).entry
        game.info      = dataRepeater.itemAt(5).entry
        imageManager.saveFrontPic(game.tag, picFrontImg.grabResult)
        imageManager.saveBackPic( game.tag, picBackImg.grabResult)
        sqlTableModel.update(row, game)
    }

    function removeGame() {
        imageManager.removePics(game.tag)
        sqlTableModel.remove(row)
    }

    Component.onCompleted:  {
        readGame()
    }

    Flickable {
        id: scrollView
        anchors.top: parent.top
        height: parent.height
                -btnRow.height
                - 20
        width: parent.width
        flickableDirection:
            Flickable.VerticalFlick
        clip: true

        contentWidth: root.width;
        contentHeight: picRow.height
                       + dataColumn.implicitHeight
                       + 10

        RowLayout {
            id : picRow
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: -10
            height : root.height/4
            width: parent.width
            enabled: root.editMode
            spacing: 20

            CSGlowImage {
                id : picFrontImg
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    loader.loadSnapshotPopup(this)
                }
            }
            CSGlowImage {
                id : picBackImg
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignLeft
                onClicked: {
                    loader.loadSnapshotPopup(this)
                }
            }
        }

        Column {
            id: dataColumn
            width: parent.width
            anchors.top: picRow.bottom
            anchors.topMargin: 15
            enabled: root.editMode
            spacing: 7
            Repeater {
                id: dataRepeater
                model: ListModel {
                    ListElement { name: qsTr("Tag");       editable: false }
                    ListElement { name: qsTr("Title");     editable: true  }
                    ListElement { name: qsTr("Platform");  editable: true  }
                    ListElement { name: qsTr("Publisher"); editable: true  }
                    ListElement { name: qsTr("Developer"); editable: true  }
                    ListElement { name: qsTr("info");      editable: true  }
                }
                delegate: Item {
                    property alias entry: textField.text

                    width: parent.width
                    height: 55

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
                        id: textField
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

    RowLayout {
        id: btnRow
        height: 50
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        anchors.horizontalCenter:
            parent.horizontalCenter
        spacing: 15
        CSButton {
            text: qsTr("close")
            onClicked: {
                closed()
            }
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignCenter
        }
        CSButton {
            text: editMode ? qsTr("save")
                           : qsTr("edit")
            onClicked: {
                if(editMode) {
                    writeGame()
                    closed()
                } else {
                    root.editMode = true
                }
            }
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignCenter
        }
        CSButton {
            text: qsTr("delete")
            visible: row >= 0
            onClicked: {
                loader.loadConfirmDelete()
            }
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignCenter
        }
    }

    Loader {
        id: loader
        function loadSnapshotPopup(img) {
            loader.setSource("PopupTakeSnapshot.qml",
                             { "boundImg": img,
                                 "width" : 2*root.width/3,
                                 "height": 2*root.height/3,
                                 "x"     : root.width/6-10,
                                 "y"     : root.height/3-40})
        }
        function loadConfirmDelete() {
            loader.setSource("PopupConfirmDelete.qml",
                             {   "width" : 2*root.width/3,
                                 "height": root.height/3,
                                 "x"     : root.width/6-10,
                                 "y"     : root.height/4+20})
        }
        Connections {
            target: loader.item
            ignoreUnknownSignals: true
            onAccepted: {
                removeGame()
                closed()
            }
        }
    }
}

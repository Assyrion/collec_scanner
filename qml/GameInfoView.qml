import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects
import GameData 1.0
import "utils"

Pane {
    id: root

    signal closed

    property var game: GameDataMaker.createEmpty()
    property bool editMode: false
    property bool manuMode: false
    property int row: -1

    Component.onCompleted:  {
        readGame()
    }

    topPadding: 0
    bottomPadding: 0

    function readGame() {
        if(manuMode) {
            var rand = Math.random().toFixed(6)
            dataRepeater.itemAt(0).entry = Qt.binding(function() {
                var _in  = "notag_" + dataRepeater.itemAt(2).entry
                        + '_' + rand // very unlikely that 2 games have same tag
                _in = _in.replace(/\W/g,'')
                return _in
            })
        } else {
            dataRepeater.itemAt(0).entry = game.tag
        }
        dataRepeater.itemAt(1).entry = row >= 0 ? (row+1) + '/'
                                                  + sqlTableModel.rowCount() : ""
        dataRepeater.itemAt(2).entry = game.code
        dataRepeater.itemAt(3).entry = game.title
        dataRepeater.itemAt(4).entry = game.platform
        dataRepeater.itemAt(5).entry = game.info
        dataRepeater.itemAt(6).entry = game.publisher
        dataRepeater.itemAt(7).entry = game.developer

        gameCoverRow.frontCoverUrl = imageManager.getFrontPic(game.tag)
        gameCoverRow.backCoverUrl  = imageManager.getBackPic( game.tag)
    }

    function writeGame() {
        game.tag       = dataRepeater.itemAt(0).entry
        game.code      = dataRepeater.itemAt(2).entry
        game.title     = dataRepeater.itemAt(3).entry
        game.platform  = dataRepeater.itemAt(4).entry
        game.info      = dataRepeater.itemAt(5).entry
        game.publisher = dataRepeater.itemAt(6).entry
        game.developer = dataRepeater.itemAt(7).entry
        sqlTableModel.update(row, game)

        if(gameCoverRow.frontCoverData) {
            imageManager.saveFrontPic(game.tag, gameCoverRow.frontCoverData)
            coverManager.handleFrontCover(game.tag)
        }
        if(gameCoverRow.backCoverData) {
            imageManager.saveBackPic(game.tag, gameCoverRow.backCoverData)
            coverManager.handleBackCover(game.tag)
        }
    }

    function removeGame() {
        imageManager.removePics(game.tag)
        sqlTableModel.remove(row)
    }

    Flickable {
        id: scrollView
        anchors.top: parent.top
        width: parent.width
        height: parent.height
                - btnRow.height
                - 20
        clip: true
        boundsBehavior:     Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        contentHeight: gameCoverRow.height
                       + dataColumn.implicitHeight
                       + 30

        GameInfoCoverRow {
            id: gameCoverRow

            anchors.top: parent.top
            anchors.topMargin: 20
            height : root.height/4
            anchors.horizontalCenter:
                parent.horizontalCenter
            anchors.horizontalCenterOffset:
                shiftFactor
            z: 1

            onEditCoverRequired:(img) => {
                loader.loadSnapshotPopup(img)
            }

            editMode: root.editMode
            mouseArea: globalMa
        }

        Column {
            id: dataColumn
            width: parent.width
            anchors.top: gameCoverRow.bottom
            anchors.topMargin: 15
            enabled: root.editMode
            spacing: 7
            Repeater {
                id: dataRepeater

                model: ListModel {
                    ListElement { name: qsTr("Tag");       editable: false }
                    ListElement { name: qsTr("Index");     editable: false }
                    ListElement { name: qsTr("Code");      editable: true  }
                    ListElement { name: qsTr("Title");     editable: true  }
                    ListElement { name: qsTr("Platform");  editable: true  }
                    ListElement { name: qsTr("info");      editable: true  }
                    ListElement { name: qsTr("Publisher"); editable: true  }
                    ListElement { name: qsTr("Developer"); editable: true  }
                }
                delegate: GameInfoListDelegate {
                    width: parent.width
                    height: 45
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
        Button {
            text: qsTr("close")
            onClicked: {
                closed()
            }
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignCenter
        }
        Button {
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
        Button {
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
            loader.setSource("TakeSnapshotPopup.qml",
                             { "boundImg": img,
                                 "width" : 2*root.width/3,
                                 "height": root.height/2,
                                 "x"     : root.width/6-12,
                                 "y"     : root.height/3-40})
        }
        function loadConfirmDelete() {
            loader.setSource("ConfirmDeletePopup.qml",
                             {   "width" : 2*root.width/3,
                                 "height": root.height/3,
                                 "x"     : root.width/6-12,
                                 "y"     : root.height/4+20})
        }
        Connections {
            target: loader.item
            ignoreUnknownSignals: true
            function onAccepted() {
                removeGame()
                closed()
            }
        }
    }

    MouseArea {
        id: globalMa
        anchors.fill: parent
        enabled : false
    }
}
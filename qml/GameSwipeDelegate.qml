import QtQuick 6.2
import QtQuick.Controls 6.2

Item {
    id: root

    property var game
    property bool editMode: false
    property int row: -1

    Component.onCompleted:  {
        readGame()
    }

    function loadSnapshotPopup(img) {
        var cpt = Qt.createComponent("TakeSnapshotPopup.qml")
        if (cpt.status === Component.Ready) {
            cpt.createObject(root, { "boundImg": img,
                                 "width" : root.width * 0.55,
                                 "height": root.height * 0.6,
                                 "x"     : root.width * 0.22,
                                 "y"     : root.height * 0.3})
        }
    }

    function readGame() {
        if(game.tag === "") {
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


    GameInfoCoverRow {
        id: gameCoverRow

        anchors.top: parent.top
        anchors.topMargin: 10
        height : root.height/4
        anchors.horizontalCenter:
            parent.horizontalCenter
        anchors.horizontalCenterOffset:
            shiftFactor
        z: 1

        onEditCoverRequired:(img) => {
                                loadSnapshotPopup(img)
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

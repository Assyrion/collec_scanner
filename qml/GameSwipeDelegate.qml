import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 6.2

import GameData 1.0

Item {
    id: root

    property var game: GameDataMaker.createEmpty()

    property bool editMode: false
    property int row: -1

    property string currentTag: ""

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
        if(currentTag === "") {
            var rand = Math.random().toFixed(6)
            currentTag = Qt.binding(function() {
                var _in  = "notag_" + tagInfo.entry
                        + '_' + rand // very unlikely that 2 games have same tag
                _in = _in.replace(/\W/g,'')
                return _in
            })
        } else {
            if(row < 0)
                currentTag = tag
            else {
                var arr = [tag, title, full_title, platform,
                           publisher, developer, code, info]
                game = GameDataMaker.createComplete(arr)
            }
        }

        gameCoverRow.frontCoverUrl = imageManager.getFrontPic(tag)
        gameCoverRow.backCoverUrl  = imageManager.getBackPic(tag)
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
        //        mouseArea: globalMa
    }

    ColumnLayout {
        id: dataColumn
        width: parent.width
        anchors.top: gameCoverRow.bottom
        anchors.topMargin: 15
        enabled: root.editMode
        spacing: 7

        GameInfoListDelegate {
            id: tagInfo
            name: qsTr("Tag");  entry:  tag; editable: false
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 45
        }
        GameInfoListDelegate {
            id: indexInfo
            name: qsTr("Index");  entry:  index; editable: false
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 45
        }
        GameInfoListDelegate {
            id: codeInfo
            name: qsTr("Code");  entry:  code; editable: false
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 45
        }
        GameInfoListDelegate {
            id: titleInfo
            name: qsTr("Title");  entry:  title; editable: false
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 45
        }
        GameInfoListDelegate {
            id: platformInfo
            name: qsTr("Platform");  entry:  platform; editable: false
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 45
        }
        GameInfoListDelegate {
            id: infoInfo
            name: qsTr("info");  entry: info ; editable: false
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 45
        }
        GameInfoListDelegate {
            id: publisherInfo
            name: qsTr("Publisher");  entry:  publisher; editable: false
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 45
        }
        GameInfoListDelegate {
            id: developerInfo
            name: qsTr("Developer");  entry:  developer; editable: false
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 45
        }
    }
}


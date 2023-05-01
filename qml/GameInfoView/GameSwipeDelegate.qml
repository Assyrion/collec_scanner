import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 6.2

import GameData 1.0

Item {
    id: root

    property int index: -1
    property bool editMode: false
    property string currentTag: ""
    property GameData currentGame:
        GameDataMaker.createEmpty()

    Component.onCompleted:  {
        readGame()
    }

    function showSnapshotPopup(img) {
        var cpt = Qt.createComponent("TakeSnapshotPopup.qml")
        if (cpt.status === Component.Ready) {
            cpt.createObject(root, { "boundImg": img,
                                 "width" : root.width * 0.8,
                                 "height": root.height * 0.6,
                                 "x"     : root.width * 0.1,
                                 "y"     : root.height * 0.27})
        }
    }

    function readGame() {
        if(currentTag === "") {
            var rand = Math.random().toFixed(6)
            currentTag = Qt.binding(function() {
                var _in  = "notag_" + titleInfo.entry
                        + '_' + rand // very unlikely that 2 games have same tag
                _in = _in.replace(/\W/g,'')
                return _in
            })
        } else {
            currentTag = tag
        }
        reloadCovers()
    }

    function saveGame() {
        // handle cover before modifying DB !
        if(gameCoverRow.frontCoverData) {
            imageManager.saveFrontPic(currentTag, gameCoverRow.frontCoverData)
            comManager.handleFrontCover(currentTag)
        }
        if(gameCoverRow.backCoverData) {
            imageManager.saveBackPic(currentTag, gameCoverRow.backCoverData)
            comManager.handleBackCover(currentTag)
        }
        var arr = [currentTag,
                   titleInfo.entry,
                   platformInfo.entry,
                   publisherInfo.entry,
                   developerInfo.entry,
                   codeInfo.entry,
                   infoInfo.entry]

        currentGame = GameDataMaker.createComplete(arr)
        sqlTableModel.update(index, currentGame)
    }

    function removeGame() {
        imageManager.removePics(currentTag)
        sqlTableModel.remove(index, currentTag)
    }

    function cancelGame() {
        for (var i = 0; i < dataColumn.children.length; i++) {
            dataColumn.children[i].reset()
        }
        reloadCovers()
    }

    function reloadCovers() {
        gameCoverRow.frontCoverUrl  = imageManager.getFrontPic(currentTag)
        gameCoverRow.frontCoverData = null
        gameCoverRow.backCoverUrl   = imageManager.getBackPic(currentTag)
        gameCoverRow.backCoverData  = null
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
                                showSnapshotPopup(img)
                            }

        editMode: root.editMode
        mouseArea: globalMa
    }

    ColumnLayout {
        id: dataColumn
        width: parent.width - 20
        anchors.horizontalCenter:
            parent.horizontalCenter
        anchors.top: gameCoverRow.bottom
        anchors.topMargin: 15
        enabled: root.editMode
        spacing: 7

        GameInfoListDelegate {
            id: tagInfo
            name: qsTr("Tag"); entry: currentTag; editable: false
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
        }
        GameInfoListDelegate {
            id: indexInfo
            name: qsTr("Index"); entry: index; editable: false
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
        }
        GameInfoListDelegate {
            id: codeInfo
            name: qsTr("Code"); entry: code; editable: editMode
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
        }
        GameInfoListDelegate {
            id: titleInfo
            name: qsTr("Title"); entry: title; editable: editMode
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
        }
        GameInfoListDelegate {
            id: platformInfo
            name: qsTr("Platform"); entry: platform; editable: editMode
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
        }
        GameInfoListDelegate {
            id: infoInfo
            name: qsTr("info"); entry: info; editable: editMode
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
        }
        GameInfoListDelegate {
            id: publisherInfo
            name: qsTr("Publisher"); entry: publisher; editable: editMode
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
        }
        GameInfoListDelegate {
            id: developerInfo
            name: qsTr("Developer"); entry: developer; editable: editMode
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
        }
    }

    MouseArea {
        id: globalMa
        anchors.fill: parent
        enabled : false
    }
}


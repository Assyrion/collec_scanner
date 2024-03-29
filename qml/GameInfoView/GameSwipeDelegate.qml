import QtQuick 6.2
import QtQuick.Layouts 6.2
import QtQuick.Controls 6.2

import GameData 1.0

import "../utils/PlatformSelector.js" as Platforms

Pane {
    id: root

    // Pane has a default padding non null
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    property int count: 0
    property int index: -1

    property bool isOwned : (index < 0) || (model?.owned)
    property bool editMode: false
    property string currentTag: ""

    Component.onCompleted: {
        if(index < 0 && currentTag === "") { // new game creation
            var rand = Math.random().toFixed(6)
            currentTag = Qt.binding(function() {
                var _in  = "notag_" + titleInfo.entry
                        + '_' + rand // very unlikely that 2 games have same tag
                _in = _in.replace(/\W/g,'')
                return _in
            })
        } else if(index >= 0){
            currentTag = Qt.binding(() => { return model.tag })
        }
    }

    function showSnapshotPopup(img) {
        var coverRatio = Platforms.list[platformName].coverRatio
        var cpt = Qt.createComponent("TakeSnapshotPopup.qml")
        if (cpt.status === Component.Ready) {
            cpt.createObject(root, { "boundImg": img,
                                 "coverRatio" : coverRatio,
                                 "width" : root.width * 0.8,
                                 "height": root.height * 0.6,
                                 "x"     : root.width * 0.1,
                                 "y"     : root.height * 0.27})
        }
    }

    function saveGame() {

        // handle cover before modifying DB !
        var coverSubfolder = platformName + "/" + currentTag

        if(gameCoverRow.frontCoverData) {
            imageManager.saveFrontPic(coverSubfolder,
                                      gameCoverRow.frontCoverData)
            comManager.handleFrontCover(coverSubfolder)
        }
        if(gameCoverRow.backCoverData) {
            imageManager.saveBackPic(coverSubfolder,
                                     gameCoverRow.backCoverData)
            comManager.handleBackCover(coverSubfolder)
        }

        if(index < 0) {
            var sqlModel = dbManager.currentSqlModel

            sqlModel.insertRow(0)
            sqlModel.setData(sqlModel.index(0, 0), currentTag)
            sqlModel.setData(sqlModel.index(0, 1), titleInfo.entry)
            sqlModel.setData(sqlModel.index(0, 2), platformInfo.entry)
            sqlModel.setData(sqlModel.index(0, 3), publisherInfo.entry)
            sqlModel.setData(sqlModel.index(0, 4), developerInfo.entry)
            sqlModel.setData(sqlModel.index(0, 5), codeInfo.entry)
            sqlModel.setData(sqlModel.index(0, 6), infoInfo.entry)
            sqlModel.setData(sqlModel.index(0, 7), ownedInfo.entry)
            sqlModel.submitAll() // don't get why I have to do it
        }
        else {
            model.title = titleInfo.entry
            model.platform = platformInfo.entry
            model.publisher = publisherInfo.entry
            model.developer = developerInfo.entry
            model.code = codeInfo.entry
            model.info = infoInfo.entry
            dbManager.currentProxyModel.invalidate() // force to update model to reload covers
        }
    }

    function removeGame() {
        imageManager.removePics(platformName + "/" + currentTag)
        dbManager.currentProxyModel.removeRow(index)
        dbManager.currentSqlModel.select() // reload DB content to avoid displaying a blank item
    }

    function cancelGame() {
        for (var i = 0; i < dataColumn.children.length; i++) {
            dataColumn.children[i].reset()
        }
        gameCoverRow.frontCoverUrl =
            ("image://coverProvider/%1.front").arg(platformName + "/" + currentTag)
        gameCoverRow.backCoverUrl =
            ("image://coverProvider/%1.back").arg(platformName + "/" + currentTag)
    }

    function setGameAsOwned() {
        ownedCheckBox.checked = true
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

        frontCoverUrl:
            ("image://coverProvider/%1.front").arg(platformName + "/" + currentTag)
        backCoverUrl:
            ("image://coverProvider/%1.back").arg(platformName + "/" + currentTag)

        onEditCoverRequired:(img) => showSnapshotPopup(img)

        editMode: root.editMode
        enabled: root.isOwned
    }

    ColumnLayout {
        id: dataColumn

        width: parent.width - 20
        anchors.horizontalCenter:
            parent.horizontalCenter
        anchors.top: gameCoverRow.bottom
        anchors.topMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 75

        GameInfoListDelegate {
            id: tagInfo
            name: qsTr("Tag")
            entry: root.currentTag
            editable: false
            opacity: root.isOwned ? 1 : 0.4
            Layout.fillWidth: true
            Layout.preferredHeight: 40
        }
        GameInfoListDelegate {
            id: indexInfo
            name: qsTr("Index");
            entry: (index < 0) ? ""
                               : (index+1) + "/" + count
            editable: false
            opacity: root.isOwned ? 1 : 0.4
            Layout.fillWidth: true
            Layout.preferredHeight: 40
        }
        GameInfoListDelegate {
            id: codeInfo
            name: qsTr("Code")
            entry: model?.code ?? "";
            editable: editMode
            opacity: root.isOwned ? 1 : 0.4
            Layout.fillWidth: true
            Layout.preferredHeight: 40
        }
        GameInfoListDelegate {
            id: titleInfo
            name: qsTr("Title")
            entry: model?.title ?? "";
            editable: editMode
            opacity: root.isOwned ? 1 : 0.4
            Layout.fillWidth: true
            Layout.preferredHeight: 50
        }
        GameInfoListDelegate {
            id: platformInfo
            name: qsTr("Platform")
            entry: platformName
            editable: false
            opacity: root.isOwned ? 1 : 0.4
            Layout.fillWidth: true
            Layout.preferredHeight: 40
        }
        GameInfoListDelegate {
            id: infoInfo
            name: qsTr("info")
            entry: model?.info ?? ""
            editable: editMode
            opacity: root.isOwned ? 1 : 0.4
            Layout.fillWidth: true
            Layout.preferredHeight: 50
        }
        GameInfoListDelegate {
            id: publisherInfo
            name: qsTr("Publisher")
            entry: model?.publisher ?? ""
            editable: editMode
            opacity: root.isOwned ? 1 : 0.4
            Layout.fillWidth: true
            Layout.preferredHeight: 40
        }
        GameInfoListDelegate {
            id: developerInfo
            name: qsTr("Developer")
            entry: model?.developer ?? ""
            editable: editMode
            opacity: root.isOwned ? 1 : 0.4
            Layout.fillWidth: true
            Layout.preferredHeight: 40
        }        
        Item {
            id: ownedInfo
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            property alias entry: ownedCheckBox.checked
            function reset() {}

            enabled: (index >= 0)

            Label {
                id: labelName
                width: parent.width/3
                height: parent.height
                verticalAlignment:
                    Label.AlignVCenter
                font.family: "Roboto"
                font.pointSize: 14
                font.bold: true
                color: "white"
                text: qsTr("In my collection")
            }
            CheckBox {
                id: ownedCheckBox
                anchors.right: parent.right
                anchors.left: labelName.right
                anchors.verticalCenter:
                    labelName.verticalCenter
                checked: root.isOwned
                onClicked: model.owned = checked ? 1 : 0
            }
        }
    }
}


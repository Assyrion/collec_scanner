import QtQuick 6.3
import QtQuick.Layouts 6.3
import QtQuick.Controls 6.3

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
    property int _index: -1

    property bool isOwned : (_index < 0) || (model?.owned)
    property bool editMode: false

    property string currentTag: ""
    property string currentTitle: ""

    signal ownedClicked(bool owned)

    Component.onCompleted: {
        if(_index < 0 && currentTag === "") { // new game creation
            var rand = Math.random().toFixed(6)
            currentTag = Qt.binding(function() {
                var _in  = "notag_" + titleInfo.entry
                        + '_' + rand // very unlikely that 2 games have same tag
                _in = _in.replace(/\W/g,'')
                return _in
            })
        } else if(_index >= 0){
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

    function showPricesPopup() {
        var cpt = Qt.createComponent("PricesPopup.qml")
        if (cpt.status === Component.Ready) {
            cpt.createObject(root, { "tag" : currentTag,
                                 "width" : root.width * 0.8,
                                 "height": root.height * 0.5,
                                 "x"     : root.width * 0.1,
                                 "y"     : root.height * 0.2})
        }
    }

    // return source index from this index
    function getSourceIdx() {
        var proxyModel = dbManager.currentProxyModel
        var proxyIdx = proxyModel.index(_index, 0)
        return proxyModel.mapToSource(proxyIdx)
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

        var proxyModel = dbManager.currentProxyModel
        var sqlModel = dbManager.currentSqlModel
        var sourceIdx = getSourceIdx()

        // In case we're creating a new game
        if(_index < 0) {
            sqlModel.prepareInsertRow() // insert new row at the beginning
            sourceIdx = sqlModel.index(0, 0)
        } else {
            currentTitle = model.title // save old title
        }

        var dataList = [currentTag,
                        titleInfo.entry,
                        platformInfo.entry,
                        publisherInfo.entry,
                        developerInfo.entry,
                        codeInfo.entry,
                        infoInfo.entry,
                        ownedInfo.entry]

        sqlModel.updateData(sourceIdx, dataList)

        if(titleInfo.entry != currentTitle || currentTitle.length === 0) { // either the title has changed or it has been left empty
            if(proxyModel.groupVar) {
                proxyModel.rebuildTitleMap()
            }
        }
    }

    function removeGame() {
        imageManager.removePics(platformName + "/" + currentTag)

        var sourceIdx = getSourceIdx()

        var sqlModel = dbManager.currentSqlModel
        var proxyModel = dbManager.currentProxyModel

        proxyModel.removeRow(_index) // remove from proxyModel and database

        sqlModel.prepareRemoveRow(sourceIdx)
        sqlModel.select() // need to be done before reevaluating sugbgame values

        if(proxyModel.groupVar) {
            proxyModel.rebuildTitleMap() // reevaluating sugbgame values
        }
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
            Layout.preferredHeight: 25
        }
        GameInfoListDelegate {
            id: indexInfo
            name: qsTr("Index");
            entry: (_index < 0) ? ""
                               : (_index+1) + "/" + count
            editable: false
            opacity: root.isOwned ? 1 : 0.4
            Layout.fillWidth: true
            Layout.preferredHeight: 25
        }
        GameInfoListDelegate {
            id: platformInfo
            name: qsTr("Platform")
            entry: platformName
            editable: false
            opacity: root.isOwned ? 1 : 0.4
            Layout.fillWidth: true
            Layout.preferredHeight: 25
        }
        GameInfoListDelegate {
            id: codeInfo
            name: qsTr("Code")
            entry: model?.code ?? "";
            editable: editMode
            opacity: root.isOwned ? 1 : 0.4
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            onReset: entry = model.code
        }
        GameInfoListDelegate {
            id: titleInfo
            name: qsTr("Title")
            entry: model?.title ?? "";
            editable: editMode
            opacity: root.isOwned ? 1 : 0.4
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            onReset: entry = model.title
        }
        GameInfoListDelegate {
            id: publisherInfo
            name: qsTr("Publisher")
            entry: model?.publisher ?? ""
            editable: editMode
            opacity: root.isOwned ? 1 : 0.4
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            onReset: entry = model.publisher
        }
        GameInfoListDelegate {
            id: developerInfo
            name: qsTr("Developer")
            entry: model?.developer ?? ""
            editable: editMode
            opacity: root.isOwned ? 1 : 0.4
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            onReset: entry = model.developer
        }
        GameInfoListDelegate {
            id: infoInfo
            name: qsTr("info")
            entry: model?.info ?? ""
            editable: editMode
            opacity: root.isOwned ? 1 : 0.4
            Layout.fillWidth: true
            Layout.fillHeight: true
            onReset: entry = model.info
        }
        Item {
            id: ownedInfo
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            property alias entry: ownedCheckBox.checked

            signal reset

            enabled: (_index >= 0)

            Label {
                id: labelName
                width: parent.width/3
                height: parent.height
                verticalAlignment:
                    Label.AlignVCenter
                font.family: "Roboto"
                font.pointSize: 14
                font.bold: true
                color: "lightgray"
                text: qsTr("In my collection")
            }
            CheckBox {
                id: ownedCheckBox
                anchors.right: parent.right
                anchors.left: labelName.right
                anchors.verticalCenter:
                    labelName.verticalCenter
                checked: root.isOwned
                onClicked: {
                    model.owned = checked ? 1 : 0
                    root.ownedClicked(model.owned)
                }
            }
        }
    }

    Button {
        text: "€"
        visible: !currentTag.includes("notag")
        width: 50
        height: 50
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 62
        font.pixelSize: 20
        onClicked: {
            showPricesPopup()
        }
    }
}


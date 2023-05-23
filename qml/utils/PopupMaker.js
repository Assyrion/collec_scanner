function showConfirmDelete(parent) {
    var cpt = Qt.createComponent("CSActionPopup.qml")
    if (cpt.status === Component.Ready) {
        return cpt.createObject(parent, {"contentText" : qsTr("Are you sure ?"),
                                    "width" : 2*parent.width/3,
                                    "height": parent.height/4,
                                    "x"     : parent.width/6,
                                    "y"     : parent.height/4+20})
    }
    return null
}

function showGameNotOwned(parent) {
    var cpt = Qt.createComponent("CSActionPopup.qml")
    if (cpt.status === Component.Ready) {
        return cpt.createObject(parent, {"contentText" : qsTr("You don't own this game. Would you want to add it to your collection ?"),
                                    "width" : 2*parent.width/3,
                                    "height": parent.height/4,
                                    "x"     : parent.width/6,
                                    "y"     : parent.height/4+20})
    }
    return null
}

function showConfirmClearDB(parent) {
    var cpt = Qt.createComponent("CSActionPopup.qml")
    if (cpt.status === Component.Ready) {
        return cpt.createObject(parent, {"contentText" : qsTr("DB will be entirely cleared.\nThis action is irreversible."),
                                    "width" : 2*parent.width/3,
                                    "height": parent.height/4,
                                    "x"     : parent.width/6,
                                    "y"     : parent.height/4+50,
                                    "z"     : 1})
    }
    return null
}

function showConfirmSaveDB(parent) {
    var cpt = Qt.createComponent("CSActionPopup.qml")
    if (cpt.status === Component.Ready) {
        return cpt.createObject(parent, {"contentText" : qsTr("DB content will be written in <DownloadPath>/game_list.csv"),
                                    "width" : 2*parent.width/3,
                                    "height": parent.height/4,
                                    "x"     : parent.width/6,
                                    "y"     : parent.height/4+50,
                                    "z"     : 1})
    }
    return null
}

function showConfirmUploadDB(parent) {
    var cpt = Qt.createComponent("CSActionPopup.qml")
    if (cpt.status === Component.Ready) {
        return cpt.createObject(parent, {"contentText" : qsTr("DB will be uploaded to server."),
                                    "width" : 2*parent.width/3,
                                    "height": parent.height/4,
                                    "x"     : parent.width/6,
                                    "y"     : parent.height/4+50,
                                    "z"     : 1})
    }
    return null
}

function showConfirmUploadCovers(parent) {
    var cpt = Qt.createComponent("CSActionPopup.qml")
    if (cpt.status === Component.Ready) {
        return cpt.createObject(parent, {"contentText" : qsTr("New covers will be uploaded to server."),
                                    "width" : 2*parent.width/3,
                                    "height": parent.height/4,
                                    "x"     : parent.width/6,
                                    "y"     : parent.height/4+50,
                                    "z"     : 1})
    }
    return null
}

function showUnknownGame(parent, tag) {
    var cpt = Qt.createComponent("CSActionPopup.qml")
    if (cpt.status === Component.Ready) {
        return cpt.createObject(parent, {"contentText" : qsTr("Game with tag = %1 is new.<br><br>Add it ?").arg(tag),
                                    "width" : parent.width,
                                    "height": parent.height})
    }
    return null
}

function showFilteredGame(parent, tag) {
    var cpt = Qt.createComponent("CSActionPopup.qml")
    if (cpt.status === Component.Ready) {
        return cpt.createObject(parent, {"contentText" : qsTr("Game with tag = %1 exists but has been filtered.<br><br>Remove filter and show it ?").arg(tag),
                                    "width" : parent.width,
                                    "height": parent.height})
    }
    return null
}

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
                                    "y"     : parent.height/4+20,
                                    "z"     : 1})
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
        return cpt.createObject(parent, {"contentText" : qsTr("%1 DB content will be written in <DownloadPath>/game_list.csv").arg(platformName),
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
        return cpt.createObject(parent, {"contentText" : qsTr("%1 DB will be uploaded to server.").arg(platformName),
                                    "width" : 2*parent.width/3,
                                    "height": parent.height/4,
                                    "x"     : parent.width/6,
                                    "y"     : parent.height/4+50,
                                    "z"     : 1})
    }
    return null
}

function showConfirmReloadDB(parent) {
    var cpt = Qt.createComponent("CSActionPopup.qml")
    if (cpt.status === Component.Ready) {
        return cpt.createObject(parent, {"contentText" : qsTr("%1 DB will be replaced by the latest on the server.<br>Filters will be reinitialized.").arg(platformName),
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
        return cpt.createObject(parent, {"contentText" : qsTr("Game with tag = %1 is not in %2 database.<br><br>Add it ?").arg(tag).arg(platformName),
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

function showFilteredGame(parent, tag) {
    var cpt = Qt.createComponent("CSActionPopup.qml")
    if (cpt.status === Component.Ready) {
        return cpt.createObject(parent, {"contentText" : qsTr("Game with tag = %1 exists but has been filtered.<br><br>Remove filter and show it ?").arg(tag),
                                    "width" : parent.width,
                                    "height": parent.height})
    }
    return null
}

function showAllOwnedWarning(parent, owned) {
    var cpt = Qt.createComponent("CSActionPopup.qml")
    if (cpt.status === Component.Ready) {
        return cpt.createObject(parent, {"contentText" : qsTr("This action will set all %1 database games as %2 in your collection !").arg(platformName).arg(owned ? qsTr("owned") :  qsTr("not owned")),
                                    "width" : 2*parent.width/3,
                                    "height": parent.height/4,
                                    "x"     : parent.width/6,
                                    "y"     : parent.height/4+50})
    }
    return null
}

import QtQuick 6.3
import QtQuick.Layouts 6.3
import QtQuick.Controls 6.3

import "../utils/PopupMaker.js" as PopupMaker

Item {
    id: root

    property bool editMode: false
    property alias currentIndex: swipeView.currentIndex
    property alias currentItem:  swipeView.currentItem

    signal closed

    function showConfirmDelete() {
        var obj = PopupMaker.showConfirmDelete(root)
        obj.accepted.connect(function() {
            root.removeGame()
            closed()
        })
    }

    function saveGame() {
        root.editMode = false
        var savedTag = root.currentItem.currentTag // index may have changed after edition

        root.currentItem.saveGame()

        var idx = dbManager.currentProxyModel.getIndexFiltered(savedTag) // get the new index
        if(idx >= 0)
            root.currentIndex = idx
        else
            closed()
    }

    function removeGame() {
        root.currentItem.removeGame()
    }

    function cancelGame() {
        root.editMode = false
        root.currentItem.cancelGame()
    }

    ListView {
        id: swipeView

        anchors.fill: parent

        interactive: !editMode
        orientation: Qt.Vertical

        Component.onCompleted: {
            swipeView.model = dbManager.currentProxyModel // initial DB
        }

        // update model when pointing to new DB
        Connections {
            target: dbManager
            function onDatabaseChanged() {
                swipeView.model = dbManager.currentProxyModel
            }
        }

        highlightMoveDuration: 0
        snapMode : ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange

        delegate : GameSwipeDelegate {
            _index: Math.max(currentIndex, 0) // prevent accidental -1 index
            count: swipeView.count
            editMode: root.editMode
            height: root.height
            width: root.width
            onOwnedClicked: (owned) => {
                if(!owned) {
                    root.cancelGame()
                }
                var idx = dbManager.currentProxyModel.getIndexFiltered(currentTag) // get the new index
                if(idx < 0)
                    root.closed()
            }
        }
    }

    RowLayout {
        id: btnRow

        height: 50
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter:
            parent.horizontalCenter
        spacing: 12
        Button {
            text: root.editMode ? qsTr("cancel")
                           : qsTr("close")
            onClicked: {
                if(root.editMode) {
                    root.cancelGame()
                } else {
                    closed()
                }
            }
            leftPadding: 12
            rightPadding: 12

            font.pointSize: 11
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: btnRow.children.reduce(function(prev, curr) {
                    return curr.implicitWidth > prev ? curr.implicitWidth : prev;
                }, 80)
        }
        Button {
            text: root.editMode ? qsTr("save")
                           : qsTr("edit")
            onClicked: {
                if(root.editMode) {
                    root.saveGame()
                } else {
                    root.editMode = true
                }
            }
            leftPadding: 12
            rightPadding: 12

            font.pointSize: 11
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: root.currentItem?.isOwned ? btnRow.children.reduce(function(prev, curr) {
                return curr.implicitWidth > prev ? curr.implicitWidth : prev;
            }, 80) : 0
            Behavior on Layout.preferredWidth { NumberAnimation { duration: 150 } }

            visible: Layout.preferredWidth > 0
        }
        Button {
            text: qsTr("delete")
            onClicked: {
                root.editMode = false
                root.showConfirmDelete()
            }
            leftPadding: 12
            rightPadding: 12

            font.pointSize: 11
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: root.currentItem?.isOwned && !root.editMode ? btnRow.children.reduce(function(prev, curr) {
                    return curr.implicitWidth > prev ? curr.implicitWidth : prev;
            }, 80) : 0
            Behavior on Layout.preferredWidth { NumberAnimation { duration: 150 } }

            visible: Layout.preferredWidth > 0
        }
    }
}

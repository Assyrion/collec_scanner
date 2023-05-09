import QtQuick 6.2
import QtQuick.Layouts 6.2
import QtQuick.Controls 6.2

Item {
    id: root

    property bool editMode: false
    property alias currentIndex:
        swipeView.currentIndex

    signal closed

    function showConfirmDelete() {
        var cpt = Qt.createComponent("../utils/CSActionPopup.qml")
        if (cpt.status === Component.Ready) {
            var obj = cpt.createObject(root, {"contentText" : qsTr("Are you sure ?"),
                                 "width" : 2*root.width/3,
                                 "height": root.height/4,
                                 "x"     : root.width/6,
                                 "y"     : root.height/4+20})
            obj.accepted.connect(function() {
                swipeView.removeGame()
                closed()
            })
        }
    }

    SwipeView {
        id: swipeView

        anchors.fill: parent

        interactive: !editMode
        orientation: Qt.Vertical
        currentIndex: 0

        Component.onCompleted: {
            contentItem.highlightMoveDuration = 0
        }

        function saveGame() {
            var savedTag = currentItem.item.currentTag // index may have changed after edition
            currentItem.item.saveGame()
            var idx = sqlTableModel.getIndexFiltered(savedTag) // get the new index
            currentIndex = idx
        }

        function removeGame() {
            currentItem.item.removeGame()
        }

        function cancelGame() {
            currentItem.item.cancelGame()
        }

        Repeater {
            model: sqlTableModel
            Loader {
                active: SwipeView.isCurrentItem
                        || SwipeView.isNextItem
                        || SwipeView.isPreviousItem
                sourceComponent: GameSwipeDelegate {
                    index: swipeView.currentIndex
                    count: swipeView.count
                    editMode: root.editMode
                    height: root.height
                    width: root.width
                }
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
        spacing: 10
        Button {
            text: editMode ? qsTr("cancel")
                           : qsTr("close")
            onClicked: {
                if(editMode) {
                    editMode = false
                    swipeView.cancelGame()
                } else {
                    closed()
                }
            }
            font.pointSize: 12
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: btnRow.children.reduce(function(prev, curr) {
                    return curr.implicitWidth > prev ? curr.implicitWidth : prev;
                }, 80)
        }
        Button {
            text: editMode ? qsTr("save")
                           : qsTr("edit")
            onClicked: {
                if(editMode) {
                    editMode = false
                    swipeView.saveGame()
                } else {
                    editMode = true
                }
            }
            font.pointSize: 12
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: btnRow.children.reduce(function(prev, curr) {
                    return curr.implicitWidth > prev ? curr.implicitWidth : prev;
                }, 80)
        }
        Button {
            text: qsTr("delete")
            onClicked: {
                editMode = false
                showConfirmDelete()
            }
            font.pointSize: 12
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: btnRow.children.reduce(function(prev, curr) {
                    return curr.implicitWidth > prev ? curr.implicitWidth : prev;
                }, 80)
        }
    }
}

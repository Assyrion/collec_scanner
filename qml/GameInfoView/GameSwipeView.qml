import QtQuick 6.2
import QtQuick.Layouts 6.2
import QtQuick.Controls 6.2

Item {
    id: root

    property bool editMode: false
    property alias currentIndex:
        swipeView.currentIndex

    signal closed

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
            var savedIndex = currentIndex
            currentItem.item.saveGame()
            currentIndex = savedIndex
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
                    editMode: root.editMode
                    index: swipeView.currentIndex
                    height: root.height
                    width: root.width
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
            Layout.preferredWidth: 110
            Layout.alignment: Qt.AlignCenter
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
            Layout.preferredWidth: 110
            Layout.alignment: Qt.AlignCenter
        }
        Button {
            text: qsTr("delete")
            onClicked: {
//                showConfirmDelete()
            }
            Layout.preferredWidth: 110
            Layout.alignment: Qt.AlignCenter
        }
    }

}

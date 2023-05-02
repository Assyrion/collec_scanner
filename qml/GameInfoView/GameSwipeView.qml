import QtQuick 6.2
import QtQuick.Layouts 6.2
import QtQuick.Controls 6.2

Item {
    id: root

    property string currentTag: ""
    property bool editMode: false

    signal closed

    SwipeView {
        id: swipeView

        anchors.fill: parent

        interactive: !editMode
        orientation: Qt.Vertical
        currentIndex: 0

        function saveGame() {
            currentItem.item.saveGame()
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
                    currentTag: root.currentTag
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
//                    contentLoader.item.editMode = false
//                    contentLoader.item.cancelGame()
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
//                    contentLoader.item.saveGame()
//                    closed() // important to do it (maybe make a new feature just to avoid it)
                } else {
//                    contentLoader.item.editMode = true
                }
            }
            Layout.preferredWidth: 110
            Layout.alignment: Qt.AlignCenter
        }
        Button {
            text: qsTr("delete")
//            visible: currentGameIndex >= 0
            onClicked: {
//                showConfirmDelete()
            }
            Layout.preferredWidth: 110
            Layout.alignment: Qt.AlignCenter
        }
    }

}

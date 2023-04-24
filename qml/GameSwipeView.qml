import QtQuick 6.2
import QtQuick.Controls 6.2

import GameData 1.0

SwipeView {
    id: root

    property string currentTag: ""
    property bool editMode: false

    orientation: Qt.Vertical
    currentIndex: 0

    function saveGame() {
        currentItem.item.saveGame()
    }

    function removeGame() {
        currentItem.item.removeGame()
    }

    spacing : 5

    Repeater {
        model: sqlTableModel
        Loader {
            active: SwipeView.isCurrentItem
                    || SwipeView.isNextItem
                    || SwipeView.isPreviousItem
            sourceComponent: GameSwipeDelegate {
                currentTag: root.currentTag
                editMode: root.editMode
                index: currentIndex
                height: root.height
                width: root.width
            }
        }
    }
}

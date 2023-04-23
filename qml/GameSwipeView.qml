import QtQuick 6.2
import QtQuick.Controls 6.2

SwipeView {
    id: root

    property string currentTag: ""

    orientation: Qt.Vertical
    currentIndex: 0

    Repeater {
        model: sqlTableModel
        Loader {
            active: SwipeView.isCurrentItem
                    || SwipeView.isNextItem
                    || SwipeView.isPreviousItem
            sourceComponent: GameSwipeDelegate {
                currentTag: currentTag
//                index: currentIndex
                height: root.height
                width: root.width
            }
        }
    }
}

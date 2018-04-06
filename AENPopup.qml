import QtQuick 2.6
import QtQuick.Controls 2.2

Popup {
    id: popup

    signal accepted
    signal refused

    modal: true
    closePolicy: Popup.NoAutoClose

    background: Rectangle {
        border.color: "#444"
    }

    contentItem : Item {
        Text {
            anchors.centerIn: parent
            text: "New game detected... add it ?"
            font.pointSize: 20
            font.family: "calibri"
        }
        Button {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            text: "yep"
            onClicked: {
                accepted()
                popup.close()
            }
        }
        Button {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            text: "nope"
            onClicked: {
                refused()
                popup.close()
            }
        }
    }
}

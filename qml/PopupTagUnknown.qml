import QtQuick 2.6
import QtQuick.Controls 2.2

Popup {
    id: popup

    signal accepted(string tag)
    signal refused

    property string tag

    function show(tag) {
        popup.tag = tag
        open()
    }

    modal: true
    closePolicy: Popup.NoAutoClose

    background: Rectangle {
        border.color: "#444"
    }

    contentItem : Item {
        Text {
            width: parent.width
            anchors.centerIn: parent
            text: qsTr("Game with tag = %1 is new, add it ?").arg(popup.tag)
            wrapMode: Text.WordWrap
            font.pointSize: 20
            font.family: "calibri"
        }
        Button {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            text: "yep"
            onClicked: {
                accepted(popup.tag)
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

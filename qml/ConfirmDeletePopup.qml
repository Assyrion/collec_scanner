import QtQuick 6.2
import QtQuick.Controls 6.2
import Qt5Compat.GraphicalEffects
import "utils"

Popup {
    id: popup

    Component.onCompleted:  {
        open()
    }

    signal accepted
    signal refused

    topPadding: 1
    bottomPadding: 1
    leftPadding: 1
    rightPadding: 1

    dim: false
    modal: true
    closePolicy: Popup.NoAutoClose

    background: RectangularGlow {
        glowRadius: 10
        spread: 0
        color: "#222222"
        cornerRadius: 0
    }

    contentItem : Pane {
        Text {
            width: parent.width
            anchors.horizontalCenter:
                parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 30
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Are you sure ?")
            wrapMode: Text.WordWrap
            font.pointSize: 20
            font.family: "Roboto"
            color: "white"
        }
        Row {
            anchors.horizontalCenter:
                parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            spacing: 25
            Button {
                text: qsTr("yes")
                onClicked: {
                    accepted()
                    popup.close()
                }
            }
            Button {
                text: qsTr("no")
                onClicked: {
                    refused()
                    popup.close()
                }
            }
        }
    }
}

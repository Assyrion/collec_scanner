import QtQuick 6.2
import QtQuick.Controls 6.2
import Qt5Compat.GraphicalEffects
import "utils"

Popup {
    id: popup

    Component.onCompleted:  {
        open()
    }

    property alias contentText : messageText.text

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
        color: "#303030"
        cornerRadius: 0
    }

    contentItem : Pane {
        Text {
            id: messageText
            width: parent.width
            anchors.horizontalCenter:
                parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pointSize: 15
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
                text: qsTr("OK")
                onClicked: {
                    accepted()
                    popup.close()
                }
            }
            Button {
                text: qsTr("cancel")
                onClicked: {
                    refused()
                    popup.close()
                }
            }
        }
    }
}

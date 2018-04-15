import QtQuick 2.6
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import "utils"

Popup {
    id: popup

    Component.onCompleted:  {
        open()
    }

    signal accepted
    signal refused

    topPadding: 4
    bottomPadding: 4
    leftPadding: 1
    rightPadding: 1

    dim: false
    modal: true
    closePolicy: Popup.NoAutoClose

    background: DropShadow {}

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
            font.family: "calibri"
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

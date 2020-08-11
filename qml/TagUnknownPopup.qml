import QtQuick 2.6
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import "utils"

Popup {
    id: popup

    signal accepted(string tag)
    signal refused

    property string tag

    function show(tag) {
        popup.tag = tag
        open()
    }

    padding: 0
    modal: true
    closePolicy: Popup.NoAutoClose

    contentItem : Pane {
        Text {
            width: parent.width
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Game with tag = %1 is new.<br><br>Add it ?").arg(popup.tag)
            wrapMode: Text.WordWrap
            font.pointSize: 20
            font.family: "Roboto"
            color: "white"
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            spacing: 25
            Button {
                text: qsTr("yes")
                onClicked: {
                    accepted(popup.tag)
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

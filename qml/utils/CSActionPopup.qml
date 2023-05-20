import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 6.2
import Qt5Compat.GraphicalEffects

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
            anchors.verticalCenter:
                parent.verticalCenter
            anchors.verticalCenterOffset: -30
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pointSize: 15
            font.family: "Roboto"
            color: "white"
        }
        RowLayout {
            id: btnRow
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
                leftPadding: 12
                rightPadding: 12

                font.pointSize: 11
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: btnRow.children.reduce(function(prev, curr) {
                        return curr.implicitWidth > prev ? curr.implicitWidth : prev;
                    }, 80)
            }
            Button {
                text: qsTr("Cancel")
                onClicked: {
                    refused()
                    popup.close()
                }
                leftPadding: 12
                rightPadding: 12

                font.pointSize: 11
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: btnRow.children.reduce(function(prev, curr) {
                        return curr.implicitWidth > prev ? curr.implicitWidth : prev;
                    }, 80)
            }
        }
    }
}

import QtQuick 6.3
import QtQuick.Controls 6.3
import Qt5Compat.GraphicalEffects

import "../utils"

Item {
    id: root

    implicitHeight: bckgndRec.height + subgamesView.height

    signal subGameClicked(int idx)

    Rectangle {
        id: bckgndRec

        anchors.top: parent.top
        width: parent.width
        height: 80

        color: "transparent"
        border.color: "white"
        border.width: 1
        radius: 10

        MouseArea {
            anchors.fill: parent
            property bool checked: true

            onClicked: {
                subgamesView.state = checked ? "expanded" : "collapsed"
                checked = !checked
            }
        }
    }

    CSGlowText {
        id: titleText
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter:
            bckgndRec.verticalCenter
        anchors.right: platformText.left
        anchors.rightMargin: 10
        opacity: model?.owned ? 1 : 0.4
        font.pointSize:
            Math.min(17, parent.width/3 + 1)
        font.family: "Roboto"
        text: model?.title ?? ""
    }
    CSGlowText {
        id: platformText
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter:
            bckgndRec.verticalCenter
        opacity: model?.owned ? 1 : 0.4
        font.pointSize:
            Math.min(17, parent.width/3 + 1)
        font.family: "Roboto"
        text: subgamesView.count + " variantes - " + platformName
    }

    ListView {
        id: subgamesView
        width: parent.width
        anchors.top: bckgndRec.bottom
        anchors.topMargin: 5
        interactive: false
        state: "collapsed"
        spacing: 5
        model: codeProxyModel

        property var codeProxyModel
        Component.onCompleted: {
            codeProxyModel = dbManager.currentProxyModel.getCodeFilterProxyModel(code)
        }

        delegate: GameListDelegate {
            width:  root.width - anchors.leftMargin
            height: 50
            anchors.left: parent?.left
            anchors.leftMargin: 40
            onClicked: {
                var sourceIdx = subgamesView.codeProxyModel.mapIndexToSource(index)
                root.subGameClicked(sourceIdx)
            }
        }
        ScrollBar.vertical: ScrollBar {
            visible: false
        }

        transitions: Transition {
            NumberAnimation {
                properties: "height,opacity"
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        states: [
            State {
                name: "expanded"
                PropertyChanges { target: subgamesView; height: (count * (50 + subgamesView.spacing)); opacity: 1 }
            },
            State {
                name: "collapsed"
                PropertyChanges { target: subgamesView; height: 0; opacity: 0 }
            }
        ]
    }
}

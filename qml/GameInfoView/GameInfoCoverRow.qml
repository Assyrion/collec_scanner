import QtQuick 6.2
import QtQuick.Layouts 6.2

import "../utils"

RowLayout {
    id : root

    spacing: 20

    signal editCoverRequired(var img)

    property alias frontCoverUrl  : picFrontImg.imgUrl
    property alias frontCoverData : picFrontImg.imgData
    property alias backCoverUrl   : picBackImg.imgUrl
    property alias backCoverData  : picBackImg.imgData

    property MouseArea mouseArea

    property bool editMode : false

    readonly property int animationDuration : 200
    readonly property int maxShiftFactor : 90

    property int shiftFactor : 0
    Behavior on shiftFactor {
        NumberAnimation { duration : animationDuration }
    }

    states: [
        State {
            name: "frontCoverZoomed";
            PropertyChanges { target: picFrontImg; Layout.preferredHeight: root.height * 2 }
            PropertyChanges { target: root; shiftFactor: maxShiftFactor }
            PropertyChanges { target: mouseArea; enabled: true }
        },
        State {
            name: "backCoverZoomed";
            PropertyChanges { target: picBackImg; Layout.preferredHeight: root.height * 2 }
            PropertyChanges { target: root; shiftFactor: -maxShiftFactor }
            PropertyChanges { target: mouseArea; enabled: true }
        },
        State { // default state
            when: editMode || mouseArea.pressed
        }
    ]

    CSGlowImage {
        id : picFrontImg

        Layout.minimumHeight: parent.height
        Layout.preferredHeight: Layout.minimumHeight
        Layout.maximumHeight: parent.height * 2
        Layout.alignment : Qt.AlignRight | Qt.AlignTop

        imgUrl: "qrc:/no_pic" // default
        onClicked: {
            if(editMode) {
                editCoverRequired(this)
            } else if(root.state !== "frontCoverZoomed"){
                root.state = "frontCoverZoomed"
            } else {
                root.state = ""
            }
        }

        Behavior on Layout.preferredHeight {
            NumberAnimation { duration : animationDuration }
        }
    }
    CSGlowImage {
        id : picBackImg

        Layout.minimumHeight: parent.height
        Layout.preferredHeight: Layout.minimumHeight
        Layout.maximumHeight: parent.height * 2
        Layout.alignment : Qt.AlignLeft | Qt.AlignTop

        imgUrl: "qrc:/no_pic" // default
        onClicked: {
            if(editMode) {
                editCoverRequired(this)
            } else if(root.state !== "backCoverZoomed"){
                root.state = "backCoverZoomed"
            } else {
                root.state = ""
            }
        }

        Behavior on Layout.preferredHeight {
            NumberAnimation { duration : animationDuration }
        }
    }
}

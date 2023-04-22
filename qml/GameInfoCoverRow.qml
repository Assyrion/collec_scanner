import QtQuick 6.2
import QtQuick.Layouts 6.2
import "utils"

RowLayout {
    id : root

    spacing: 20

    signal editCoverRequired(var img)

    property alias frontCoverUrl  : picFrontImg.imgUrl
    property alias frontCoverData : picFrontImg.imgData
    property alias backCoverUrl   : picBackImg.imgUrl
    property alias backCoverData  : picBackImg.imgData

    property MouseArea mouseArea

    readonly property int animationDuration : 200
    readonly property int maxShiftFactor : 90

    property bool editMode : false
    property int shiftFactor : 0

    Behavior on shiftFactor {
        NumberAnimation { duration : animationDuration }
    }

    Component.onCompleted: {
        mouseArea.clicked.connect( function(mouse) {
            mouseArea.enabled = false
            picFrontImg.isZoomed = true
            picBackImg.isZoomed  = true
        })
    }

    CSGlowImage {
        id : picFrontImg
        property bool isZoomed : true

        Layout.minimumHeight: parent.height
        Layout.preferredHeight: Layout.minimumHeight
        Layout.maximumHeight: parent.height * 3
        Layout.alignment : Qt.AlignRight | Qt.AlignTop

        imgUrl: "qrc:/no_pic" // default
        onClicked: {
            if(editMode)
                editCoverRequired(this)
            else {
                isZoomed = !isZoomed
            }
        }
        onIsZoomedChanged : {
            if(isZoomed) {
                shiftFactor = 0

                Layout.preferredHeight = Layout.minimumHeight
            } else {
                shiftFactor = maxShiftFactor
                mouseArea.enabled = true

                Layout.preferredHeight = Layout.maximumHeight
            }
        }

        Behavior on Layout.preferredHeight {
            NumberAnimation { duration : animationDuration }
        }
    }
    CSGlowImage {
        id : picBackImg
        property bool isZoomed : true

        Layout.minimumHeight: parent.height
        Layout.preferredHeight: Layout.minimumHeight
        Layout.maximumHeight: parent.height * 3
        Layout.alignment : Qt.AlignLeft | Qt.AlignTop

        imgUrl: "qrc:/no_pic" // default
        onClicked: {
            if(editMode)
                editCoverRequired(this)
            else {
                isZoomed = !isZoomed
            }
        }
        onIsZoomedChanged : {
            if(isZoomed) {
                shiftFactor = 0

                Layout.preferredHeight = Layout.minimumHeight
            } else {
                shiftFactor = -maxShiftFactor
                mouseArea.enabled = true

                Layout.preferredHeight = Layout.maximumHeight
            }
        }

        Behavior on Layout.preferredHeight {
            NumberAnimation { duration : animationDuration }
        }
    }
}

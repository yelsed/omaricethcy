// Installed over /usr/share/sddm/themes/omarchy/Main.qml by the boot splash
// hook, which substitutes the background colour and the letter boundaries below.
// omarchy-plymouth-set writes Omarchy's stock version there on every sync, so
// this has to go on afterwards rather than replacing it once.
//
// Two differences from stock. The banner and the password box are anchored the
// way the boot splash anchors them — banner centred, box 40px under it — instead
// of centring the pair as a block, so the two screens land in the same place.
// And the banner types itself out, the way the lock screen does.

import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
  id: root
  width: 640
  height: 480
  color: "#181716"

  // The pixel column each letter of the banner ends at, from the theme's
  // unlock.widths. QML cannot read the theme directory at runtime, so the hook
  // bakes them in. Left empty, the banner is simply drawn whole.
  property var letterEnds: [/* UNLOCK_WIDTHS */]
  property int revealed: 0

  property string currentUser: userModel.lastUser
  property bool loginFailed: false
  property int sessionIndex: {
    for (var index = 0; index < sessionModel.rowCount(); index++) {
      var name = (sessionModel.data(sessionModel.index(index, 0), Qt.DisplayRole) || "").toString()
      if (name.indexOf("uwsm") !== -1)
        return index
    }
    return sessionModel.lastIndex
  }

  Connections {
    target: sddm
    function onLoginFailed() {
      root.loginFailed = true
      password.text = ""
      password.focus = true
    }
    function onLoginSucceeded() {
      root.loginFailed = false
    }
  }

  // 170ms is LOCK_DELAY in omaricethcy-banner, so this types at the rate the
  // lock screen types at.
  Timer {
    interval: 170
    repeat: true
    running: root.revealed < root.letterEnds.length
    onTriggered: root.revealed++
  }

  // Never drawn. It carries the banner's position and size, so the clipper below
  // can borrow both without its own width feeding back into them.
  Image {
    id: logo
    source: "logo.png"
    anchors.centerIn: parent
    visible: false
  }

  Item {
    x: logo.x
    y: logo.y
    height: logo.height
    clip: true
    width: root.letterEnds.length === 0
      ? logo.width
      : root.revealed > 0
        ? Math.min(root.letterEnds[root.revealed - 1], logo.width)
        : 0

    Image {
      source: "logo.png"
    }
  }

  Image {
    id: entry
    source: root.loginFailed ? "entry-failed.png" : "entry.png"
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: logo.bottom
    anchors.topMargin: 40

    Row {
      anchors.left: parent.left
      anchors.leftMargin: 20
      anchors.verticalCenter: parent.verticalCenter
      spacing: 5

      Repeater {
        model: Math.min(password.text.length, 21)

        Image {
          source: "bullet.png"
          width: 7
          height: 7
        }
      }
    }

    TextInput {
      id: password
      anchors.fill: parent
      anchors.leftMargin: 20
      anchors.rightMargin: 20
      verticalAlignment: TextInput.AlignVCenter
      echoMode: TextInput.Password
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 24
      font.letterSpacing: 5
      passwordCharacter: "•"
      color: "transparent"
      selectionColor: "transparent"
      selectedTextColor: "transparent"
      cursorDelegate: Item {}
      focus: true

      onTextChanged: root.loginFailed = false

      Keys.onPressed: {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          sddm.login(root.currentUser, password.text, root.sessionIndex)
          event.accepted = true
        }
      }
    }
  }

  Image {
    source: root.loginFailed ? "lock-failed.png" : "lock.png"
    width: 34
    height: 38
    fillMode: Image.PreserveAspectFit
    anchors.right: entry.left
    anchors.rightMargin: 15
    anchors.verticalCenter: entry.verticalCenter
  }

  Component.onCompleted: password.forceActiveFocus()
}

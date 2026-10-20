import QtQuick
import Quickshell.Io
import qs.Commons as Commons
import qs.Ui

// Whether the current Omarchy theme is dark or light, as omarchy-theme-color
// reads it (the mode omarchy-theme-set hands GTK), shown as Material Design's
// dark or light mode icon (brightness-4, brightness-7: night light's moon and
// the weather's sun are taken) drawn by BarSvgIcon in the bar's foreground
// colour. A click runs omarchy-theme-mode-toggle, which switches to the
// machine's theme of the other mode; the dotfiles provide it.
BarWidget {
  id: root
  moduleName: "josemiguelo.theme-mode"

  property string mode: ""
  readonly property string icon: mode === "" ? "" : mode === "light" ? "icons/brightness-7.svg" : "icons/brightness-4.svg"

  // A theme switch recolours the shell, so a new background is when the
  // mode is read again.
  readonly property color themeBackground: Commons.Color.background
  onThemeBackgroundChanged: modeProc.running = true
  Component.onCompleted: modeProc.running = true

  Process {
    id: modeProc
    command: ["omarchy-theme-color", "mode"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.mode = text.trim()
    }
  }

  visible: icon !== ""
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    hasVisualContent: root.icon !== ""
    labelVisible: false
    fixedWidth: root.vertical ? -1 : root.barSize
    fixedHeight: root.vertical ? root.barSize : -1
    tooltipText: root.mode === "light" ? "Light theme (click for dark)" : "Dark theme (click for light)"
    onPressed: function() {
      if (!root.bar) return
      root.bar.run("omarchy-theme-mode-toggle")
    }

    BarSvgIcon {
      anchors.centerIn: parent
      host: button
      source: root.icon
    }
  }
}

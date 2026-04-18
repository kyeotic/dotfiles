registerShortcut(
  'Toggle Panel Visibility',
  'Toggle Panel Visibility',
  'Meta+F8',
  function () {
    callDBus(
      'org.kde.plasmashell',
      '/PlasmaShell',
      'org.kde.PlasmaShell',
      'evaluateScript',
      "panels().forEach(panel => { panel.hiding = panel.hiding === 'none' ? 'autohide' : 'none'; })",
    )
  },
)

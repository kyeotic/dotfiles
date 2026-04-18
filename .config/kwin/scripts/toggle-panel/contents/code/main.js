registerShortcut("Toggle Panel Visibility", "Toggle Panel Visibility", "Meta+F8", function() {
    callDBus(
        "org.kde.plasmashell",
        "/PlasmaShell",
        "org.kde.PlasmaShell",
        "evaluateScript",
        "var allPanels = panels(); for (var i = 0; i < allPanels.length; i++) { var p = allPanels[i]; if (p.hiding === 'none') { p.hiding = 'dodgewindows'; } else { p.hiding = 'none'; } }"
    );
});

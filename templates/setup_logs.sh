#!/bin/bash
# Legt die Rollen-Tagebücher für den Kaizen-Prozessoptimierer an.
# Einmalig ausführen nach dem ersten `git submodule update --init`.

LOGS_DIR=".claude/artifacts/logs"
TEMPLATE=".claude/skills/templates/role_log.md.template"

mkdir -p "$LOGS_DIR"

declare -A ROLES=(
    ["pm_log.md"]="PM"
    ["requirements_log.md"]="Requirements Engineer"
    ["architect_log.md"]="Architekt"
    ["developer_log.md"]="Developer"
    ["unit_tester_log.md"]="Unit Tester"
    ["integration_tester_log.md"]="Integrationstester"
    ["system_tester_log.md"]="Systemtester"
    ["reviewer_log.md"]="Reviewer"
)

for FILE in "${!ROLES[@]}"; do
    TARGET="$LOGS_DIR/$FILE"
    if [ ! -f "$TARGET" ]; then
        sed "s/\[ROLLENNAME\]/${ROLES[$FILE]}/" "$TEMPLATE" > "$TARGET"
        echo "✅ $TARGET angelegt"
    else
        echo "⏭  $TARGET existiert bereits, übersprungen"
    fi
done

echo ""
echo "Log-Verzeichnis: $LOGS_DIR"
echo "Commit nicht vergessen: git add $LOGS_DIR && git commit -m 'chore: init kaizen role logs'"

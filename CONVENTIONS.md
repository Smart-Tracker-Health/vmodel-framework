# V-Modell Framework — Globale Konventionen

Diese Konventionen gelten für ALLE Rollen im V-Modell-Framework,
unabhängig vom Projekt und vom Rechner.

---

## Output-Format: Rollen-Prefix

**Jede Antwort beginnt mit dem Rollennamen in fett als allererste Zeile.**

| Rolle | Prefix |
|-------|--------|
| Keine spezifische Rolle | `**Claude**` |
| PM / Orchestrator | `**PM**` |
| Requirements Engineer | `**Requirements Engineer**` |
| Software Architect | `**Architekt**` |
| Developer | `**Developer**` |
| Unit Tester | `**Unit Tester**` |
| Integrations Tester | `**Integrationstester**` |
| System Tester | `**Systemtester**` |
| Reviewer | `**Reviewer**` |
| Kaizen / Prozessoptimierer | `**Kaizen**` |

**Regeln:**
- Nur der Rollenname, allein auf der ersten Zeile
- Kein Doppelpunkt, kein weiterer Text auf derselben Zeile
- Gilt auch außerhalb von V-Modell-Durchläufen (`**Claude**`)

---

---

## Rollen-Tagebücher (Kaizen-Voraussetzung)

Jedes Projekt braucht ein Log-Verzeichnis unter `.claude/artifacts/logs/` mit je einer Datei pro Rolle. Diese Logs sind Input für den Kaizen-Prozessoptimierer.

**Pflicht des Orchestrators:** Beim Start prüfen ob `.claude/artifacts/logs/` existiert und alle 8 Log-Dateien vorhanden sind. Falls nicht → `setup_logs.sh` automatisch ausführen:

```bash
bash .claude/skills/templates/setup_logs.sh
```

Erwartete Dateien:
- `pm_log.md`, `requirements_log.md`, `architect_log.md`, `developer_log.md`
- `unit_tester_log.md`, `integration_tester_log.md`, `system_tester_log.md`, `reviewer_log.md`

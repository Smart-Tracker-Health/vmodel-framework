# vmodel-framework

Ein wiederverwendbares V-Modell Workflow-Framework für Claude Code.

Definiert 9 spezialisierte Rollen als Skill-Dateien — technologie-agnostisch, projektübergreifend einsetzbar. Claude Code liest die Skill-Dateien und übernimmt die jeweilige Rolle vollständig, produziert Artefakte und wartet auf Freigabe bevor es zur nächsten Phase geht.

---

## Konzept

Jede Entwicklungsphase wird von einer dedizierten Rolle übernommen. Die Rollen kennen kein spezifisches Projekt — sie lesen den Projektkontext aus einer `project.md` die im jeweiligen Projekt liegt. Dadurch ist das Framework in beliebigen Projekten als Git Submodule einbindbar.

```
vmodel-framework/          ← dieses Repo (Submodule)
    CONVENTIONS.md         ← Globale Konventionen (Rollen-Prefix etc.)
    00_orchestrator.md
    01_requirements.md
    ...

mein-projekt/
    CLAUDE.md              ← Projektregeln
    .claude/
        project.md         ← Kontext-Bridge (Stack, DoD, Constraints)
        skills/            ← Submodule → vmodel-framework
        artifacts/         ← generiert während des Workflows
            logs/          ← Rollen-Tagebücher (für Kaizen)
```

---

## Workflow

```
SPEZIFIKATION                    VERIFIKATION
─────────────                    ────────────
01 Requirements Engineer    ←──► 06 System Tester
02 Software Architect       ←──► 05 Integrations Tester
03 Developer                ←──► 04 Unit Tester
         ↕
    07 Reviewer (nach jeder Phase)
    00 Orchestrator (steuert den gesamten Ablauf)
         ↓
    08 Kaizen (retrospektiv vor jedem Release)
```

Der Orchestrator verwaltet den Status in `.claude/artifacts/00_status.md` und stellt sicher, dass keine Phase übersprungen wird und alle Artefakte konsistent sind. Vor jedem Release triggert der Orchestrator automatisch den Kaizen-Prozessoptimierer.

---

## Rollen & Skill-Dateien

| Datei | Rolle | Prefix | Artefakt |
|-------|-------|--------|----------|
| `00_orchestrator.md` | PM & Workflow-Controller | `**PM**` | `00_status.md` |
| `01_requirements.md` | Requirements Engineer | `**Requirements Engineer**` | `requirements.md` |
| `02_architect.md` | Software Architect | `**Architekt**` | `architecture.md` |
| `03_developer.md` | Developer | `**Developer**` | Code + `implementation_notes.md` |
| `04_unit_tester.md` | Unit Tester | `**Unit Tester**` | `unit_test_report.md` |
| `05_integration_tester.md` | Integrations Tester | `**Integrationstester**` | `integration_test_report.md` |
| `06_system_tester.md` | System Tester | `**Systemtester**` | `system_test_report.md` |
| `07_reviewer.md` | Reviewer | `**Reviewer**` | `review_[phase].md` |
| `08_kaizen.md` | Kaizen / Prozessoptimierer | `**Kaizen**` | `logs/kaizen_report.md` |

Außerhalb aller Rollen: `**Claude**`

---

## Globale Konventionen

`CONVENTIONS.md` enthält projektagnostische Regeln die für alle Rollen gelten — insbesondere den Rollen-Prefix. Der Orchestrator lädt diese Datei bei der Initialisierung. Dadurch gelten die Konventionen auf jedem Rechner sobald das Submodule geladen ist, unabhängig von der projektspezifischen `CLAUDE.md`.

---

## Rollen-Tagebücher (Kaizen-Input)

Jede Rolle schreibt nach ihrem Einsatz einen kurzen Eintrag in ihr Tagebuch unter `.claude/artifacts/logs/`. Der Kaizen-Prozessoptimierer liest diese Logs vor jedem Release und destilliert daraus Verbesserungen:

- **Produkt-Findings** → bleiben im Projekt-Repo (projektspezifisch)
- **Prozess-Verbesserungen** → fließen als Änderungen in die Skill-Dateien zurück (projektagnostisch)

---

## Einbindung in ein Projekt

### 1. Submodule hinzufügen

```bash
cd mein-projekt
git submodule add https://github.com/[user]/vmodel-framework .claude/skills
git submodule update --init
```

### 2. Projektkontext anlegen

`project.md` wird **automatisch** angelegt: Beim ersten `@vmodel`-Aufruf startet der
Orchestrator einen Q&A-Dialog (6 Blöcke, ca. 5 Minuten) und schreibt das Ergebnis
direkt in `.claude/project.md`.

Alternativ manuell aus dem Template:

```bash
cp .claude/skills/templates/project.md.template .claude/project.md
```

Die `project.md` beschreibt:
- Tech Stack und Architektur-Prinzipien
- Coding Standards und Namenskonventionen
- Test-Framework
- Projektspezifische Constraints
- Definition of Done

### 3. CLAUDE.md anlegen

Template kopieren und ausfüllen:

```bash
cp .claude/skills/templates/CLAUDE.md.template CLAUDE.md
```

Die `CLAUDE.md` enthält:
- Stack und Build-Kommandos
- Projektstruktur und Code-Konventionen
- Projektspezifische Regeln (Stopp-Pflichten, Sicherheitsregeln)
- Den V-Modell Kommando-Block (bereits im Template enthalten)

### 4. Fertig

Beim ersten `@vmodel`-Aufruf erledigt der Orchestrator automatisch:
- Q&A-Dialog → `project.md` anlegen (falls nicht vorhanden)
- Log-Verzeichnis `.claude/artifacts/logs/` mit 8 Rollen-Tagebüchern anlegen

### 5. Submodule aktuell halten

```bash
# Framework-Updates in alle Projekte übernehmen
git submodule update --remote .claude/skills
git add .claude/skills
git commit -m "chore: update vmodel-framework"
```

---

## Nutzung

### Neues Feature starten

```
@vmodel CSV-Export
```

Der Orchestrator lädt `CONVENTIONS.md`, `project.md` und `CLAUDE.md`, legt `.claude/artifacts/00_status.md` an und startet Phase 01.

### Direkt in eine Phase einsteigen

```
@arch CSV-Export        # setzt vorhandenes requirements.md voraus
@dev                    # setzt requirements.md + architecture.md voraus
@review                 # reviewed das zuletzt produzierte Artefakt
@kaizen                 # Retrospektive vor Release
```

### Status prüfen

```
@vmodel status
```

Zeigt welche Phasen abgeschlossen sind und welche Artefakte vorliegen — ohne eine Aktion auszulösen.

---

## Kosten

Das Framework läuft ausschließlich über Claude Code mit Pro- oder Max-Abo — keine zusätzlichen API-Kosten. Alle Token-Ausgaben zählen zur Abo-Flatrate.

Einzige Ausnahme: Wenn eine `ANTHROPIC_API_KEY` Umgebungsvariable gesetzt ist, verwendet Claude Code automatisch den API-Key statt der Subscription. Vor dem ersten Start prüfen:

```bash
echo $ANTHROPIC_API_KEY   # sollte leer sein für Abo-Nutzung
```

---

## Struktur dieses Repos

```
vmodel-framework/
├── README.md
├── CONVENTIONS.md              ← Globale Konventionen (Rollen-Prefix etc.)
├── 00_orchestrator.md
├── 01_requirements.md
├── 02_architect.md
├── 03_developer.md
├── 04_unit_tester.md
├── 05_integration_tester.md
├── 06_system_tester.md
├── 07_reviewer.md
├── 08_kaizen.md
└── templates/
    ├── project.md.template     ← Vorlage für project.md (auch Onboarding-Basis)
    ├── CLAUDE.md.template      ← Vorlage für CLAUDE.md
    ├── role_log.md.template    ← Vorlage für Rollen-Tagebücher
    └── setup_logs.sh           ← Legt alle 8 Log-Dateien an (auto via Orchestrator)
```

---

## Wann den Workflow nutzen?

**Ja** — bei Features mit nicht-trivialer Architektur, Breaking Changes, oder wenn mehrere Schichten betroffen sind.

**Nein** — bei kleinen Bugfixes, einfachen UI-Anpassungen oder Konfigurationsänderungen. Dann direkt coden, kein Overhead.

Die Entscheidung liegt beim Entwickler. Der Orchestrator erzwingt nichts.

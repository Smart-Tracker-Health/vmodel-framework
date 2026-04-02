# vmodel-framework

Ein wiederverwendbares V-Modell Workflow-Framework für Claude Code.

Definiert 8 spezialisierte Rollen als Skill-Dateien — technologie-agnostisch, projektübergreifend einsetzbar. Claude Code liest die Skill-Dateien und übernimmt die jeweilige Rolle vollständig, produziert Artefakte und wartet auf Freigabe bevor es zur nächsten Phase geht.

---

## Konzept

Jede Entwicklungsphase wird von einer dedizierten Rolle übernommen. Die Rollen kennen kein spezifisches Projekt — sie lesen den Projektkontext aus einer `project.md` die im jeweiligen Projekt liegt. Dadurch ist das Framework in beliebigen Projekten als Git Submodule einbindbar.

```
vmodel-framework/          ← dieses Repo (Submodule)
    skills/
        00_orchestrator.md
        01_requirements.md
        ...

mein-projekt/
    CLAUDE.md              ← Projektregeln
    .claude/
        project.md         ← Kontext-Bridge (Stack, DoD, Constraints)
        skills/            ← Submodule → vmodel-framework/skills/
        artifacts/         ← generiert während des Workflows
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
    07 Reviewer (nach jeder Phase optional)
    00 Orchestrator (steuert den gesamten Ablauf)
```

Der Orchestrator verwaltet den Status in `.claude/artifacts/00_status.md` und stellt sicher, dass keine Phase übersprungen wird und alle Artefakte konsistent sind.

---

## Rollen & Skill-Dateien

| Datei | Rolle | Artefakt |
|-------|-------|----------|
| `00_orchestrator.md` | PM & Workflow-Controller | `00_status.md` |
| `01_requirements.md` | Requirements Engineer | `requirements.md` |
| `02_architect.md` | Software Architect | `architecture.md` |
| `03_developer.md` | Developer | Code + `implementation_notes.md` |
| `04_unit_tester.md` | Unit Tester | `unit_test_report.md` |
| `05_integration_tester.md` | Integrations Tester | `integration_test_report.md` |
| `06_system_tester.md` | System Tester | `system_test_report.md` |
| `07_reviewer.md` | Reviewer | `review_[phase].md` |

---

## Einbindung in ein Projekt

### 1. Submodule hinzufügen

```bash
cd mein-projekt
git submodule add https://github.com/[user]/vmodel-framework .claude/skills
git submodule update --init
```

### 2. Projektkontext anlegen

Template kopieren und ausfüllen:

```bash
cp .claude/skills/templates/project.md.template .claude/project.md
```

Die `project.md` beschreibt:
- Tech Stack und Architektur-Prinzipien
- Coding Standards und Namenskonventionen
- Test-Framework
- Projektspezifische Constraints
- Definition of Done

Etwa 15–30 Minuten einmalige Arbeit pro Projekt.

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

### 4. Submodule aktuell halten

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

Der Orchestrator liest `project.md` und `CLAUDE.md`, legt `.claude/artifacts/00_status.md` an und startet Phase 01.

### Direkt in eine Phase einsteigen

```
@arch CSV-Export        # setzt vorhandenes requirements.md voraus
@dev                    # setzt requirements.md + architecture.md voraus
@review                 # reviewed das zuletzt produzierte Artefakt
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
├── skills/
│   ├── 00_orchestrator.md
│   ├── 01_requirements.md
│   ├── 02_architect.md
│   ├── 03_developer.md
│   ├── 04_unit_tester.md
│   ├── 05_integration_tester.md
│   ├── 06_system_tester.md
│   └── 07_reviewer.md
└── templates/
    ├── project.md.template
    └── CLAUDE.md.template
```

---

## Wann den Workflow nutzen?

**Ja** — bei Features mit nicht-trivialer Architektur, Breaking Changes, oder wenn mehrere Schichten betroffen sind.

**Nein** — bei kleinen Bugfixes, einfachen UI-Anpassungen oder Konfigurationsänderungen. Dann direkt coden, kein Overhead.

Die Entscheidung liegt beim Entwickler. Der Orchestrator erzwingt nichts.

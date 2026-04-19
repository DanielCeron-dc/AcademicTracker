# AcademicTracker — Swift Prototype

Prototype of an academic management app written in **SwiftUI**. It lets a teacher
register students, evaluative activities and grades, and automatically calculates
performance, generates academic alerts and produces a course report.

---

## Requirements coverage

| Requirement                                       | Where it lives                        |
|---------------------------------------------------|---------------------------------------|
| Register students                                 | `StudentsView` + `addStudent`         |
| Register evaluative activities                    | `ActivitiesView` + `addActivity`      |
| Register grades                                   | `GradesView` + `recordGrade`          |
| Queries (per-student, per-activity)               | `weightedAverage(for:)`, `grade(...)` |
| Performance calculations                          | `weightedAverage`, `courseAverage`    |
| Identify low-performance cases                    | `lowPerformanceStudents`, `alerts`    |
| Basic academic alerts                             | `alerts` (3 severities)               |
| Course-level reports                              | `generateReport()` + `ReportsView`    |
| Organize course information                       | `CourseManager` as single source      |

---

## Architecture

**MVVM** with one observable object as the source of truth.

```
AcademicTracker/
├── AcademicTrackerApp.swift     ← @main entry, hosts CourseManager
├── Models.swift                 ← Student, Activity, Grade, ActivityType
├── CourseManager.swift          ← Logic: CRUD, averages, alerts, reports
└── Views/
    ├── StudentsView.swift       ← Tab 1
    ├── ActivitiesView.swift     ← Tab 2
    ├── GradesView.swift         ← Tab 3
    ├── ReportsView.swift        ← Tab 4
    └── AlertsView.swift         ← Tab 5
```

### Why this structure

- **Models are plain structs + Codable** → easy to persist later with
  `JSONEncoder` / `FileManager` or migrate to SwiftData/Core Data.
- **`CourseManager` is `@MainActor` + `ObservableObject`** → all UI updates are
  reactive; views just read derived state.
- **Views are stateless** with respect to data → they only render and trigger
  actions on the manager.

---

## Key calculations

### Weighted average (per student)

```
average = Σ ( normalized_score(activity) × weight(activity) ) / Σ weight(activity)
```

where `normalized_score = (raw_score / activity.maxScore) × 5.0`, so different
max scores can coexist on a single 0–5 scale. Missing grades count as 0 if the
student has at least one grade recorded.

### Alert rules

| Severity | Trigger                                                    |
|----------|------------------------------------------------------------|
| Critical | average < `passingThreshold` (3.0)                         |
| Critical | student has 0 grades and there are activities              |
| Warning  | `passingThreshold` ≤ average < `passingThreshold + 0.3`    |
| Info     | student is missing some (but not all) activity grades      |

Both `passingThreshold` and `borderlineMargin` are properties on
`CourseManager`, so they can be tuned at runtime or wired to a settings screen.

---

## How to run

1. Open Xcode 15 or later.
2. Create a new **iOS App** project (SwiftUI, Swift) named `AcademicTracker`.
3. Replace the generated files with the ones in this folder, keeping the same
   folder layout.
4. Run on iPhone simulator (iOS 17+).

The app boots with seeded sample data so you can immediately see grades,
reports and alerts without typing anything.

---

## Suggested next steps

- **Persistence**: replace in-memory arrays with SwiftData (`@Model`) or save
  Codable arrays to disk on every change.
- **Per-student detail view**: tap a student to see all their grades, the
  activities they're missing, and a small chart of their progress.
- **CSV export** of the report.
- **Multiple courses**: wrap `CourseManager` instances in a `CoursesStore`.
- **Settings tab** to expose `passingThreshold` and `borderlineMargin`.
- **Validation**: warn when activity weights don't sum to 100%.

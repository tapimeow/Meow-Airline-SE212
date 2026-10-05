# Team and ownership

| Member | Student ID | Main role | Owns (phase) | Reviews |
|---|---|---|---|---|
| Patarawadee Kunna | 682115034 | Database | Phase 2 lead (relational model, FDs, 3NF), Phase 3 (schema + seed), report §3–§6 | Kawintida's backend PRs (SQL matches schema) |
| Kawintida Kantong | 682115002 | Backend | Phase 4 (routes + controllers), queries Q1–Q9, report §2, §8 API | Patarawadee's schema PRs |
| Kornnaphat Uttama | 682115001 | Frontend | Phase 5 (views, CSS, reports pages), queries Q10–Q18, report §1 | — (reviewed by Patarawadee) |
| All | | | Phase 0, 1, 2 (EER), 6 (demo) | |

## Who owns which files

| Path | Owner | Comment tag in code |
|---|---|---|
| `db/schema.sql`, `db/seed.sql`, `config/db.js`, `.env.example`, `docs/DATABASE.md` | Patarawadee | `[Phase 3 · Database · Patarawadee]` |
| `routes/`, `controllers/`, `server.js` | Kawintida | `[Phase 4 · Backend · Kawintida]` |
| `views/`, `public/` | Kornnaphat | `[Phase 5 · Frontend · Kornnaphat]` |
| `db/queries.sql` | Kawintida (Q1–Q9), Kornnaphat (Q10–Q18) | `[Kawintida]` / `[Kornnaphat]` |
| `docs/ROUTES.md` | Kawintida + Kornnaphat | — |
| `README.md`, `RULES.md`, `docs/PHASES.md`, `docs/TEAM.md`, `docs/REPORT.md` | All | — |

Search the code for your name to find your TODOs:

```
grep -rn "Patarawadee" --include=*.js --include=*.sql --include=*.ejs .
```

## Learning plan (Lab 6 B4.2)

Nobody has used MySQL before, so all three members learn it in Phase 0 (Mon 5 – Tue 6 Oct).
Everyone already knows Node.js/Express, EJS/HTML/JS, GitHub and VS Code.

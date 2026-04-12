# OECD Semiconductor Watch

A curated Quarto website that monitors OECD semiconductor research and interprets it for India's policy community.

## Audience
- **Primary:** Indian policymakers, think tank researchers, academics working on semiconductor / tech geopolitics
- **Secondary:** General policy-curious public who follow India's tech strategy

## Editorial principle: India-first, always
Every report curated here must answer the question: **"What does this mean for India?"** Even OECD research on Mexico, the Dominican Republic, or EU subsidy regimes is worth curating if it illuminates a choice, a benchmark, or a warning for India's semiconductor ambitions.

## How content is organized

- **`posts/*.qmd`** — one file per OECD report. Each is a standalone markdown document with rich YAML frontmatter. This is the core content.
- **`data/datapoints.yml`** — quantitative cross-country data points extracted from reports. Powers the Compare Countries page. Update this when a report yields new cross-country data.
- **`data/countries.yml`** — country reference metadata (name, region, India flag).
- **`index.qmd`** — India-first homepage (hero, dashboard cards, recent reports, India-critical listing).
- **`reports.qmd`** — Quarto listing page (native, no code) showing all reports filterable by category and sortable.
- **`comparisons.qmd`** — Observable JS charts comparing countries across extracted metrics, with India always highlighted in saffron.
- **`about.qmd`** — Project purpose, methodology, editor note.

## Technical stack
- **Pure Quarto.** No R, no Python runtime required for the build.
- **Observable JS (OJS)** for cross-country charts, native to Quarto, runs in the browser.
- **Quarto listings** for the reports browse page (zero custom code).
- **GitHub Pages** for hosting, GitHub Actions for deployment.
- **Weekly monitoring** via `scripts/check_oecd.sh` + a scheduled workflow that opens a GitHub Issue when new OECD semiconductor publications are detected.

## Adding a new OECD report (~30 min curation workflow)

1. **Skim** the report (5 min). Set `india-relevance` honestly on a 1-5 scale.
2. **Create** `posts/YYYY-MM-oecd-slug.qmd` using the schema below (15 min).
3. **Extract cross-country data** into `data/datapoints.yml` if applicable (~5 min).
4. **Preview** with `quarto preview`.
5. **Commit and push.** GitHub Actions deploys automatically.

### Post frontmatter schema

```yaml
---
title: "Full OECD Report Title"
subtitle: "Optional subtitle"
date: 2024-11-15              # OECD publication date
date-curated: 2026-04-10      # When you added it
author: "Curated by Pranay Kotasthane"
categories: [flagship, subsidies, supply-chain, india-relevant]
oecd-url: "https://doi.org/..."
oecd-type: "Flagship Report"  # or Working Paper, Policy Brief, Country Review, Dataset
india-relevance: 5            # 1-5: how directly it matters for India
description: "One-sentence hook used in listing cards and search."
image: "img/thumbnail.png"    # Optional
---
```

### Post body template

Each post must have these sections in this order:

1. **India Focus callout** — 2-3 sentences distilling the India takeaway (use `::: {.callout-important}`)
2. **## Summary** — 3-4 sentence editorial summary
3. **## Key Insights** — 3-5 numbered findings with page references
4. **## What This Means for India** — the core value-add, 2-3 paragraphs
5. **## Data Extracted** — tables of quantitative findings (with India row highlighted via `{.india-highlight}` table class)
6. **## Source** — link to OECD source

## India highlighting conventions
- **Color:** `#FF9933` (saffron) for India, gray `#888` for other countries in charts
- **Tables:** Use `{.india-highlight}` class and mark the India row with `{.india-row}` in a custom Pandoc attribute (or simply place India first with bold)
- **Callouts:** Use `::: {.callout-important}` for India Focus sections (styled saffron-accent via styles.scss)
- **Missing India data is a story:** If a metric doesn't include India, add a `.india-absent` callout explaining why (e.g., "India does not yet have measurable capacity in this area").

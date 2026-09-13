# gabeyocum.com redesign — "Graph paper"

Date: 2026-09-12. Approved in chat.

## Goal

Replace the placeholder styling with a professional, math-forward design and
extend the site structure: home page sections, per-project pages, an About
page, build-time LaTeX, and a theme toggle. Audience is recruiters and readers
equally.

## Visual system

- Fonts: IBM Plex Sans (body, headings) and IBM Plex Mono (dates, labels,
  tags, code). Self-hosted woff2 in `static/fonts/`, preloaded, `font-display:
  swap`, system fallbacks.
- Palette as CSS variables on `:root`; dark values under
  `[data-theme=dark]` and, when no explicit choice, `prefers-color-scheme`.
  Light: off-white paper, faint 24px grid, near-black ink, one accent blue.
  Dark: deep navy paper, lighter grid, warm-white ink, lighter accent.
- Layout: single column, 44rem text measure, wider (64rem) container for
  project card grids. Section labels are numbered mono captions
  ("01 / Projects").
- Syntax highlighting via Hugo classes (`noClasses = false`) with a palette
  keyed to the theme variables.
- Subtle motion: link underline transitions, card hover lift. Respect
  `prefers-reduced-motion`.

## Structure

- Home (`layouts/index.html`): intro (name, tagline, contact links), Selected
  Projects (`featured: true`, up to 4, ordered by weight), Recent Writing
  (latest 5, link to `/posts/`).
- `/posts/`: list of all posts with date, title, description, reading time.
- `/projects/`: card grid from `content/projects/*.md`. Each card links to the
  project page; live URLs get a "Visit" link.
- `/projects/<slug>/`: title, status badge, stack, visit link, body writeup.
- `/about/`: bio and contact links.
- Nav: Writing, Projects, About. Header also holds the theme toggle.
- Footer: copyright, RSS, contact links.
- 404 page.
- Contact links defined once in `hugo.toml` `[params.social]`.

Project frontmatter:

```yaml
title, date, status (live|building|soon), link, stack (list), featured (bool),
weight (int), description
```

Existing `data/projects.yaml` is removed; its five entries migrate to markdown.

## Math

Goldmark passthrough extension enabled for `$...$`, `$$...$$`, `\(..\)`,
`\[..\]`. Render hook `layouts/_default/_markup/render-passthrough.html` calls
`transform.ToMath`. Pages set `math: true` in frontmatter to load the
self-hosted KaTeX stylesheet and fonts. No JavaScript.

## Theme toggle

Inline script in `<head>` applies `data-theme` from localStorage before first
paint. Button in header toggles and saves. No saved value means follow the OS.
The only JavaScript on the site.

## Extras

- Open Graph and Twitter meta on every page.
- SVG favicon.
- Skip-to-content link, focus styles, `aria` on the toggle.
- Print stylesheet basics.
- Reading time on posts.

## Out of scope

Tags, search, comments, analytics, project images.

## Testing

`hugo --gc --minify` builds clean locally with Hugo 0.152. Every page is
screenshotted in Chrome in light and dark at desktop and phone widths.

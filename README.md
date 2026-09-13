# gabeyocum.com

Hugo site. Markdown in, static HTML out. Served by Caddy on an Oracle Cloud
Ampere A1 instance.

```
content/posts/      blog posts (markdown)
content/projects/   one markdown file per project
content/about.md    the About page
layouts/            html templates and partials
static/css/main.css all styling lives here
static/fonts/       self-hosted IBM Plex Sans / Mono
static/vendor/katex KaTeX stylesheet and fonts (math is rendered at build time)
deploy/             server-side build pipeline
```

## Publishing a post

Add a markdown file to `content/posts/` and push. The server checks for new
commits every two minutes and rebuilds.

```markdown
---
title: "Post Title"
date: 2026-09-11
description: "One sentence, shown on the home page and in RSS."
draft: false
math: false
---

Body goes here.
```

Set `math: true` to load the KaTeX stylesheet. Then `$...$` is inline math and
`$$...$$` is display math, rendered to HTML when the site builds.

`draft: true` keeps it out of the build. Filename becomes the URL:
`content/posts/my-post.md` → `/posts/my-post/`

## For agents

Publishing requires no API, no auth beyond git, and no CMS. To publish:

1. Write a file at `content/posts/<slug>.md` with the frontmatter above
2. Commit and push to `main`

That's the entire contract. Rules worth following:

- `date` must be ISO format (`2026-09-11`) and not in the future, or the post
  won't render
- `description` is used verbatim in RSS and on the home page — one sentence
- Slugs are lowercase, hyphenated, no dates in the filename
- Set `draft: true` for anything that needs review before going live
- Never edit `public/` — it's generated and gitignored

## Adding a project

Add a markdown file at `content/projects/<slug>.md`:

```markdown
---
title: "Project Name"
date: 2026-09-11
description: "One or two sentences, shown on the card."
status: live          # live | building | soon
link: ""              # live URL, or empty for no link yet
stack: [React, Postgres]
featured: true        # show on the home page (top three by weight)
weight: 1             # sort order, lower first
---

Longer writeup goes here. Can be empty.
```

The card grid on `/projects/` and the home page reads these files. Nothing
else needs to change.

Contact links (email, GitHub, LinkedIn) live in `hugo.toml` under
`[params.social]` and are rendered on the home page, About page and footer.

## Local preview

```bash
hugo server -D
```

Open http://localhost:1313. `-D` includes drafts.

## Deploying

One-time, on the server:

```bash
mkdir -p ~/stacks/blog
cp deploy/docker-compose.yml deploy/build.sh ~/stacks/blog/
chmod +x ~/stacks/blog/build.sh
# edit REPO in docker-compose.yml
docker compose -f ~/stacks/blog/docker-compose.yml up -d
docker logs -f site-builder
```

Then point Caddy at the built output (see `deploy/Caddyfile`) and reload.

After that, deployment is `git push`.

## Why Hugo

A single Go binary with no runtime dependencies. Posts are plain text files
with no database behind them. If this sits untouched for four years it will
still build.

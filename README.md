# gabeyocum.com

Hugo site. Markdown in, static HTML out. Served by Caddy on an Oracle Cloud
Ampere A1 instance.

```
content/posts/      blog posts (markdown)
content/projects/   copy for the /projects page
data/projects.yaml  the project list itself
layouts/            html templates
static/css/main.css all styling lives here
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
---

Body goes here.
```

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

To add a project, append an entry to `data/projects.yaml`. No other file
changes.

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

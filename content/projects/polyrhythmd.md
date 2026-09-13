---
title: "polyrhythmd"
date: 2026-09-01
description: "Letterboxd, but for music. Rate and review albums, follow what your friends are listening to, and argue about it in public."
status: live
link: "https://polyrhythmd.gabeyocum.com"
stack: [React, Express, MongoDB, Spotify API, WebSockets]
featured: true
weight: 1
---

Album data comes from the Spotify API. Reviews, ratings and follows live in
MongoDB, and a WebSocket channel pushes new activity from people you follow
into your feed without a refresh.

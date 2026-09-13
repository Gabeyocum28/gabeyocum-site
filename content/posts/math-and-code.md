---
title: "Typesetting Math and Code on This Site"
date: 2026-09-12
description: "A short demo of LaTeX rendered at build time, plus syntax-highlighted code."
draft: true
math: true
---

Posts here can use LaTeX directly in markdown. Inline math like $e^{i\pi} + 1 = 0$
sits in the line, and display math gets its own block:

$$
\int_{-\infty}^{\infty} e^{-x^2}\,dx = \sqrt{\pi}
$$

Everything is rendered to HTML when the site builds, so there is no JavaScript
involved and nothing flashes on load. Here is a matrix, because why not:

$$
A = \begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix},
\qquad
\det A = -2
$$

## Code

Code blocks are highlighted at build time too.

```python
import numpy as np

def newton(f, df, x0, tol=1e-10, max_iter=50):
    x = x0
    for _ in range(max_iter):
        step = f(x) / df(x)
        x -= step
        if abs(step) < tol:
            return x
    raise RuntimeError("did not converge")

print(newton(lambda x: x**2 - 2, lambda x: 2*x, 1.0))
```

> Blockquotes look like this. Good for pulling out the one line that matters.

And a table, for completeness:

| Method    | Order | Cost per step |
|-----------|-------|---------------|
| Bisection | 1     | 1 eval        |
| Newton    | 2     | 2 evals       |
| Secant    | 1.618 | 1 eval        |

# {{NAME}}

{{DESCRIPTION}}

Vite + TypeScript (strict) + Tailwind CSS 4 (via `@tailwindcss/vite`; styles are utility classes, entry CSS is `src/style.css`).

## Commands

- `npm run dev` — dev server
- `npm run lint` / `npm run build` — must pass before finishing (`build` includes the typecheck)

## Conventions

- Client-exposed env vars must be prefixed `VITE_`; never put secrets in them.
- Prefer Tailwind utilities over custom CSS.

{{RULES}}

## This stack

- Everything in the bundle is public. Never ship secrets, private keys or internal URLs in client code or `VITE_` variables.
- Build DOM with `textContent` / `createElement`. Never assign untrusted data to `innerHTML`, `outerHTML` or `insertAdjacentHTML`; never use `eval` or `new Function`.
- Add a Content-Security-Policy at the host/CDN, and `rel="noopener noreferrer"` on external `target="_blank"` links.
- CI runs `npm audit` (high severity, dev dependencies included, since they produce the bundle) on every push and weekly, and installs with `npm ci`.
- Watch the `vite build` size output. Split routes with dynamic `import()`, lazy-load below-the-fold images (`loading="lazy"`, explicit width/height), and avoid large dependencies for small jobs.
- Avoid layout thrash: batch DOM reads and writes, and debounce scroll/resize handlers.
- Accessibility (WCAG 2.2 AA): use semantic elements (`button`, `nav`, `main`, ordered headings), label every input, give images meaningful `alt` text, keep focus visible and everything keyboard-operable, keep text contrast at 4.5:1 or better, and respect `prefers-reduced-motion`.

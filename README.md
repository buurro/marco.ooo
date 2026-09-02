# marco.ooo

Hugo site with a home-grown theme built on [retro-ui](https://github.com/buurro/ui):
the tokens and component CSS come from that repo, the layouts live here in
`layouts/`, and the blog-specific styling is `assets/css/site.css`.

## Building

```sh
nix build .#html      # → result/
nix develop           # hugo on PATH, assets/retro-ui linked
hugo server -D        # inside the dev shell
```

`assets/retro-ui` is gitignored: the flake copies the pinned retro-ui `src/`
there at build time, and the dev shell symlinks it. To work against a local
checkout instead:

```sh
ln -sfn ../../ui/src assets/retro-ui
```

Bump the pinned revision with `nix flake update retro-ui`.

## Theme layout

- `layouts/_default/baseof.html` – skip link, top bar, main, footer
- `layouts/index.html` – profile home (avatar, name, headline, links from `params.author`)
- `layouts/_default/list.html` – post list as tactile cards, paginated
- `layouts/_default/single.html` – article with breadcrumbs, meta row, older/newer cards
- `layouts/partials/head.html` – concatenates the retro-ui CSS files it needs plus
  `site.css` and `chroma.css` into one fingerprinted bundle
- `layouts/shortcodes/lead.html` – `{{< lead >}}` intro paragraph

Per-article options (`showDate`, `showAuthor`, `showReadingTime`,
`showDraftLabel`, `showBreadcrumbs`, `showHeadingAnchors`, `showPagination`,
`invertPagination`) default from `config/_default/params.toml` and can be
overridden in front matter or a section's `cascade`.

Dark mode keys off `data-theme` on `<html>`, persisted in `localStorage`
under `darkMode`, same as retro-ui's `useDarkMode` hook.

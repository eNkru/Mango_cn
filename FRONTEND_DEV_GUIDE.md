# 🎨 Frontend Development Guide

## 📁 Key Folders for UI Work

| Folder | Purpose |
|---|---|
| **`src/views/`** | HTML page templates (ECR — Crystal's templating language, like ERB) |
| `src/views/components/` | Reusable template partials (head, card, modal, etc.) |
| **`public/css/`** | Stylesheets written in **LESS** |
| **`public/js/`** | Client-side JavaScript (vanilla, no framework) |

## 🛠 Technical Stack

| Layer | Technology |
|---|---|
| **Templating** | **ECR** (Embedded Crystal) — `<%= %>` tags, similar to ERB |
| **CSS Framework** | **UIkit 3.5.9** — layout, nav, cards, modals, etc. |
| **CSS Preprocessor** | **LESS** — compiled via Gulp |
| **JS Libraries** | **jQuery** + jQuery UI, **Alpine.js** (lightweight reactivity), Moment.js, Select2 |
| **Icons** | **FontAwesome 5** (solid icons only) |
| **Build Tool** | **Gulp** — compiles LESS, transpiles/minifies JS via Babel |

## 🚀 Quick Start for UI Changes

1. **Run `npm run uglify` (or `gulp dev`)** to compile LESS → CSS and copy assets to `public/`.
2. **To change a page's layout/structure** → edit the `.html.ecr` file in `src/views/` (e.g., `home.html.ecr`, `library.html.ecr`, `title.html.ecr`).
3. **To change styling** → edit `.less` files in `public/css/` (main one is `mango.less`), then recompile.
4. **To change interactivity** → edit `.js` files in `public/js/` (e.g., `common.js`, `reader.js`, `title.js`).

The layout wrapper for all pages is **`src/views/layout.html.ecr`** (navbar, theme toggle, etc.), so global changes go there.

---

## 📂 Detailed File Reference

### Views (`src/views/`)

| File | Description |
|---|---|
| `layout.html.ecr` | Master layout — navbar, theme toggle, common head tags |
| `home.html.ecr` | Home page |
| `library.html.ecr` | Library browse page |
| `title.html.ecr` | Single title detail page |
| `reader.html.ecr` | Manga reader page |
| `login.html.ecr` | Login page |
| `admin.html.ecr` | Admin panel |
| `tag.html.ecr` | Tag browse page |
| `tags.html.ecr` | Tags list page |
| `user.html.ecr` | User profile page |
| `user-edit.html.ecr` | User edit page |
| `api.html.ecr` | API docs page |
| `message.html.ecr` | Generic message page |
| `missing-items.html.ecr` | Missing items page |
| `plugin-download.html.ecr` | Plugin download page |
| `download-manager.html.ecr` | Download manager page |
| `subscription-manager.html.ecr` | Subscription manager page |
| `reader-error.html.ecr` | Reader error page |

### View Components (`src/views/components/`)

| File | Description |
|---|---|
| `head.html.ecr` | Common `<head>` content |
| `card.html.ecr` | Reusable card component |
| `dots.html.ecr` | Loading dots indicator |
| `entry-modal.html.ecr` | Entry detail modal |
| `sort-form.html.ecr` | Sort/filter form |
| `uikit.html.ecr` | UIkit CSS/JS includes |
| `jquery-ui.html.ecr` | jQuery UI includes |
| `moment.html.ecr` | Moment.js includes |

### OPDS Views (`src/views/opds/`)

| File | Description |
|---|---|
| `index.xml.ecr` | OPDS catalog feed |
| `title.xml.ecr` | OPDS title entry |

### Stylesheets (`public/css/`)

| File | Description |
|---|---|
| `mango.less` | Main stylesheet — global styles, layout, components |
| `tags.less` | Tag-specific styles |
| `uikit.less` | UIkit customization/overrides |

### JavaScript (`public/js/`)

| File | Description |
|---|---|
| `common.js` | Shared utilities and common logic |
| `reader.js` | Manga reader functionality |
| `title.js` | Title detail page logic |
| `search.js` | Search functionality |
| `sort-items.js` | Sorting items logic |
| `dots.js` | Loading dots indicator |
| `dotdotdot.js` | Text truncation (dotdotdot plugin) |
| `admin.js` | Admin panel logic |
| `user.js` | User page logic |
| `user-edit.js` | User edit page logic |
| `alert.js` | Alert/notification system |
| `subscription.js` | Subscription logic |
| `subscription-manager.js` | Subscription manager page logic |
| `plugin-download.js` | Plugin download logic |
| `download-manager.js` | Download manager page logic |
| `missing-items.js` | Missing items page logic |

---

## ⚙️ Build System (Gulp)

The build pipeline is defined in `gulpfile.js`:

- **LESS compilation** — `.less` files are compiled to CSS and placed in `public/css/`
- **JS transpilation** — ES6+ JS is transpiled via Babel and minified
- **Asset copying** — fonts, images, and vendor assets are copied to `public/`

### Key NPM Scripts

| Command | Description |
|---|---|
| `npm run uglify` | Compile LESS and minify JS |
| `gulp dev` | Watch mode — recompile on file changes |
| `gulp` | Default build task |

---

## 🧩 ECR Templating Cheat Sheet

ECR (Embedded Crystal) is Crystal's built-in templating, similar to ERB in Ruby:

```erb
<%# Comment (not rendered) %>
<%= some_variable %>          <!-- Output (HTML-escaped) -->
<%= raw some_html %>          <!-- Output (unescaped HTML) -->
<% if condition %>            <!-- Control flow -->
<% end %>
<% items.each do |item| %>   <!-- Iteration -->
<% end %>
```

---

## 💡 Tips

- **Hot reload**: Run `gulp dev` in a separate terminal while developing to auto-recompile on changes.
- **UIkit docs**: Reference [getuikit.com/docs](https://getuikit.com/docs/) for available components and classes.
- **Alpine.js**: Used for lightweight reactivity (x-data, x-show, x-bind, etc.). See [alpinejs.dev](https://alpinejs.dev/).
- **LESS variables**: Check `mango.less` for theme variables (colors, spacing, etc.) before overriding UIkit defaults.

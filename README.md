# ✍️ Docloud Content Source

This is the **Source of Truth** for all Docloud Framework documentation, blogs, and API references.

**Note:** You do not need to worry about website code here. Simply push your Markdown files, and the automated pipeline will handle the rest.

## 🚀 The Publishing Workflow

Everything you push here is automatically synced and deployed to **[dev.docloud.lk](https://dev.docloud.lk)**.

1. **Edit:** Create or modify `.md` files in your preferred editor (Obsidian, VS Code, etc.).
2. **Commit:** Save your changes with a clear commit message.
3. **Push:** Push to the `main` branch.
4. **Live:** Within 60-90 seconds, your changes will be live on the website.

---

## 📂 Folder Structure

Please ensure your files are placed in the correct directories to maintain the site structure:

- **/docs**: Technical guides, installation manuals, and "how-to" documentation.
- **/blog**: News, framework updates, and announcements.
  - _Filename format: `YYYY-MM-DD-title.md` (e.g., `2026-04-27-new-features.md`)_
- **/api**: Technical API references and function documentation.

---

## 📝 Writing Guidelines

### Front Matter

Every file must start with a "Front Matter" block so the website knows how to display it:

**For Docs:**

```markdown
---
title: My Page Title
sidebar_label: Short Title
---
```

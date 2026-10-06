---
slug: docs-for-framework-0-0-42
title: The docs now cover DoFramework 0.0.42
authors: nipun
tags: [update, docs]
---

We've rewritten this site against DoFramework 0.0.42. Every page was checked against the framework's code, so the examples match what the framework does today. There is also a new section on building apps from scratch.

{/* truncate */}

## What's new in the docs

- **Building Apps.** A new section that follows an app from start to finish:
  - [Dev Workspace](/docs/framework/Building%20Apps/Dev%20Workspace): develop an app from one `dev/<app>/` folder.
  - [App Manifest](/docs/framework/Building%20Apps/App%20Manifest) and [App Frontend Config](/docs/framework/Building%20Apps/App%20Frontend%20Config): every element and field.
  - [Dashboard Widgets](/docs/framework/Building%20Apps/Dashboard%20Widgets) and [Admin Pages](/docs/framework/Building%20Apps/Admin%20Pages).
  - [Packaging And Updates](/docs/framework/Building%20Apps/Packaging%20And%20Updates): export, install and update an app.
- **[Architecture](/docs/framework/Architecture)** explains how a request travels through the framework. **[Frontend Runtime (XP)](/docs/framework/Frontend%20Runtime%20(XP))** is a full reference for the `XP` object.
- **[Roles And Permissions](/docs/framework/Essentials/Roles%20And%20Permissions)** covers the current permission model: roles declared in the manifest, users with several roles, permission changes that reach logged-in users without a new login, and scoped grants.
- **[Configuration Files](/docs/framework/Essentials/Configuration%20Files)** explains which file each setting lives in: `config.xml`, the per-environment overlay, `xp-config.json` and the `.dist` templates.
- **[Scheduler (Heartbeat)](/docs/framework/Essentials/Scheduler%20(Heartbeat))** shows how an app schedules its own background tasks with a `DoScheduler` class.
- **[Vue DC UI KIT](/docs/framework/Vue%20DC%20UI%20KIT/)** documents all 68 components in the kit, grouped by purpose.
- The **[Todo App](/docs/framework/Todo%20App)** tutorial is rewritten for the dev workspace and the current app layout.

## Framework changes since the last docs update

The previous docs were written for the 2024 releases. The changes developers will notice most since then:

- **One workspace per app.** In development mode the framework links `dev/<app>/` into the app folders on every request. Each app can be its own git repository.
- **Roles and permissions.** Apps can declare roles and their default grants in the manifest. Users can hold several roles. Permission changes reach logged-in users on their next request, and grants can be limited to part of an app's data.
- **Config templates.** `api/config.xml` and both `xp-config.json` files are now gitignored live copies of tracked `.dist` templates. Release-owned values are reset from the template.
- **A real dashboard.** Apps add widgets to the home page from `app-config.json`.
- **A growing UI kit.** It now includes page headers, tree navigation, activity and comment feeds, date ranges, media viewers and the dashboard components.
- **An admin activity log.** Every change made in the admin panel is recorded and can be browsed under Logs.
- **Safer updates.** Framework and app updates now carry new manifest content onto the system. A framework update restores the system status it found.
- **PHP 8.1 or later** is now required.

See [Get Started](/docs/framework/Get%20Started) for the current requirements and install steps.

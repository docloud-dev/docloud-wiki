---
slug: /
title: DoFramework Docs
sidebar_label: Home
sidebar_position: 1
---

# DoFramework Docs

These docs cover **DoFramework 0.0.44**. See [what changed in this update](/blog/docs-for-framework-0-0-44).

# Introduction

DoFramework is a PHP and Vue 3 framework for building business web apps. It's the framework behind DoCloud: you download it from [DoCloud](./framework/Docloud.md), install it on your own server, and publish your apps to the DoCloud App Library so other systems can install them.

You build features as **apps**. An app is a self-contained unit with its own routes, API endpoints, database tables, permissions and menu entries. The framework provides everything around it:

- **Routing and the API.** Each request reaches your app's controller, and every endpoint answers in the same JSON format.
- **Users, sessions, roles and permissions.** Every API action is checked against the permissions your app declares.
- **Database access** to MySQL or MariaDB through the core `database` class.
- **An admin panel** for installing apps, managing users and roles, settings and logs.
- **A frontend runtime** that loads each app's Vue components with no build step, and a UI kit of ready-made components.
- **Background tasks, email, notifications, logging** and other shared services.
- **Packaging.** An app moves between systems as a zip, and installs and updates from the admin panel.

---

# Requirements

- **Web server:** Apache 2.4, OpenLiteSpeed 1.7.x or later, or LiteSpeed Web Server (LSWS) 6.0 or later, with `.htaccess` support and `mod_rewrite`.
- **HTTPS,** on a domain or subdomain of its own, with the framework at the web root.
- **PHP 8.1 or above,** with a memory limit of 128 MB or above.

[Get Started](./framework/Get%20Started.md) has the full list, including the PHP extensions, and the install steps.

---

# Where to start

| If you want to… | Read |
| --- | --- |
| Install the framework | [Get Started](./framework/Get%20Started.md) |
| Understand how a request works | [Architecture](./framework/Architecture.md) |
| Build your first app, step by step | [Todo App](./framework/Todo%20App.md) |
| Look up an app's files and how it ships | [Building Apps](./framework/Building%20Apps/Building%20Apps.md) |
| Use authentication, roles, email, logging and the other built-in services | [Essentials](./framework/Essentials/Essentials.md) and [Modules](./framework/Modules/Modules.md) |
| Build the frontend | [Frontend Runtime (XP)](./framework/Frontend%20Runtime%20(XP).md) and [Vue DC UI KIT](./framework/Vue%20DC%20UI%20KIT/Vue%20DC%20UI%20KIT.md) |
| Run a system | [Admin Panel](./framework/Admin%20Panel.md) |
| Update a system to a newer framework release | [Upgrading The Framework](./framework/Upgrading%20The%20Framework.md) |
| Learn how the work is done, from first commit to release | [Developer Workflow](./Developer%20Workflow/Developer%20Workflow.md) |

---

# News and contributing

Framework releases and docs updates are announced on the [Dev Blog](/blog).

Found a mistake on a page? These docs are Markdown in a git repository. [Contributing To The Docs](./Developer%20Workflow/Contributing%20To%20The%20Docs.md) explains how to change a page and publish it.

---

---
title: Building Apps
sidebar_label: Building Apps
---

# Building Apps

# Introduction

In DoFramework you build features as **apps**. An app is a self-contained unit with its own routes, API endpoints, database tables, permissions and menu entries. The framework provides routing, authentication, sessions, database access, logging and the admin panel, so an app only implements its own logic.

An app has up to three parts. In production each one sits in its own framework folder:

| Part | Folder | What it holds |
| --- | --- | --- |
| Backend | `api/apps/<app>/` | The controller, business logic, DAO, model and the XML manifest `<app>.xml` |
| Frontend | `apps/<app>/` | `app-config.json`, `route.js`, `services.js`, Vue components and assets |
| Admin pages (optional) | `api/admin/apps/<app>/` | Pages for the admin panel |

While you develop, all three live in one folder, `dev/<app>/`, which the framework links into those locations. The built-in `helloworld` app is a complete example of every file.

The folder name, the class name prefixes and `<app_name>` in the manifest must all be the same app name.

These pages cover building an app, roughly in the order you need them. For a hands-on walk-through, start with the [Todo App](../Todo%20App.md) tutorial.

---

## Dev Workspace

Dev Workspace explains how to develop an app from a single `dev/<app>/` folder, with `frontend/`, `backend/` and `adminpanel/` inside, which can be its own git repository. With `system_environment` set to `development`, the framework links that folder into `apps/`, `api/apps/` and `api/admin/apps/` on every request. The page also covers checking and repairing the links, and running controllers from the command line.

---

## App Manifest

App Manifest is the reference for an app's XML manifest, `api/apps/<app>/<app>.xml`. This is the backend contract: the app's identity and version, which apps may call it, its user and admin permissions, roles, notifications, options, tables, autoloading and dependencies. For each element it says what reads it and when a change takes effect.

---

## App Frontend Config

App Frontend Config is the reference for `apps/<app>/app-config.json`. It declares the app's scripts and styles, sidebar and megabar menu entries and their permissions, dashboard widgets, and which fields reach the browser through `_public`.

---

## Dashboard Widgets

Dashboard Widgets shows how an app adds widgets to the framework dashboard. It covers declaring them in `app-config.json`, the `aside`, `main` and `full` regions, hiding and showing widgets per app or per installation, writing a widget component with `DcDashboardWidget`, and theming the dashboard with CSS variables.

---

## Admin Pages

Admin Pages explains how to add pages for an app to the admin panel. It covers the admin app's folder layout, menu entries gated by `<admin_panel_permissions>`, calling the app's own controllers, the admin UI kit, and how the admin panel records an activity log of state-changing requests.

---

## Packaging And Updates

Packaging And Updates covers getting an app onto other systems: exporting it from the admin panel, installing it from an export, a repository zip or the DoCloud App Library, and how an update merges the new manifest with the installed one. It also covers version fields, reinitializing and removing an app.

---

---
title: Developer Workflow
sidebar_label: Developer Workflow
---

# Developer Workflow

# Introduction

The Framework pages explain what DoFramework does. These pages explain how the work gets done, from the first commit to a release. Each one covers one kind of work:

| You are… | Read |
| --- | --- |
| Building an app on DoFramework | [App Development](./App%20Development.md) |
| Changing the framework itself | [Framework Development](./Framework%20Development.md) |
| Writing or fixing these docs | [Contributing To The Docs](./Contributing%20To%20The%20Docs.md) |

All three follow the same habits: each thing you ship has its own repository, every commit is one small change with a subject that says what changed, and nothing reaches users until it has been checked on a development copy.

---

## App Development

App Development covers an app's whole life: setting up a development install, creating the app in its own repository under `dev/`, the edit, reload and reinitialize loop, testing, versioning, and shipping the app as a zip or through the DoCloud App Library. It links to the Building Apps pages for the details of each step.

---

## Framework Development

Framework Development is for people who work on the framework repository. It covers branches, commit messages, the files that must never be committed, the config templates, running the tests, writing the changelog and cutting a release with `./bump-version`.

---

## Contributing To The Docs

Contributing To The Docs explains how this site is built and published. Pages are Markdown in the `docloud-wiki` repository. You edit them on the `dev` branch, preview them locally with `./preview.sh`, and merge to `main` to publish. The page also lists the page conventions and the MDX mistakes that break the site build.

---

---
title: Modules
sidebar_label: Modules
---

# Modules

Owner: Nuwan Danushka

# Introduction

Modules are the framework's reusable backend toolkits. They live in `api/core/Modules/`, are listed under `<modules>` in `api/config.xml`, and are loaded automatically: call them from any controller or class without a `require`. The boot health check refuses to start the system if a listed module is missing (see [Configuration Files](../Essentials/Configuration%20Files.md)).

---

## App Manager

App Manager is how an app works with the framework: table helpers that prefix table names with the app's name, schema install and reinitialization from `<createTables>` or from [migrations](../Building%20Apps/Database%20Migrations.md), calls into other apps with `CreateAppInstance`, autoloading and the app boot order. It also covers the lower-level schema functions and editing an app's manifest from code.

---

## Curl

Curl wraps PHP's cURL for calling web services. It sends GET, POST, PUT and DELETE requests, posts form, JSON or URL-encoded bodies, sets headers and basic, bearer or API-key authentication, and decodes JSON responses by default.

---

## Custom Fields

Custom Fields stores definitions of extra fields that an app lets users add to its records, such as a "Customer tier" on a contact. Definitions live in shared `xp_system_custom_fields` tables, grouped by app. Optional conditions and actions call a handler class in your app when a field's value changes, and the app stores the values itself. No framework app uses the module yet, and parts of it need workarounds in 0.0.44, which the page describes.

---

## Encryption

Encryption encrypts and decrypts strings with the system's `encryption_key`, creates hashes, and builds simple tokens for passing data between requests.

---

## Exchanger API

Exchanger API connects the framework to QuickBooks over OAuth 2. It stores the tokens in its own table, keeps them in the session, checks the connection, and wraps the QuickBooks calls for authorization, queries, batches and invoice PDFs. In 0.0.44 the module can't be loaded as shipped and the QuickBooks SDK isn't included; the page explains both.

---

## File Manager

File Manager handles files and images: uploads with validation, image thumbnails, building public URLs and paths, copying and deleting files and folders, and storing files either on the server or in an S3 bucket.

---

## JSON Manager

JSON Manager works with JSON strings and files: it reads nested values, checks whether a key exists, and changes the data with `set`, `push`, `pop`, `shift`, `unshift`, `merge` and `unset`.

---

## XML Manager

XML Manager works with XML strings and files: it reads values with XPath, adds, updates and removes elements and attributes, and returns results as XML or as arrays.

---

## Util

Util groups small helper classes, each reached through an accessor such as `Util::Validation()`: common functions, date and time handling, IP addresses, time zones, input validation, QR codes and image handling.

---

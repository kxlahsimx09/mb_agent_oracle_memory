---
title: MONGODB_READ_URI optional SECONDARY URI for least-privilege Mongo (db679b4 #410,
tags: [technical-writer, repo:mobiz-payment-gateway, current, mongo, least-privilege, db-rbac]
created: 2026-05-07
source: db/mongo.go:50-66,127-143@db679b4
project: github.com/kokarat/mobiz-payment-gateway
---

# MONGODB_READ_URI optional SECONDARY URI for least-privilege Mongo (db679b4 #410,

MONGODB_READ_URI optional SECONDARY URI for least-privilege Mongo (db679b4 #410, 2026-05-07).

`db.Connect()` in `db/mongo.go` now reads `EnvMongoReadURI()` first when wiring the SECONDARY/read pool. When the env var is empty the SECONDARY reuses `MONGODB_URI` (unchanged dev behaviour); when set, the SECONDARY connects under separate credentials — production wires it to DigitalOcean managed Mongo's built-in `do-readonly` user (companion `54873f1` #416 added the var to `k8s/secrets.yaml` + `k8s/deployment.yaml`).

Effect: any `GetReadCollection` caller is now sand-boxed at the database RBAC layer, not just the app layer. ReadPreference (`SecondaryPreferred`), pool sizes, and the existing auto-fallback to PRIMARY when SECONDARY init fails are all unchanged. Startup log line "Connecting SECONDARY with MONGODB_READ_URI (separate read-only credentials)" confirms the split is active.

---
*Added via Oracle Learn*

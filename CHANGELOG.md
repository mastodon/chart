# 6.6.6

- Added additional customization for redis secret. Can now specify auth secrey key:
```yaml
redis:
  auth:
    existingSecret:
    existingSecretKey:
  sidekiq:
    auth:
      existingSecret:
      existingSecretKey:
  cache:
    auth:
      existingSecret:
      existingSecretKey:

```

# 6.6.5

- Update the mastodon version to v4.5.5

# 6.6.4

- Update the mastodon version to v4.5.4

# 6.6.3

- Update the mastodon version to v4.5.3

# 6.6.2

- Update the mastodon version to v4.5.2

# 6.6.1

- Update the mastodon version to v4.5.1

# 6.6.0

- Update the mastodon version to v4.5.0. Please refer to the [release notes](https://github.com/mastodon/mastodon/releases/tag/v4.5.0) for important changes.

# 6.5.8

- Update the mastodon version to v4.4.8

# 6.5.7

- Updated all dependent chart images to bitnami legacy repositories.
- Updated chart test jobs.
- Added additional configuration options:
```yaml
mastodon:
  s3:
    protocol: https
...
elasticsearch:
  caSecret:
  indexPrefix:
...
jobLabels:
```

# 6.5.6

- Update the mastodon version to v4.4.7

# 6.5.5

- Update the mastodon version to v4.4.6

# 6.5.4

- Update the mastodon version to v4.4.5

# 6.5.3

- Update the mastodon version to v4.4.4

# 6.5.2

- Update the Mastodon version to v4.4.3

# 6.5.1

- Updated the Mastodon version to v4.4.2

# 6.5.0

Updated the Mastodon version to v4.4.1. Please read the [4.4.0 release notes](https://github.com/mastodon/mastodon/releases/tag/v4.4.0) before updating from a version < 4.4. In particular:
- Redis & Postgres minimum versions have been bumped to 6.2 and 13 respectively
- Redis namespace support has been dropped
- No-downtime updates from versions before 4.3.0 are not supported
- Elasticsearch mappings need to be updated manually via `tootctl` after deploying this new version
- The new experimental Fediverse Auxiliary Service (`fasp`) Sidekiq queue needs to be added to the list of processed queues if you changed the default Sidekiq values

# 6.4.0

- Added configuration for [bulk SMTP](https://docs.joinmastodon.org/admin/config/#optional-bulk-email-settings):
```yaml
mastodon:
  smtp:
    bulk:
```

# 6.3.4

- Updated the Mastodon version to v4.3.9

# 6.3.3

- Updated the Mastodon version to v4.3.8

# 6.3.2

- No longer sets `DEFAULT_LOCALE` to `en` by default; leaves this value unset.

# 6.3.1

- Removed DB_POOL from the ConfigMap as we should never have to override this.

# 6.3.0

- Added `nodeSelector` fields for every resource type for better fine-grain tuning of where resources end up.

# 6.2.4

- Fixed an issue where redis secrets specified in values or the helm CLI wouldn't be used by the db-prepare job on install.

# 6.2.3

- Updated the Mastodon version to v4.3.7

# 6.2.2

-  `app.kubernetes.io/version` shortens any potential digest hash to 7 characters to avoid hitting the 63 character label limit.

# 6.2.1

- Fixed some situations where disabling all bitnami charts caused it to error.
- Fixed a potential null postgresql host value error.

# 6.2.0

- Added ability to add pod labels to pods created from Deployment objects at the global level

# 6.1.1

- Updated the Mastodon version to v4.3.6

# 6.1.0

- Added a new job to re/build elasticsearch indices as a post-upgrade hook:
```yaml
mastodon:
  hooks:
    deploySearch:
```

# 6.0.3

- Updated the Mastodon version to v4.3.5

# 6.0.2

- Helm version tagging now utilizes `.Values.image.tag` when set.

# 6.0.1

- Added additional values to separate out `db:prepare` and `db:migrate` jobs and whether they should run:
```yaml
mastodon:
  hooks:
    dbPrepare:
      enabled: true
    dbMigrate:
      enabled: true
```

# 6.0.0

### !! BREAKING CHANGES !!
- Services for web & streaming now use `ipFamilyPolicy: PreferDualStack`. This will cause upgrades on existing deployments to fail, as kubernetes cannot patch this field. Please remove both service objects before running `helm upgrade` (services are `mastodon-web` and `mastodon-streaming` by default).

### Features
- Added prometheus metrics config for web and sidekiq pods (feature will be available with Mastodon v4.4).
```yaml
mastodon:
  metrics:
    prometheus:
```
- Added ability to automatically upload assets to an S3 bucket:
```yaml
mastodon:
  hooks:
    s3Upload:
```
- Added OpenTelemetry metrics:
```yaml
mastodon:
  otel:
---
mastodon:
  sidekiq:
    otel:
---
mastodon:
  web:
    otel:
```
- Fine-grained control of labels and annotations for both pods and deployments.
- Additional redis options for separate instances (app, sidekiq, cache).
- Configurable PodDisruptionBudgets for web and streaming pods.

### Fixes
- Various database migrations fixes
  - Fixed first-time install DB setup on self-managed databases
  - Fixed running migrations through a connection pooler.
- Removed old, unused jobs:
  - chewy upgrade (use `tootctl search deploy` instead)
  - assets precompile

# 5.1.0

- Added values for Active Record Encryption in Redis:
    ```yaml
    mastodon:
      secrets:
        activeRecordEncryption:
          primaryKey:
          deterministicKey:
          keyDerivationSalt:
    ```

- Small bugfix related to automatic secret generation

# [5.0.0](https://github.com/mastodon/chart/commit/63a052b6a5c19dabd172c15c1fd74298dcc544b2)

- Updated major versions of chart dependencies (postgres, redis, elasticsearch)

# [4.0.0](https://github.com/mastodon/chart/compare/920cf37..ae892d5)

- adds support for multiple Sidekiq deployments to be configured to manage
  different sets of queues.

- smtp: replaces `enable_starttls_auto` boolean with `enable_starttls` setting
  that defaults to `auto`.

- adds support for statsd publishing:
    ```
    mastodon:
      metrics:
        statsd:
          address:
    ```

- allows disabling the included redis deployment in order to use an existing external redis server:
    ```
    redis:
      enabled: false
    ```

- adds support for [authorized
  fetch](https://docs.joinmastodon.org/admin/config/#authorized_fetch):
    ```
    mastodon:
      authorizedFetch: true
    ```

- removed the `HorizontalPodAutoscaler` and the global autoscaling configuration.

A number of other configuration options have been added, see [values.yaml](./values.yaml).

# 3.0.0

skipped

#  2.1.0

## ingressClassName and tls-acme changes
The annotations previously defaulting to nginx have been removed and support
 for ingressClassName has been added.
```yaml
ingress:
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
```

To restore the old functionality simply add the above snippet to your `values.yaml`,
but the recommendation is to replace these with `ingress.ingressClassName` and use
cert-manager's issuer/cluster-issuer instead of tls-acme.
If you're uncertain about your current setup leave `ingressClassName` empty and add
`kubernetes.io/tls-acme` to `ingress.annotations` in your `values.yaml`.

#  2.0.0

## Fixed labels
Because of the changes in [#19706](https://github.com/mastodon/mastodon/pull/19706) the upgrade may fail with the following error:
```Error: UPGRADE FAILED: cannot patch "mastodon-sidekiq"```

If you want an easy upgrade and you're comfortable with some downtime then
simply delete the -sidekiq, -web, and -streaming Deployments manually.

If you require a no-downtime upgrade then:
1. run `helm template` instead of `helm upgrade`
2. Copy the new -web and -streaming services into `services.yml`
3. Copy the new -web and -streaming deployments into `deployments.yml`
4. Append -temp to the name of each deployment in `deployments.yml`
5. `kubectl apply -f deployments.yml` then wait until all pods are ready
6. `kubectl apply -f services.yml`
7. Delete the old -sidekiq, -web, and -streaming deployments manually
8. `helm upgrade` like normal
9. `kubectl delete -f deployments.yml` to clear out the temporary deployments

## PostgreSQL passwords
If you've previously installed the chart and you're having problems with
postgres not accepting your password then make sure to set `username` to
`postgres` and `password` and `postgresPassword` to the same passwords.
```yaml
postgresql:
  auth:
    username: postgres
    password: <same password>
    postgresPassword: <same password>
```

And make sure to set `password` to the same value as `postgres-password`
in your `mastodon-postgresql` secret:
```kubectl edit secret mastodon-postgresql```

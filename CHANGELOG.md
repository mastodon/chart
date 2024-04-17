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

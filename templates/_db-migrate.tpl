{{/* vim: set filetype=mustache: */}}
{{/*
Spec template for DB migration pre- and post-install/upgrade jobs.
*/}}
{{- define "mastodon.dbMigrateJob" -}}
apiVersion: batch/v1
kind: Job
metadata:
  {{- if .preDeploy }}
  name: {{ include "mastodon.fullname" . }}-db-pre-migrate
  {{- else }}
  name: {{ include "mastodon.fullname" . }}-db-post-migrate
  {{- end }}
  labels:
    {{- include "mastodon.labels" . | nindent 4 }}
  annotations:
    {{- if .preDeploy }}
    "helm.sh/hook": pre-upgrade
    {{- else }}
    "helm.sh/hook": post-install,post-upgrade
    {{- end }}
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
    "helm.sh/hook-weight": "-2"
spec:
  template:
    metadata:
      name: {{ include "mastodon.fullname" . }}-db-migrate
      {{- with .Values.jobAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
    spec:
      restartPolicy: Never
      containers:
        - name: {{ include "mastodon.fullname" . }}-db-migrate
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          command:
            - bundle
            - exec
            - rake
            - db:migrate
          envFrom:
            - secretRef:
                name: {{ template "mastodon.secretName" . }}
          env:
            - name: "DB_HOST"
              value: {{ template "mastodon.postgres.host" . }}
            - name: "DB_PORT"
              value: {{ template "mastodon.postgres.port" . }}
            - name: "DB_NAME"
              value: {{ .Values.postgresql.auth.database }}
            - name: "DB_USER"
              value: {{ .Values.postgresql.auth.username }}
            - name: "DB_PASS"
              valueFrom:
                secretKeyRef:
                  name: {{ template "mastodon.postgresql.secretName" . }}
                  key: password
            - name: "REDIS_HOST"
              value: {{ template "mastodon.redis.host" . }}
            - name: "REDIS_PORT"
              value: {{ .Values.redis.port | default "6379" | quote }}
            {{- if .Values.redis.sidekiq.enabled }}
            {{- if .Values.redis.sidekiq.hostname }}
            - name: SIDEKIQ_REDIS_HOST
              value: {{ .Values.redis.sidekiq.hostname }}
            {{- end }}
            {{- if .Values.redis.sidekiq.port }}
            - name: SIDEKIQ_REDIS_PORT
              value: {{ .Values.redis.sidekiq.port | quote }}
            {{- end }}
            {{- end }}
            {{- if .Values.redis.cache.enabled }}
            {{- if .Values.redis.cache.hostname }}
            - name: CACHE_REDIS_HOST
              value: {{ .Values.redis.cache.hostname }}
            {{- end }}
            {{- if .Values.redis.cache.port }}
            - name: CACHE_REDIS_PORT
              value: {{ .Values.redis.cache.port | quote }}
            {{- end }}
            {{- end }}
            - name: "REDIS_DRIVER"
              value: "ruby"
            - name: "REDIS_PASSWORD"
              valueFrom:
                secretKeyRef:
                  name: {{ template "mastodon.redis.secretName" . }}
                  key: redis-password
          {{- if .preDeploy }}
            - name: "SKIP_POST_DEPLOYMENT_MIGRATIONS"
              value: "true"
          {{- end }}
{{- end }}

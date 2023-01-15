{{/* vim: set filetype=mustache: */}}
{{/*
Spec template for DB migration pre- and post-install/upgrade jobs.
*/}}
{{- define "mastodon.dbMigrateJob" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "mastodon.fullname" . }}-db-migrate
  labels:
    {{- include "mastodon.labels" . | nindent 4 }}
  annotations:
    {{- if .preDeploy }}
    "helm.sh/hook": pre-install,pre-upgrade
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
      {{- if (not .Values.mastodon.s3.enabled) }}
      # ensure we run on the same node as the other rails components; only
      # required when using PVCs that are ReadWriteOnce
      {{- if or (eq "ReadWriteOnce" .Values.mastodon.persistence.assets.accessMode) (eq "ReadWriteOnce" .Values.mastodon.persistence.system.accessMode) }}
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: app.kubernetes.io/part-of
                    operator: In
                    values:
                      - rails
              topologyKey: kubernetes.io/hostname
      {{- end }}
      volumes:
        - name: assets
          persistentVolumeClaim:
            claimName: {{ template "mastodon.fullname" . }}-assets
        - name: system
          persistentVolumeClaim:
            claimName: {{ template "mastodon.fullname" . }}-system
      {{- end }}
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
            - configMapRef:
                name: {{ include "mastodon.fullname" . }}-env
            - secretRef:
                name: {{ template "mastodon.secretName" . }}
          env:
            - name: "DB_PASS"
              valueFrom:
                secretKeyRef:
                  name: {{ template "mastodon.postgresql.secretName" . }}
                  key: password
            - name: "REDIS_PASSWORD"
              valueFrom:
                secretKeyRef:
                  name: {{ template "mastodon.redis.secretName" . }}
                  key: redis-password
            - name: "PORT"
              value: {{ .Values.mastodon.web.port | quote }}
          {{- if .preDeploy }}
            - name: "SKIP_POST_DEPLOYMENT_MIGRATIONS"
              value: "true"
          {{- end }}
          {{- if (not .Values.mastodon.s3.enabled) }}
          volumeMounts:
            - name: assets
              mountPath: /opt/mastodon/public/assets
            - name: system
              mountPath: /opt/mastodon/public/system
          {{- end }}
{{- end }}

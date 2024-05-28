{{/*
    Expand the name of the chart.
    */}}
    {{- define "react-site.name" -}}
    {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
    {{- end -}}
    
    {{/*
    Create a default fully qualified app name.
    */}}
    {{- define "react-site.fullname" -}}
    {{- if .Values.fullnameOverride -}}
    {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
    {{- include "react-site.name" . }}-{{ .Release.Name | trunc 63 | trimSuffix "-" -}}
    {{- end -}}
    {{- end -}}
    
    {{/*
    Create chart labels
    */}}
    {{- define "react-site.labels" -}}
    helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
    {{ include "react-site.name" . }}-release: {{ .Release.Name }}
    app.kubernetes.io/name: {{ include "react-site.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/version: {{ .Chart.AppVersion }}
    app.kubernetes.io/managed-by: {{ .Release.Service }}
    {{- end -}}
    
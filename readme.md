# 🌐 Kubernetes Internet Speedtest Exporter

Monitoramento automatizado de velocidade de internet (Download, Upload e Latência) rodando em um cluster Kubernetes, integrado com Prometheus (`PodMonitor`) e visualizado através de um dashboard customizado no Grafana.

---

## 🏗️ Arquitetura e Funcionamento

1. **Geração dos Dados (`CronJob`)**:
   * Um CronJob executa periodicamente testes de velocidade e grava as métricas no formato estruturado do Prometheus (`.prom`).
   * Os dados são salvos em um **Volume Persistente Compartilhado (PVC)** montado via NFS (`speedtest-metrics-pvc`).

2. **Exposição HTTP (`Nginx Sidecar`)**:
   * Um pod dedicado (`speedtest-exporter-http`) executa um servidor Nginx que lê o arquivo `.prom` estático gerado pelo CronJob e o expõe via HTTP.
   * O cabeçalho de resposta é configurado estritamente como `Content-Type: text/plain; version=0.0.4; charset=utf-8` para atender às exigências do Prometheus.

3. **Coleta de Métricas (`PodMonitor`)**:
   * Um recurso **`PodMonitor`** (`speedtest-pod-monitor`) instalado no namespace `monitoring` aponta diretamente para o pod do Nginx no namespace `internet-check-home`.
   * **Seletor de Alvo**: `App: speedtest-exporter-http`
   * **Endpoint**: `/speedtest.prom` (a cada 60 segundos).

4. **Visualização (`Grafana`)**:
   * Dashboard configurado com medidores (*Big Numbers / Gauges*) para o estado atual e gráficos de linha temporais.
   * **Métricas Principais**:
     * `internet_download_bps` (convertida automaticamente no Grafana para `Mb/s`).
     * `internet_upload_bps` (convertida automaticamente no Grafana para `Mb/s`).
     * `internet_ping_ms` (exibida em `ms`).

---

## 🛠️ Validação Rápida no Cluster

* **Verificar o PodMonitor**:
  ```bash
  kubectl get podmonitor -A

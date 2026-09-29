#!/bin/bash

OUTPUT_DIR="/config/metrics"
mkdir -p "$OUTPUT_DIR"
METRIC_FILE="$OUTPUT_DIR/speedtest.prom"

# Executa o speedtest oficial em formato JSON
RESULT=$(speedtest --accept-license --accept-gdpr -f json 2>/dev/null)

if [ $? -eq 0 ]; then
    # Extrai os valores usando grep e awk básicos (sem dependência de python3)
    DOWNLOAD=$(echo "$RESULT" | grep -o '"download":{[^}]*' | grep -o '"bandwidth":[0-9]*' | awk -F: '{print $2}')
    UPLOAD=$(echo "$RESULT" | grep -o '"upload":{[^}]*' | grep -o '"bandwidth":[0-9]*' | awk -F: '{print $2}')
    PING=$(echo "$RESULT" | grep -o '"latency":[0-9.]*' | head -n 1 | awk -F: '{print $2}')

    # Converte bandwidth de bytes para bits (* 8)
    DOWN_BPS=$(( DOWNLOAD * 8 ))
    UP_BPS=$(( UPLOAD * 8 ))

    # Escreve no formato padrão do Prometheus
    cat << EOF > "$METRIC_FILE"
# HELP internet_download_bps Velocidade de download da internet em bits por segundo
# TYPE internet_download_bps gauge
internet_download_bps $DOWN_BPS
# HELP internet_upload_bps Velocidade de upload da internet em bits por segundo
# TYPE internet_upload_bps gauge
internet_upload_bps $UP_BPS
# HELP internet_ping_ms Latência da conexão em milissegundos
# TYPE internet_ping_ms gauge
internet_ping_ms $PING
EOF

    echo "Métricas atualizadas com sucesso em $METRIC_FILE"
else
    echo "Erro ao executar o speedtest da Ookla."
fi

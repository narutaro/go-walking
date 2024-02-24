#!/bin/bash

# THING_NAME とトピック設定
THING_NAME="16a9b90b"
TOPIC_BASE="\$aws/device_location/$THING_NAME/get_position_estimate"
ACCEPTED_TOPIC="${TOPIC_BASE}/accepted"
REJECTED_TOPIC="${TOPIC_BASE}/rejected"

# ブローカーとクライアントIDの設定
BROKER_HOST=$(aws iot describe-endpoint --endpoint-type iot:Data-ATS --output text --query 'endpointAddress')

# ポート番号
PORT=8883

# 証明書ファイルのパス
CAFILE="$THING_NAME/AmazonRootCA1.pem"
CERTFILE="$THING_NAME/device.pem.crt"
KEYFILE="$THING_NAME/private.pem.key"

# mosquitto_sub コマンドを使用してトピックにサブスクライブ
mosquitto_sub --cafile "$CAFILE" \
              --cert "$CERTFILE" \
              --key "$KEYFILE" \
              -h "$BROKER_HOST" \
              -p $PORT \
              -t "$ACCEPTED_TOPIC" \
              -t "$REJECTED_TOPIC" \
              -i "$THING_NAME" \
              -v -d


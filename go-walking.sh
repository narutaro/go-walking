#!/bin/bash


# 設定変数
LOG=go-walking/log
CURRENT_TIME=$(date "+%Y%m%d-%H%M%S")

mkdir -p $HOME/$LOG

# iwスキャンコマンドの実行とログ出力
SCAN_OUTPUT=$(/usr/sbin/iw dev wlan0 scan | jc --iw-scan -p)
echo $SCAN_OUTPUT > $HOME/$LOG/${CURRENT_TIME}.iw

# jqでのデータ加工とログ出力
JSON_DATA=$(echo $SCAN_OUTPUT | jq -c '{WiFiAccessPoints: map({MacAddress: .bssid, Rss: .signal_dbm})}')
echo $JSON_DATA > $HOME/$LOG/${CURRENT_TIME}.json


# MQTTにデータをパブリッシュする関数
publish_data() {
    local THING_NAME="16a9b90b"
    local HOST=$(aws iot describe-endpoint --endpoint-type iot:Data-ATS --output text --query 'endpointAddress')
    local TOPIC="\$aws/device_location/$THING_NAME/get_position_estimate"
    local PORT="8883"
    mosquitto_pub --cafile $THING_NAME/AmazonRootCA1.pem \
                  --cert $THING_NAME/device.pem.crt \
                  --key $THING_NAME/private.pem.key \
                  -h $HOST \
                  -p $PORT \
                  -t $TOPIC \
                  -i $THING_NAME \
                  -m "$JSON_DATA" \
                  -d
    echo "Data published to MQTT topic."
}
# publish_data

send_mail() {
    local recipient="a@b.com"  # 受信者のメールアドレス
    local subject="Hello from go-walking at $CURRENT_TIME"
    local body=$(echo $JSON_DATA | jq '.')

    # メールの本文を作成
    echo -e "Subject: $subject\n\n$body" | msmtp --from=default -t $recipient
}
send_mail

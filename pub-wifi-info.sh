JSON_DATA='{
    "WiFiAccessPoints": [{
        "MacAddress": "A0:EC:F9:1E:32:C1",
        "Rss": -77
    }]
}'

HOST=$(aws iot describe-endpoint --endpoint-type iot:Data-ATS --output text --query 'endpointAddress')
THING_NAME=16a9b90b
TOPIC="\$aws/device_location/$THING_NAME/get_position_estimate"

mosquitto_pub --cafile $THING_NAME/AmazonRootCA1.pem \
  --cert $THING_NAME/device.pem.crt \
  --key $THING_NAME/private.pem.key \
  -h $HOST \
  -p 8883 \
  -t $TOPIC \
  -i rp \
  -m "$JSON_DATA" \
  -d


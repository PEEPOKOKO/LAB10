#include <WiFiMulti.h>
#include <InfluxDbClient.h>
#include <InfluxDbCloud.h>
#include "WiFi.h"

#define WIFI_SSID "Poopae7"
#define WIFI_PASSWORD "12345678"

#define INFLUXDB_URL "https://us-east-1-1.aws.cloud2.influxdata.com"
#define INFLUXDB_TOKEN "RJmbyFuORzd6l46BUTDVrq-ptr0BdUx_hm6iwALNulUfxpMfG7EhYJmUQqHM4DCtkSDVvZuA08XDm_VSzHFKbg=="
#define INFLUXDB_ORG "SUT"
#define INFLUXDB_BUCKET "Poopae"

#define TZ_INFO "UTC7"

WiFiMulti wifiMulti;
InfluxDBClient client(INFLUXDB_URL, INFLUXDB_ORG, INFLUXDB_BUCKET, INFLUXDB_TOKEN, InfluxDbCloud2CACert);

Point sensorNode("Poopae");

void setup() {
  Serial.begin(115200);

  WiFi.mode(WIFI_STA);
  wifiMulti.addAP(WIFI_SSID, WIFI_PASSWORD);

  Serial.print("Connecting to WiFi");
  while (wifiMulti.run() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println(" Connected!");

  // ซิงค์เวลาจาก Server (จำเป็นสำหรับการส่งข้อมูลเข้า Cloud)
  timeSync(TZ_INFO, "pool.ntp.org", "time.nis.gov");

  // ตรวจสอบการเชื่อมต่อ InfluxDB
  if (client.validateConnection()) {
    Serial.print("Connected to InfluxDB: ");
    Serial.println(client.getServerUrl());
  } else {
    Serial.print("InfluxDB connection failed: ");
    Serial.println(client.getLastErrorMessage());
  }
}

void loop() {
  // สุ่มค่าเหมือนในโค้ดเดิมของคุณ
  float ESP32_Tempp = random(1000, 3000) / 100.0;
  float DHT22_Temp = random(1000, 3000) / 100.0;
  float DHT22_Humid = random(1000, 3000) / 100.0;
  float Rotary_Angle = random(10000, 36000) / 100.0;

  // เคลียร์ค่าเก่าและเพิ่มค่าใหม่ลงใน Point
  sensorNode.clearFields();
  sensorNode.addField("ESP32_MAC_Address", WiFi.macAddress());
  sensorNode.addField("ESP32_Wifi_Name", "bps");
  sensorNode.addField("ESP32_Tempp", ESP32_Tempp);
  sensorNode.addField("DHT22_Temp", DHT22_Temp);
  sensorNode.addField("DHT22_Humid", DHT22_Humid);
  sensorNode.addField("Rotary_Angle", Rotary_Angle);

  // ส่งข้อมูลไปที่ InfluxDB
  Serial.print("Writing: ");
  Serial.println(sensorNode.toLineProtocol());

  if (!client.writePoint(sensorNode)) {
    Serial.print("InfluxDB write failed: ");
    Serial.println(client.getLastErrorMessage());
  }

  delay(10000); // แนะนำให้ส่งทุก 10 วินาทีสำหรับบัญชีฟรี
}
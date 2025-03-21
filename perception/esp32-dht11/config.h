#ifndef _config_

// Server URL

#define API_IP        "192.168.0.142"
#define API_PORT      "8080"
#define API_IP_PORT   API_IP ":" API_PORT

// WiFi Access

#define WIFI_SSID     "FMRv3"
#define WIFI_PASSWORD "-Fmr47@rF-"

// Device Identity


#define DEVICE_ID     "esp32-dht11"

// Sensor configuration

//esp32-dht11 
#define ONE_WIRE_GPIO 17
#define USER_AGENT    "esp-idf/1.0 esp32"

// esp32s2-dht11 
//#define ONE_WIRE_GPIO 0
// #define USER_AGENT    "esp-idf/1.0 esp32s2"

// esp8266-dht11-arduino
// #define ONE_WIRE_GPIO 2

// esp32c3-bmp280 
// #define SDA_GPIO      4
// #define SCL_GPIO      5
// #define USER_AGENT    "esp-idf/1.0 esp32c3"

// esp32-bmp280 
// #define SDA_GPIO     21
// #define SCL_GPIO     22
// #define USER_AGENT   "esp-idf/1.0 esp32c3"


#define _config_
#endif

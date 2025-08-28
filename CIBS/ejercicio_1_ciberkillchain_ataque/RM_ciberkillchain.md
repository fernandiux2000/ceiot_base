# CiberKillChain - Ataque a Sistema IoT

## Alumno
*  **Alumno:** Rodrigo Morocho Roman

## Sistema víctima
Un sistema IoT de monitoreo ambiental compuesto por:
* **Hardware:** Un ESP32 con sensores de temperatura/humedad (DHT11) y calidad de aire (MQ-2).
* **Backend Dockerizado:** Un bróker MQTT (Mosquitto), una API en Node.js y una base de datos MongoDB.
* **Frontend Dockerizado:** Un dashboard en Angular/Ionic que muestra los datos en tiempo real y dispara alarmas visuales si los valores superan ciertos umbrales.

## Objetivo
Minar la capacidad operativa y la reputación de una empresa competidora, explotando una vulnerabilidad de acceso anónimo en su sistema IoT para inyectar datos falsos; esto se realiza en un momento crítico, como la inspección de un cliente, para disparar alarmas de emergencia inexistentes, con el fin de simular una falla catastrófica, destruir la credibilidad de la víctima y asegurar que un lucrativo contrato sea adjudicado a la empresa que orquestó el ataque.

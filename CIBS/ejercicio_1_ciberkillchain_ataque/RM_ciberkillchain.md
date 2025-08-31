# CiberKillChain - Ataque a sistema de Monitoreo ambiental IoT

## Alumno
* **Alumno:** Rodrigo Morocho Roman

## Sistema víctima
El sistema, denominado "Monitoreo ambiental IoT", es una solución de monitoreo de entornos controlados compuesta por:
* **Hardware:** Un dispositivo ESP32 con sensores de temperatura/humedad (DHT11) y calidad del aire (MQ-2).
* **Backend Dockerizado:** Un bróker MQTT (Mosquitto), una API en Node.js para procesar y servir datos, y una base de datos MongoDB para el almacenamiento.
* **Frontend Dockerizado:** Un dashboard en Angular/Ionic que visualiza los datos en tiempo real mediante medidores y dispara alarmas visuales cuando los valores superan umbrales predefinidos.

## Objetivo
Sabotear el sistema "Monitoreo ambiental IoT" de una empresa rival, inyectando datos falsos vía MQTT para disparar alarmas críticas de sobrecalentamiento y gas durante una auditoría clave de un cliente, para provocar su descalificación inmediata y asegurar que el lucrativo contrato sea adjudicado de forma exclusiva a la empresa competidora que orquestó el ataque, garantizando así un rédito económico directo.

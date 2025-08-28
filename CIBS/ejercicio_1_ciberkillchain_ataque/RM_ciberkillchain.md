# CiberKillChain - Ataque a Sistema IoT

## Alumno
* **Alumno:** Rodrigo Morocho Roman

## Sistema Víctima
Un sistema IoT de monitoreo ambiental compuesto por:
* **Hardware:** Un ESP32 con sensores de temperatura/humedad (DHT11) y calidad de aire (MQ-2).
* **Backend Dockerizado:** Un bróker MQTT (Mosquitto), una API en Node.js y una base de datos MongoDB.
* **Frontend Dockerizado:** Un dashboard en Angular/Ionic que muestra los datos en tiempo real y dispara alarmas visuales si los valores superan ciertos umbrales.

## Objetivo
Minar la capacidad operativa y la reputación de la víctima. El atacante explota una vulnerabilidad en el sistema IoT para inyectar datos falsos de forma remota, disparando alarmas de emergencia inexistentes que fuerzan a la empresa víctima a detener su producción y realizar evacuaciones. Este caos deliberado genera pérdidas económicas y daña la confianza de los clientes, beneficiando directamente al competidor que pagó por el ataque.

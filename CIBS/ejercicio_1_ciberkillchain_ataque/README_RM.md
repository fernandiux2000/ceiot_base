# CiberKillChain - Ataque a sistema de Monitoreo ambiental IoT

## Alumno
* Rodrigo Morocho Roman

## Sistema víctima
El sistema, denominado "Monitoreo ambiental IoT", una plataforma comercial de monitoreo en tiempo real para la cadena de frío y la logística de productos de alta sensibilidad. Su principal argumento de venta es la garantía de la integridad ambiental de las instalaciones de almacenamiento, utilizando sensores IoT que miden temperatura y calidad del aire. Los datos son procesados por una plataforma en la nube y presentados a los clientes a través de un dashboard web que incluye un sistema de alarmas visuales automáticas ante cualquier desviación de los parámetros seguros.

## Objetivo
Sabotear el sistema "Monitoreo ambiental IoT", inyectando datos falsos vía MQTT para disparar alarmas críticas de sobrecalentamiento y gas durante una auditoría clave de un cliente, para provocar su descalificación inmediata y asegurar que el lucrativo contrato sea adjudicado de forma exclusiva a la empresa competidora que orquestó el ataque, garantizando así un rédito económico directo.

## Resolución

### 1- Reconnaissance

> Se identificó el uso del protocolo **MQTT**. Un posterior escaneo de puertos al subdominio descubierto (`dashboard.empresa-victima.com`) reveló la vulnerabilidad crítica: un **bróker MQTT expuesto en el puerto 1883 que permite conexiones anónimas**, estableciendo el punto de entrada principal para el ataque.

*Técnicas utilizadas: [T1591 Gather Victim Org Information], [T1590 Gather Victim Host Information], [T1595 Active Scanning]*

El ataque se inicia con una fase de inteligencia de fuentes abiertas (OSINT) para construir un perfil técnico de la empresa víctima, aplicando la técnica **[T1591 Gather Victim Org Information](https://attack.mitre.org/techniques/T1591/)**. Se analizan publicaciones de blog de la empresa, comunicados de prensa sobre su nueva plataforma "Monitoreo ambiental IoT" y ofertas laborales para ingenieros de software. Estas últimas revelan el uso de tecnologías como Docker, Node.js, Angular y, de manera crucial, el protocolo MQTT, lo que proporciona una idea clara de la arquitectura subyacente.

A continuación, se procede a identificar la huella digital de la víctima, utilizando la técnica **[T1590 Gather Victim Host Information](https://attack.mitre.org/techniques/T1590/)**. Mediante herramientas de recolección de subdominios, se descubre la existencia de un portal de acceso público en `dashboard.empresa-victima.com`.

Finalmente, con un objetivo claro, se ejecuta un **[T1595 Active Scanning](https://attack.mitre.org/techniques/T1595/)** sobre el dominio identificado. Un escaneo de puertos revela que, además del puerto `443` (HTTPS) para el dashboard, el servidor tiene expuesto el puerto `1883`. Una simple prueba de conexión con un cliente MQTT genérico confirma que el bróker permite conexiones anónimas, revelando la vulnerabilidad crítica que será el eje del ataque.

### 2- Weaponization

> Se preparó una herramienta de cliente MQTT estándar (`mosquitto_pub`) como vehículo de inyección, y se diseñó el payload malicioso: un mensaje JSON con valores de sensores extremos para engañar al sistema y disparar las alarmas deseadas.

*Técnicas utilizadas: [T1588.002 Obtain Capabilities: Tool], [CWE-345 Insufficient Verification of Data Authenticity]*

Una vez identificado el bróker MQTT como vector de entrada, se procede a preparar las herramientas para el ataque.

Para la técnica **[T1588.002 Obtain Capabilities: Tool](https://attack.mitre.org/techniques/T1588/002/)**, se adquiere un cliente MQTT estándar, específicamente `mosquitto_pub`, que viene incluido en la imagen de Docker de `eclipse-mosquitto`. Esta herramienta legítima de administración se convertirá en el vehículo para inyectar los datos falsos en el sistema.

Aprovechando la vulnerabilidad **[CWE-345 Insufficient Verification of Data Authenticity](https://cwe.mitre.org/data/definitions/345.html)**, que se asume basándose en la falta de autenticación del bróker, se desarrolla el payload malicioso. Se elabora un mensaje en formato JSON, estructurado para ser indistinguible de una publicación legítima del sensor, pero conteniendo valores extremos (`"temperatura": 99`, `"gasLevel": 999`). Estos valores son seleccionados específicamente para sobrepasar los umbrales de la lógica de negocio del sistema y así disparar las alarmas visuales en el dashboard.

### 3- Delivery

> El JSON malicioso se entrega directamente al sistema víctima a través de la red, utilizando el cliente MQTT para enviar el paquete al puerto 1883 expuesto del bróker.

*Técnica utilizada: [T1190 Exploit Public-Facing Application]*

La fase de entrega es directa y se ejecuta de forma remota. Utilizando la técnica **[T1190 Exploit Public-Facing Application](https://attack.mitre.org/techniques/T1190/)**, se conecta al bróker MQTT, que es una aplicación expuesta públicamente y vulnerable debido a su configuración de acceso anónimo. A través del cliente `mosquitto_pub` preparado en la fase anterior, se envía el payload JSON malicioso, a través de internet, hasta la dirección IP y el puerto `1883` del servidor víctima. El paquete MQTT conteniendo los datos falsos llega al bróker, completando la fase de entrega y preparando el terreno para la explotación.

### 4- Exploitation

> Ocurre en el momento en que el bróker MQTT, al carecer de mecanismos de autenticación, procesa el paquete malicioso como si fuera legítimo, completando la inyección de datos en el flujo del sistema.

*Técnicas utilizadas: [T1190 Exploit Public-Facing Application], [CWE-345 Insufficient Verification of Data Authenticity]*

Se explota la vulnerabilidad inherente del sistema, correspondiente a la técnica **[T1190 Exploit Public-Facing Application](https://attack.mitre.org/techniques/T1190/)**. El bróker MQTT, al recibir el paquete `PUBLISH` entregado en la fase anterior, no realiza ninguna validación de su origen. Debido a la falla **[CWE-345 Insufficient Verification of Data Authenticity](https://cwe.mitre.org/data/definitions/345.html)**, el servidor acepta el payload anónimo y lo procesa como una transmisión válida. En consecuencia, el bróker retransmite inmediatamente el mensaje JSON con los datos falsos a todos los clientes suscritos al tópico `sensores/casa`, incluyendo el `api_server` del backend, que ahora tratará esta información maliciosa como una lectura real del sensor.



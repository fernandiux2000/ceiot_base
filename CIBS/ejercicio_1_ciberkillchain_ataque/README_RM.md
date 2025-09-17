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

### 5- Installation

> En el tipo de ataque de inyección de datos, la fase de Instalación no aplica, ya que el objetivo no es establecer una persistencia en el sistema operativo o dejar un backdoor.

*Técnicas utilizadas: No aplica.*

Esta fase no es necesaria para cumplir el objetivo del ataque. La explotación de la vulnerabilidad del bróker MQTT permite la inyección de datos en tiempo real desde el exterior. El ataque no busca instalar malware, modificar archivos de configuración en el servidor, ni establecer un punto de acceso persistente (backdoor) en el sistema víctima. El efecto del ataque es inmediato a través de la manipulación de los datos que el sistema procesa, por lo que no se requiere una "instalación" para mantener el acceso o asegurar el impacto.

### 6- Command & Control

> El control sobre el sistema se mantiene a través del mismo bróker MQTT, que actúa como un canal de Comando y Control improvisado, permitiendo al atacante enviar nuevos payloads para manipular el estado de las alarmas a voluntad.

*Técnica utilizada: [T1071 Application Layer Protocol]*

En este ataque, no se establece un canal de C2 tradicional con un servidor remoto. En su lugar, se utiliza el propio protocolo de la aplicación víctima como canal de comando y control, lo que corresponde a la técnica **[T1071 Application Layer Protocol](https://attack.mitre.org/techniques/T1071/)**. Se mantiene la capacidad de influir en el sistema de forma remota y persistente simplemente manteniendo el acceso al bróker MQTT abierto. Se puede automatizar la inyección de datos mediante un script local que envíe diferentes payloads JSON en momentos programados, permitiendo al atacante activar o desactivar las falsas alarmas a discreción para maximizar el impacto durante la auditoría del cliente.

### 7- Actions on Objectives

> Finalmente, se utiliza el canal de C2 para ejecutar el ataque en el momento preciso, logrando el objetivo final de sabotaje al desacreditar a la víctima y asegurar el beneficio económico para su cliente.

*Técnicas utilizadas: [T1491 Defacement], [T1565.001 Stored Data Manipulation]*

En el momento exacto en que la empresa víctima está realizando la auditoría final con su cliente potencial, se ejecuta la acción sobre el objetivo. Utilizando el canal de C2 (el bróker MQTT), el atacante publica el payload malicioso con los valores extremos de temperatura y gas.

El primer impacto es una forma de **[T1491 Defacement](https://attack.mitre.org/techniques/T1491/)**: el dashboard, que está siendo presentado al cliente como prueba de la fiabilidad del sistema, se "desfigura" con alarmas críticas en rojo, proyectando una imagen de falla catastrófica e incompetencia.

Simultáneamente, se logra una **[T1565.001 Stored Data Manipulation](https://attack.mitre.org/techniques/T1565/001/)**, ya que estos datos falsos son guardados permanentemente en la base de datos de la víctima, corrompiendo sus registros históricos y dejando una "evidencia" del falso incidente.

El resultado es la pérdida total de confianza por parte del cliente, y, en última instancia, la pérdida del contrato, cumpliendo así el objetivo económico del ataque.

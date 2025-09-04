# CiberKillChain - Ataque a sistema de Monitoreo ambiental IoT

## Alumno
* Rodrigo Morocho Roman

## Sistema víctima
El sistema, denominado "Monitoreo ambiental IoT", una plataforma comercial de monitoreo en tiempo real para la cadena de frío y la logística de productos de alta sensibilidad. Su principal argumento de venta es la garantía de la integridad ambiental de las instalaciones de almacenamiento, utilizando sensores IoT que miden temperatura y calidad del aire. Los datos son procesados por una plataforma en la nube y presentados a los clientes a través de un dashboard web que incluye un sistema de alarmas visuales automáticas ante cualquier desviación de los parámetros seguros.

## Objetivo
Sabotear el sistema "Monitoreo ambiental IoT", inyectando datos falsos vía MQTT para disparar alarmas críticas de sobrecalentamiento y gas durante una auditoría clave de un cliente, para provocar su descalificación inmediata y asegurar que el lucrativo contrato sea adjudicado de forma exclusiva a la empresa competidora que orquestó el ataque, garantizando así un rédito económico directo.

## Resolución

### 1- Reconnaissance
*Técnicas utilizadas: [T1591 Gather Victim Org Information], [T1590 Gather Victim Host Information], [T1595 Active Scanning]*

El ataque se inicia con una fase de inteligencia de fuentes abiertas (OSINT) para construir un perfil técnico de la empresa víctima, aplicando la técnica **[T1591 Gather Victim Org Information](https://attack.mitre.org/techniques/T1591/)**. Se analizan publicaciones de blog de la empresa, comunicados de prensa sobre su nueva plataforma "Monitoreo ambiental IoT" y ofertas laborales para ingenieros de software. Estas últimas revelan el uso de tecnologías como Docker, Node.js, Angular y, de manera crucial, el protocolo MQTT, lo que proporciona una idea clara de la arquitectura subyacente.

A continuación, se procede a identificar la huella digital de la víctima, utilizando la técnica **[T1590 Gather Victim Host Information](https://attack.mitre.org/techniques/T1590/)**. Mediante herramientas de recolección de subdominios, se descubre la existencia de un portal de acceso público en `dashboard.empresa-victima.com`.

Finalmente, con un objetivo claro, se ejecuta un **[T1595 Active Scanning](https://attack.mitre.org/techniques/T1595/)** sobre el dominio identificado. Un escaneo de puertos revela que, además del puerto `443` (HTTPS) para el dashboard, el servidor tiene expuesto el puerto `1883`. Una simple prueba de conexión con un cliente MQTT genérico confirma que el bróker permite conexiones anónimas, revelando la vulnerabilidad crítica que será el eje del ataque.


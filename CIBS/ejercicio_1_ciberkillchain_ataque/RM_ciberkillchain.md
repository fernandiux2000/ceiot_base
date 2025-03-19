Alumno

Rodrigo Morocho

Sistema víctima

El sistema domótico controla el encendido y apagado de luces, así como la gestión del aire acondicionado (encendido, apagado y regulación de temperatura). Este sistema está compuesto por dispositivos ESP32 y Raspberry Pi, utiliza una base de datos MongoDB y está orquestado mediante Node-RED.

Objetivo

Comprometer el sistema domótico para obtener acceso no autorizado, permitiendo al atacante controlar los dispositivos conectados, recopilar información sensible y potencialmente utilizar la infraestructura para actividades maliciosas adicionales.

Resolución

Reconnaissance

Investigar en foros y comunidades en línea donde los usuarios comparten configuraciones y arquitecturas de sus sistemas. Encontrar publicaciones detalladas que describen implementaciones similares al sistema objetivo, identificando el uso de dispositivos ESP32 y Raspberry Pi, con Node-RED como plataforma de orquestación y MongoDB como base de datos. Utilizar herramientas de escaneo de red para identificar dispositivos IoT expuestos en la red objetivo, descubriendo servicios abiertos y posibles vulnerabilidades.

Weaponization

Con la información recopilada, desarrollar un malware personalizado diseñado para explotar vulnerabilidades específicas de las versiones de firmware de los ESP32 y del sistema operativo de la Raspberry Pi. Este malware permite la ejecución remota de comandos y la instalación de puertas traseras en los dispositivos comprometidos. Además, crear scripts maliciosos que pueden integrarse en los flujos de Node-RED, aprovechando configuraciones deficientes de seguridad, como la falta de autenticación en el panel de control.

Delivery

Envíar correos electrónicos de phishing dirigidos al administrador del sistema, haciéndose pasar por un miembro de la comunidad de usuarios de sistemas domóticos. En el mensaje, sugiere mejoras y proporciona enlaces a actualizaciones de software que, en realidad, contienen el malware desarrollado. Alternativamente, explotar servicios expuestos a Internet sin las medidas de seguridad adecuadas para cargar el malware directamente en los dispositivos.

Exploitation

Una vez que el administrador descarga e instala la supuesta actualización, el malware se activa, explotando vulnerabilidades en el sistema operativo de la Raspberry Pi y en los dispositivos ESP32. Esto permite al atacante ejecutar comandos de forma remota y modificar los flujos de Node-RED para incluir nodos que faciliten el control no autorizado de los dispositivos domóticos.

Installation

El malware instala puertas traseras en los dispositivos comprometidos, asegurando el acceso persistente del atacante. Además, configura túneles seguros para comunicarse con servidores de comando y control (C2), permitiendo la gestión remota continua del sistema comprometido.

Command and Control

Establecer comunicación con las puertas traseras instaladas, permitiendo el control total del sistema domótico. Utiliza los túneles seguros para enviar comandos y recibir información desde y hacia los dispositivos comprometidos, eludiendo posibles medidas de seguridad implementadas en la red.

Actions on Objectives

Con el control del sistema domótico, se pueden realizar diversas acciones maliciosas, como:

Sabotaje: Encender y apagar las luces o modificar la temperatura del aire acondicionado de manera aleatoria, causando molestias a los habitantes y potencialmente dañando los dispositivos.

Extorsión: Amenazar con alterar el funcionamiento del sistema domótico a menos que se pague un rescate.

Acceso a la red interna: Utilizar los dispositivos comprometidos como punto de entrada para atacar otros sistemas en la red doméstica, como computadoras personales o dispositivos de almacenamiento.

Ataques a terceros: Emplear los dispositivos comprometidos como parte de una botnet para lanzar ataques distribuidos de denegación de servicio (DDoS) contra otros objetivos en Internet.
# CiberKillChain - Defensa a sistema de Monitoreo ambiental IoT

## Alumno
* Rodrigo Morocho Roman

## Resolución

### 7- Actions on Objectives
> Para contrarrestar la acción final, se implementan defensas en la lógica de la aplicación: se valida la plausibilidad de los datos (creíbles y consistentes) para detectar anomalías y se requiere la persistencia de una condición antes de disparar una alarma para mitigar el impacto.

#### Medida de Detección: Validación de Entradas (Input Validation)
Basado en la mejor práctica de desarrollo seguro **[CWE-20: Improper Input Validation](https://cwe.mitre.org/data/definitions/20.html)**, se implementa una capa de "validación de sanidad" en el `api_server`. Antes de procesar o guardar cualquier dato proveniente del bróker MQTT, la lógica del backend comprueba si los valores se encuentran dentro de un rango físico y operacionalmente plausible (ej: temperatura entre -20 y 60 °C). Si un valor excede este rango, como el `99` inyectado en el ataque, el sistema lo descarta o lo registra como un "evento anómalo sospechoso" en lugar de tratarlo como una lectura válida, detectando así la manipulación.

#### Medida de Mitigación: Diseño de Sistema Resiliente
Siguiendo principios de **Diseño Resiliente**, detallados en patrones de la industria como el **Patrón de Reintento (Retry Pattern)**, se modifica la lógica de negocio para que sea tolerante a eventos anómalos únicos. El sistema de alarmas deja de reaccionar a una única lectura fuera de umbral y, en su lugar, se requiere que la condición de alarma persista durante un periodo definido (ej: en 3 lecturas consecutivas). Esta medida, respaldada por las guías de resiliencia de aplicaciones de [Paradigma Digital](https://www.paradigmadigital.com/dev/4-patrones-resiliencia-fundamentales/) y [Microsoft](https://learn.microsoft.com/es-es/dotnet/architecture/cloud-native/application-resiliency-patterns), mitiga eficazmente el impacto del ataque de inyección de un solo paquete, ya que un evento aislado y falso no es suficiente para provocar la interrupción del negocio, neutralizando el objetivo del sabotaje.

### 6- Command & Control
> Para neutralizar el canal de Comando y Control, las defensas se centran en asegurar el bróker MQTT, detectando conexiones no autorizadas y mitigando el acceso anónimo mediante la implementación de controles de acceso robustos.

#### Medida de Detección: Auditoría y Monitoreo de Conexiones
Esta medida se basa en el principio de **Registro y Monitoreo de Seguridad**, una de las prácticas de seguridad más importantes **[OWASP - Security Logging and Monitoring Failures](https://owasp.org/Top10/A09_2021-Security_Logging_and_Monitoring_Failures/)**. El objetivo es hacer visible quién se conecta al bróker.

* **Implementación:** Se modifica el archivo `mosquitto.conf` para habilitar el registro detallado de eventos (`log_type all`). Esto generará logs con cada conexión, publicación y suscripción, incluyendo la dirección IP y el ID del cliente. Con recursos limitados, se puede configurar un simple script (`cron job/tarea programada`) que revise estos logs periódicamente en busca de anomalías, como conexiones desde direcciones IP no autorizadas o clientes con IDs desconocidos, y envíe una alerta por correo electrónico.

#### Medida de Mitigación: Implementación de Controles de Acceso
La mitigación más efectiva es eliminar la vulnerabilidad raíz: el acceso anónimo. Esto se logra implementando **Autenticación y Autorización**, dos pilares del control de acceso **[OWASP - Access Control Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Access_Control_Cheat_Sheet.html)**.

* **Implementación:**
    1.  **Autenticación:** Se deshabilita el acceso anónimo (`allow_anonymous false`) en `mosquitto.conf` y se configura un archivo de contraseñas. A cada cliente legítimo (el ESP32 y el `api_server`) se le asigna un usuario y una contraseña únicos.
    2.  **Autorización (ACLs):** Se crea un Archivo de Listas de Control de Acceso (ACL) que define permisos granulares. Se configura para que el usuario del ESP32 **solo** pueda `publicar` en el tópico `sensores/casa`, y el usuario del `api_server` **solo** pueda `suscribirse` a ese mismo tópico.

Esta medida destruye por completo el canal de C2 del atacante. Ya no puede conectarse para enviar comandos, y aunque lograra robar una credencial, las ACLs limitarían drásticamente lo que podría hacer con ella.

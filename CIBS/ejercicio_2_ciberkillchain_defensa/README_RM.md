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
> La defensa se centra en la mitigación proactiva, eliminando por completo el canal de C2 del atacante mediante la implementación de controles de acceso en el bróker MQTT.

#### Medida de Mitigación: Implementación de Controles de Acceso
La medida más eficiente es la mitigación, ya que elimina la causa raíz de la vulnerabilidad. Siguiendo el principio de **Control de Acceso**, se implementa una defensa robusta de la siguiente manera:

1.  **Autenticación:** Se deshabilita el acceso anónimo (`allow_anonymous false`) en `mosquitto.conf` y se exige un usuario y contraseña únicos para cada cliente legítimo (el ESP32 y el `api_server`).
2.  **Autorización (ACLs):** Se definen Listas de Control de Acceso (ACLs) para aplicar el principio de mínimo privilegio. El usuario del ESP32 solo puede `publicar` en el tópico `sensores/casa`, y el `api_server` solo puede `suscribirse` a él.

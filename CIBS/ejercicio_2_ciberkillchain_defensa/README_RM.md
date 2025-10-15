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

### 5- Installation
> Dado que el ataque no requiere instalar malware, la defensa es proactiva y se enfoca en la mitigación, endureciendo el sistema para que, por diseño, sea dificil que un atacante logre persistencia.

#### Medida de Mitigación: Endurecimiento del Contenedor (Sistema de archivos de solo lectura)
La medida es el endurecimiento preventivo del sistema, siguiendo las mejores prácticas de seguridad en contenedores como las definidas en el **CIS Docker Benchmark**.

* **Implementación:** Se modifica el archivo `docker-compose.yml` para añadir la directiva `read_only: true` al servicio del `api_server`. Esto instruye a Docker para que monte el sistema de archivos del contenedor en modo de solo lectura. De esta manera, cualquier intento de un atacante por escribir un archivo (instalar un backdoor, un webshell, etc.) fallará a nivel del sistema operativo. Esta medida mitiga de forma proactiva una amplia gama de ataques que buscan establecer persistencia.

### 4- Exploitation
> Mitigación proactiva, eliminando la capacidad del bróker MQTT de procesar paquetes de origen no verificado, previniendo así la inyección de datos en su origen.

#### Medida de Mitigación: Requerir Autenticación de Clientes
Se logra aplicando el principio de **Control de Acceso por Autenticación** (ver [OWASP - Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)).

* **Implementación:** Se modifica el archivo `mosquitto.conf` para establecer `allow_anonymous false` y se le asocia un archivo de contraseñas. Se obliga a que cada cliente que intente conectarse deba presentar un nombre de usuario y una contraseña válidos.

Cuando el paquete malicioso del atacante llega, el bróker verifica las credenciales. Al no tenerlas, **rechaza la conexión y descarta el paquete**. La explotación falla antes de poder ocurrir, neutralizando el ataque en esta etapa.

### 3- Delivery
> Para impedir la entrega del paquete malicioso, la defensa se centra en la mitigación a nivel de red, implementando una regla de firewall que bloquea el acceso desde cualquier fuente no autorizada.

#### Medida de Mitigación: Firewall perimetral con lista blanca de IPs
La medida es aplicar el principio de **Defensa Perimetral**. En lugar de dejar el puerto del bróker abierto a todo internet, se restringe el acceso a nivel de red.

* **Implementación:** Se configura el firewall de la red en el router de la infraestructura para **denegar por defecto** todo el tráfico entrante al puerto `1883`. A continuación, se crea una **regla de excepción (lista blanca)** que permite la conexión únicamente desde las direcciones IP públicas y conocidas de los dispositivos IoT legítimos.

Esta única regla de firewall asegura que cuando el atacante intente enviar su paquete desde una ubicación no autorizada, la conexión será bloqueada en la capa de red. El paquete nunca llegará al bróker MQTT, haciendo que la entrega del ataque falle por completo. Esta es una medida de seguridad fundamental y de bajo costo.

### 2- Weaponization
> La defensa contra el armado del ataque se centra en la mitigación, implementando un mecanismo de firma digital que garantiza la autenticidad e integridad de cada mensaje, haciendo difícil que un payload fabricado por el atacante sea considerado válido.

#### Medida de Mitigación: Implementación de Firmas digitales en mensajes
La medida es aplicar el principio de **Integridad y Autenticidad de los Datos**. Cada mensaje MQTT estará firmado digitalmente, utilizando un estándar como **JSON Web Signature (JWS)**.

* **Implementación:**
  1.  Se genera un par de claves criptográficas (pública/privada). La **clave privada** se almacena de forma segura en el dispositivo ESP32. La **clave pública** se almacena en el `api_server`.
  2.  El firmware del ESP32 se modifica para que, antes de publicar cada mensaje JSON, lo firme con la clave privada.
  3.  El `api_server` se modifica para que, antes de procesar cualquier mensaje, verifique la firma utilizando la clave pública.

Si la firma es válida, el dato es auténtico y proviene del sensor legítimo. Si un atacante envía su payload JSON malicioso, este carecerá de una firma válida. El `api_server` lo detectará, descartará el mensaje inmediatamente y puede registrar el evento como un intento de falsificación. Esta medida inutiliza por completo el arma del atacante, ya que no puede falsificar la firma sin la clave privada.

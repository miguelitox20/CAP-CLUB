# Guía de demostración y sustentación — CAP / CLUB

**Antes de grabar:** ejecutar `flutter pub get`, `flutter analyze` y `flutter test`; corregir cualquier diagnóstico. Verificar Firebase y reglas en una copia/proyecto de prueba. Probar con administrador verificado y cliente. No mostrar contraseñas ni tokens completos en un video público.

| Criterio | Peso | Evidencia requerida |
|---|---:|---|
| Coherencia | 15% | Explicar que la tienda digitaliza catálogo, carrito y pedidos. |
| Interfaz | 10% | Login, catálogo, búsqueda, filtros, ficha de producto, carrito, pedidos, cuenta; mostrar validaciones. |
| POO / datos | 10% | Abrir Product, Pedido, PedidoItem, CartItem; mostrar crear, leer, editar y eliminar producto. |
| Firebase | 20% | Mostrar documentos creados/actualizados en Firestore; enviar notificación de prueba y recibirla. |
| Autenticación | 10% | Registro, error de credenciales, login, roles y logout. |
| SharedPreferences | 10% | Cerrar/reabrir app con sesión, mostrar Cuenta, explicar reconcileSession y clearSession. |
| GetX | 15% | Mostrar controladores, Obx, RxList, suscripciones y separación de responsabilidades. |
| Entregables | 10% | ZIP, README y video real de esta misma versión. |

## Guion sugerido (5–7 minutos)

1. Presentación: “CAP CLUB es una tienda de gorras con dos roles: cliente y administrador. Resuelve la necesidad de consultar productos y organizar pedidos en un mismo sistema.”
2. Acceder como cliente: mostrar validación de correo y contraseña, catálogo, filtros de marca y ordenamiento. Añadir dos productos; modificar cantidades y observar cómo GetX actualiza el total. Confirmar pedido y consultar su estado.
3. Cerrar/reabrir la aplicación sin cerrar sesión: mostrar que Firebase mantiene la autenticación y SharedPreferences conserva el correo de sesión. Cerrar sesión, volver a entrar: el último correo puede seguir visible, pero el usuario ya no tiene acceso al catálogo hasta autenticarse.
4. Entrar como administrador verificado: crear una gorra de prueba, editar el precio, consultar el catálogo y borrar con confirmación. Cambiar el estado del pedido a enviado. Comprobar el cambio con el cliente y en Firestore.
5. Activar notificaciones: copiar el token y enviar un mensaje de prueba desde Firebase Console. Mostrar el aviso real recibido. Si no funciona, explicar qué falta sin simular el resultado.
6. Mostrar `lib`: modelos, controladores, servicios, vistas y tema. Explicar que Firebase valida sesión y permisos, no SharedPreferences. Cerrar indicando que no existe una pasarela de pago real.

## Lista de verificación (marcar tras probar, no antes)

- [ ] Flutter compila y abre la versión actual en el dispositivo o navegador.
- [ ] Registro, login inválido, login correcto y recuperación de contraseña.
- [ ] Administrador verificado / cliente no puede modificar el catálogo.
- [ ] CRUD de producto y confirmación de eliminación.
- [ ] Búsqueda, filtros, orden, imagen y adaptación a pantalla pequeña.
- [ ] Carrito, cantidades, subtotal, pedido y bloqueo de envíos repetidos.
- [ ] Pedido visible solo para el cliente propietario y administrador; estado actualizado.
- [ ] Persistencia al reiniciar y eliminación de session_email al salir.
- [ ] Reglas Firestore probadas y publicadas en el proyecto autorizado.
- [ ] Recepción de notificación FCM real en primer y/o segundo plano.
- [ ] Si se exige ejecución móvil, Android registrado y probado.
- [ ] Video grabado y README revisado.

## Preguntas frecuentes

- ¿Qué es Singleton? Una única instancia compartida; StorageService usa constructor privado y factory.
- ¿Cómo se implementa CRUD? ProductService usa add, snapshots, update y delete en la colección gorras.
- ¿Cómo funciona GetX? Los controladores exponen valores reactivos; Obx reconstruye las vistas cuando cambian. Los streams de Firestore actualizan las listas.
- ¿Qué hace el token FCM? Identifica una instalación para enviar mensajes. No equivale a una contraseña ni a una sesión.
- ¿Cómo se diferencia el administrador? Correo del proyecto original y verificación de correo; las reglas del servidor deben aplicar la misma condición.
- ¿Qué queda fuera? Pagos reales, notificaciones automáticas por pedidos, despliegue de reglas y pruebas remotas hasta que se ejecuten en tu entorno.


## Momento destacado — CLUB TRACK (versión 3.0)

1. Abre una gorra desde el catálogo en el emulador estrecho. Haz zoom en la foto, marca favorito y cambia cantidad; muestra cómo se recalcula el subtotal.
2. Confirma el pedido y toca Rastrear mi pedido. Presenta el mapa ilustrativo, el estado inicial y los pasos del envío.
3. Desde una sesión separada con administrador verificado, actualiza a preparando, enviado y reparto. Muestra el cambio en Firestore y en la pantalla del cliente sin recargar. Si aparece permiso denegado, comprueba las reglas nuevas y el correo verificado.
4. Explica: «El mapa es una representación animada de la ruta, no un GPS. El estado se obtiene mediante snapshots de Firestore, pasa por OrderService y OrderController y Obx reconstruye la interfaz. La fecha de actualización la genera el servidor».
5. Explica el patrón Singleton con favoritos y sesión, y demuestra la prueba de FCM real desde la consola. No afirmes que existe envío automático, GPS, pagos ni datos de transportadoras.

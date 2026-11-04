# Respuestas: base de datos del gimnasio FitVal

# PARTE A. Pensar antes de escribir SQL

Ejercicio A1

1. No se pueden repetir nunca `id`, `dni` y `email`.
2. La clave primaria es `id`. Las claves alternativas son `dni` y `email` (las dos llevan `UNIQUE`).
3. `plan_id` apunta a la tabla `planes` (a su columna `id`).
4. Usamos un `id` numérico porque:
   - El DNI puede cambiar o estar mal escrito, y si fuera la PK habría que cambiarlo también en todas las tablas que lo usan como clave ajena. El `id` no cambia nunca porque no significa nada.
   - Un número es más corto y más rápido de comparar que un texto de 9 caracteres, y ocupa menos cuando se repite en otras tablas (por ejemplo en `reservas`).
   - Además puede haber socios sin DNI español (un extranjero con NIE o pasaporte), y con un `id` no tenemos ese problema.

Ejercicio A2

| Pareja | Un A, ¿cuántos B? | Un B, ¿cuántos A? | Relación |
|---|---|---|---|
| planes - socios | muchos | uno | 1:N |
| socios - tarjetas | una | uno | 1:1 |
| monitores - clases | muchas | uno | 1:N |
| socios - clases | muchas | muchos | N:M |
| monitores - especialidades | muchas | muchos | N:M |

Ejercicio A3. Monitores y clases

1. Las dos preguntas:
   - Un monitor, ¿cuántas clases da? Muchas.
   - Una clase, ¿cuántos monitores la dan? Uno.

   Es una relación 1:N.

2. La clave ajena va en el lado muchos, que es `clases`. La llamaría `monitor_id` (y apunta a `monitores(id)`).

3. Si la pusiera en el lado equivocado (`clase_id` dentro de `monitores`):

   | id | nombre | email | clase_id |
   |---:|---|---|---|
   | 1 | Carla Navarro | carla@gym.com | 1, 4, 7 |
   | 2 | Javier Ortega | javier@gym.com | 2, 6 |

   Falla porque Carla da varias clases y en una celda solo cabe un número, así que tendría que repetir a Carla en varias filas con su DNI y su email copiados (y entonces el DNI ya no sería `UNIQUE`).

4. Sí, debe ser `NOT NULL`, porque el enunciado dice que cada clase la da un monitor. Una clase sin monitor no tiene sentido.

5. Primero hay que crear `monitores`, porque `clases` apunta a ella y no se puede hacer referencia a una tabla que todavía no existe.

Ejercicio A4

1. Si quitamos el `UNIQUE` de `socio_id`, un mismo socio podría tener varias tarjetas y la relación pasaría a ser 1:N. Por ejemplo, esto se podría guardar sin error:

   | id | codigo | activa | socio_id |
   |---:|---|---|---:|
   | 1 | TJ-0001 | TRUE | 1 |
   | 8 | TJ-0099 | TRUE | 1 |

   Ana tendría dos tarjetas, y el enunciado dice que un socio solo tiene una.

2. - `UNIQUE` en `codigo`: evita que dos tarjetas tengan el mismo código (si no, en el torno no se sabría de quién es la tarjeta).
   - `UNIQUE` en `socio_id`: evita que un socio tenga más de una tarjeta. Es lo que hace que la relación sea 1:1.

3. Ejemplo: empleado - taquilla en una empresa. Un empleado tiene una taquilla y una taquilla es de un empleado. Hay taquillas libres que no son de nadie, pero no hay empleados con dos taquillas. La pondría en `taquillas` como `empleado_id UNIQUE` (que podría ser `NULL` si está libre). Otro ejemplo: coche - matrícula, la FK iría en matrícula porque depende del coche.

Ejercicio A5. Monitores y especialidades

1. Las dos preguntas:
   - Un monitor, ¿cuántas especialidades tiene? Muchas.
   - Una especialidad, ¿cuántos monitores la tienen? Muchos.

   Es una relación N:M.

2. Necesito tres tablas: `monitores`, `especialidades` y la tabla intermedia `monitor_especialidades`.

3. Columnas:

   - `monitores`: `id` (PK), `dni` (UNIQUE), `nombre`, `email` (UNIQUE)
   - `especialidades`: `id` (PK), `nombre` (UNIQUE)
   - `monitor_especialidades`: `id` (PK), `monitor_id` (FK a monitores), `especialidad_id` (FK a especialidades), y `UNIQUE (monitor_id, especialidad_id)`

4. El `UNIQUE (monitor_id, especialidad_id)` evita que se guarde dos veces la misma pareja, por ejemplo que Carla tenga "Fuerza" repetida. Carla puede tener muchas especialidades y "Fuerza" la pueden tener muchos monitores, pero la pareja Carla-Fuerza solo puede estar una vez.

5. En común: las dos son tablas intermedias de una relación N:M, tienen dos claves ajenas y un `UNIQUE` sobre la pareja. La diferencia es que `reservas` guarda un dato propio de la relación (`fecha_reserva`) y `monitor_especialidades` solo guarda la pareja, no tiene datos extra.

Ejercicio A6

| # | Caso | Preguntas | Relación | ¿Dónde va la FK? |
|---|---|---|---|---|
| 1 | País - ciudad | Un país tiene muchas ciudades; una ciudad está en un país | 1:N | En `ciudades` (`pais_id`) |
| 2 | Persona - pasaporte | Una persona tiene un pasaporte (en vigor); un pasaporte es de una persona | 1:1 | En `pasaportes` (`persona_id UNIQUE NOT NULL`), porque el pasaporte depende de la persona y hay personas sin pasaporte |
| 3 | Alumno - asignatura | Un alumno cursa muchas asignaturas; una asignatura la cursan muchos alumnos | N:M | Tabla intermedia `matriculas` (`alumno_id`, `asignatura_id`, y por ejemplo `nota` o `curso`) |
| 4 | Cliente - pedido | Un cliente hace muchos pedidos; un pedido es de un cliente | 1:N | En `pedidos` (`cliente_id`) |
| 5 | Película - actor | Una película tiene muchos actores; un actor sale en muchas películas | N:M | Tabla intermedia `repartos` (`pelicula_id`, `actor_id`, `personaje`). El nombre del personaje va ahí porque no es del actor (hace muchos personajes) ni de la película (tiene muchos personajes), es de ese actor en esa película |
| 6 | Autor - libro | Un autor escribe muchos libros; un libro depende | 1:N o N:M | Depende de si un libro puede tener varios autores. Si solo tiene uno es 1:N y `autor_id` va en `libros`. Si puede tener varios (lo normal) es N:M con tabla intermedia `libro_autores` |
| 7 | Furniro: usuario - pedido | Un usuario hace muchos pedidos; un pedido es de un usuario | 1:N | En `orders` (`user_id`) |
| 8 | Furniro: pedido - producto | Un pedido tiene muchos productos; un producto está en muchos pedidos | N:M | Tabla intermedia `order_items` (`order_id`, `product_id`) |

En la tabla intermedia de Furniro (`order_items`) guardaría:

- `cantidad`: cuántas unidades de ese producto hay en ese pedido.
- `precio_unitario`: el precio que tenía el producto en el momento de comprar. Si luego el producto cambia de precio, el pedido antiguo no debe cambiar.
- (opcional) `descuento` aplicado a esa línea.
- `UNIQUE (order_id, product_id)` para no repetir el mismo producto dos veces en un pedido (se sube la cantidad).


# PARTE B. Construirlo en PostgreSQL

El SQL completo está en `gimnasio.sql`.

Ejercicio B3. Romper la base de datos a propósito

Ejercicio B3.1 Un socio con un plan que no existe

Pensaba que iba a fallar porque el plan 99 no existe y `plan_id` es clave ajena hacia `planes`. Y falla:

```
ERROR:  insert or update on table "socios" violates foreign key constraint "socios_plan_id_fkey"
DETAIL:  Key (plan_id)=(99) is not present in table "planes".
```

Quiere decir que al insertar en "socios" se viola la clave ajena "socios_plan_id_fkey", porque (plan_id)=(99) no está en "planes". Lo impide la clave ajena `plan_id`, que apunta a `planes(id)`.

Ejercicio B3.2 Un socio con el email de Ana

Tenía que fallar porque `email` es `UNIQUE` y `ana@gym.com` ya está.

```
ERROR:  duplicate key value violates unique constraint "socios_email_key"
DETAIL:  Key (email)=(ana@gym.com) already exists.
```

Dice que hay un valor duplicado que viola la restricción única "socios_email_key", el email ana@gym.com ya existe. Lo impide la clave alternativa `email UNIQUE`.

Ejercicio B3.3 Una segunda tarjeta para Ana

Falla porque `socio_id` en `tarjetas` es `UNIQUE` y Ana (id 1) ya tiene la TJ-0001. El código TJ-0099 es nuevo, así que el problema no es ese.

```
ERROR:  duplicate key value violates unique constraint "tarjetas_socio_id_key"
DETAIL:  Key (socio_id)=(1) already exists.
```

Valor duplicado en la restricción única "tarjetas_socio_id_key", el socio_id 1 ya existe. Lo impide el `UNIQUE` de la clave ajena `socio_id`, que es justo lo que hace que la relación sea 1:1.

Ejercicio B3.4 Ana reserva otra vez el Spinning del lunes

La pareja (socio 1, clase 1) ya está en `reservas` y hay un `UNIQUE (socio_id, clase_id)`, así que tiene que fallar aunque la fecha sea distinta.

```
ERROR:  duplicate key value violates unique constraint "reservas_socio_id_clase_id_key"
DETAIL:  Key (socio_id, clase_id)=(1, 1) already exists.
```

Valor duplicado en "reservas_socio_id_clase_id_key", la pareja (1, 1) ya existe. Lo impide el `UNIQUE (socio_id, clase_id)` de la tabla intermedia.

Ejercicio B3.5 Una reserva para una clase que no existe

No hay clase 50 y `clase_id` es clave ajena a `clases`, así que falla.

```
ERROR:  insert or update on table "reservas" violates foreign key constraint "reservas_clase_id_fkey"
DETAIL:  Key (clase_id)=(50) is not present in table "clases".
```

Al insertar en "reservas" se viola la clave ajena "reservas_clase_id_fkey" porque la clase 50 no está en "clases". Lo impide la clave ajena `clase_id`, que apunta a `clases(id)`.

Ejercicio B3.6 Borrar el plan Básico

Este pensaba que fallaría porque hay socios con el plan Básico (Luis, Pablo y Diego) y se quedarían apuntando a un plan que no existe.

```
ERROR:  update or delete on table "planes" violates foreign key constraint "socios_plan_id_fkey" on table "socios"
DETAIL:  Key (id)=(1) is still referenced from table "socios".
```

Borrar en "planes" viola la clave ajena "socios_plan_id_fkey" de "socios", porque el id 1 todavía se usa desde "socios". Lo impide la clave ajena `socios.plan_id`, que en este caso protege desde el otro lado: no te deja borrar el plan al que apuntan.

Ejercicio B3.7 Borrar el plan Mañanas

Este sí funciona porque ningún socio tiene el plan Mañanas. Sale `DELETE 1`, sin error.

Luego lo volví a meter con `INSERT INTO planes (nombre, precio_mensual) VALUES ('Mañanas', 19.90);`. Ahora tiene el id 5 y no el 4, porque el `IDENTITY` no reutiliza números.

Ejercicio B3.8 ¿Por qué B3.6 falla y B3.7 funciona?

Lo que importa no es que sea un plan, sino si alguien apunta a él. El Básico tiene socios con `plan_id` = 1, así que si lo borro esos socios se quedan apuntando a algo que no existe y la clave ajena no lo deja. El Mañanas no lo tiene nadie, nadie se queda huérfano y se puede borrar.

Ejercicio B4.11 ¿Ana sale tres veces en la consulta 6?

No es un error. La consulta empieza en `reservas` y saca una fila por cada reserva. Ana tiene tres reservas (Spinning, Pilates y Crossfit), así que sale tres veces, una con cada clase. Es lo que tiene que pasar en una relación N:M: el socio se repite en la tabla intermedia tantas veces como clases ha reservado. Si quisiera ver a cada socio una sola vez tendría que usar `DISTINCT` o `GROUP BY`.

Ejercicio B5.6 Borrar a Pablo

Al ejecutar `DELETE FROM socios WHERE email = 'pablo@gym.com';` sale:

```
ERROR:  update or delete on table "socios" violates foreign key constraint "tarjetas_socio_id_fkey" on table "tarjetas"
DETAIL:  Key (id)=(6) is still referenced from table "tarjetas".
```

(Borrar en "socios" viola la clave ajena "tarjetas_socio_id_fkey" de "tarjetas": el id 6 todavía está referenciado desde "tarjetas".)

Pablo tiene una tarjeta (TJ-0006) y una reserva (el Spinning del martes, clase 4) que apuntan a él. El error solo menciona la tarjeta porque es la primera que comprueba, pero la reserva también lo bloquearía.

Orden en el que lo he borrado:

1. Sus reservas (`DELETE FROM reservas WHERE socio_id = ...`).
2. Su tarjeta (`DELETE FROM tarjetas WHERE socio_id = ...`).
3. Por último, el socio.

Hay que borrar primero las filas que tienen la clave ajena (las que apuntan) y al final la fila a la que apuntan. Es el mismo orden que el script de reinicio: primero los "hijos", luego el "padre". (Reservas y tarjeta se pueden borrar en cualquier orden entre ellas, lo importante es que vayan antes que el socio.)

Ejercicio B6. Explícalo con tus palabras

1. PK vs `UNIQUE`: las dos impiden repetir valores, pero la PK es la que se elige como identificador principal de la fila (solo hay una por tabla, nunca es `NULL` y es la que usan las claves ajenas para apuntar). Una `UNIQUE` es otra columna que también identifica, como el DNI o el email, y puede haber varias.

2. ¿Por qué una FK puede repetirse? Porque varias filas pueden apuntar a la misma fila de la otra tabla. Muchos socios tienen el mismo plan, así que el `plan_id` 2 aparece varias veces.

3. ¿Dónde va la FK en una 1:N? En el lado muchos. Si la pusiera en el lado uno, tendría que meter varios valores en una celda (por ejemplo varios socios en un plan), y en una celda solo cabe un valor.

4. ¿Qué convierte una 1:N en 1:1? Poner `UNIQUE` en la clave ajena. Así cada fila de la otra tabla solo puede aparecer una vez.

5. ¿Por qué N:M necesita tabla intermedia? Porque los dos lados son "muchos", así que en cualquiera de las dos tablas tendría que meter varios valores en una celda. La tabla intermedia guarda una fila por cada pareja y convierte la N:M en dos 1:N.

6. ¿Por qué `fecha_reserva` está en `reservas`? Porque no es un dato del socio (que tiene muchas reservas con fechas distintas) ni de la clase (que la reservan muchos socios en días distintos). Es un dato de esa reserva concreta, de la pareja socio-clase.




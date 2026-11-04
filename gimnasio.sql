-- =========================================================
-- Gimnasio FitVal
-- Base de datos: gimnasio
-- =========================================================

-- Script de reinicio (por si hay que empezar de cero)
DROP TABLE IF EXISTS pagos;  -- tabla del reto opcional
DROP TABLE IF EXISTS monitor_especialidades;
DROP TABLE IF EXISTS especialidades;
DROP TABLE IF EXISTS reservas;
DROP TABLE IF EXISTS clases;
DROP TABLE IF EXISTS monitores;
DROP TABLE IF EXISTS tarjetas;
DROP TABLE IF EXISTS socios;
DROP TABLE IF EXISTS planes;


-- =========================================================
-- Ejercicio B1 - Crear las tablas
-- =========================================================

-- Ejercicio B1.1 - planes, socios y tarjetas (resueltas en el enunciado)
CREATE TABLE planes (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    precio_mensual NUMERIC(6,2) NOT NULL CHECK (precio_mensual >= 0)
);

CREATE TABLE socios (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dni VARCHAR(9) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    fecha_alta DATE NOT NULL,
    plan_id INTEGER NOT NULL REFERENCES planes(id)
);

CREATE TABLE tarjetas (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    activa BOOLEAN NOT NULL,
    socio_id INTEGER UNIQUE NOT NULL REFERENCES socios(id)
);

-- Ejercicio B1.2 - monitores y clases
-- Un monitor da muchas clases y una clase la da un monitor (1:N),
-- así que monitor_id va en clases.
CREATE TABLE monitores (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dni VARCHAR(9) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL
);

CREATE TABLE clases (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    actividad VARCHAR(50) NOT NULL,
    sala VARCHAR(20) NOT NULL,
    fecha_hora TIMESTAMP NOT NULL,
    plazas INTEGER NOT NULL CHECK (plazas > 0),
    monitor_id INTEGER NOT NULL REFERENCES monitores(id)
);

-- Ejercicio B1.3 - reservas (necesita que existan socios y clases)
CREATE TABLE reservas (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    socio_id INTEGER NOT NULL REFERENCES socios(id),
    clase_id INTEGER NOT NULL REFERENCES clases(id),
    fecha_reserva DATE NOT NULL,
    UNIQUE (socio_id, clase_id)
);

-- Ejercicio B1.4 - especialidades y monitor_especialidades (N:M)
CREATE TABLE especialidades (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE monitor_especialidades (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    monitor_id INTEGER NOT NULL REFERENCES monitores(id),
    especialidad_id INTEGER NOT NULL REFERENCES especialidades(id),
    UNIQUE (monitor_id, especialidad_id)
);

-- Ejercicio B1.5 - Comprobar la estructura (en psql)
-- \dt
-- \d clases
-- \d reservas


-- =========================================================
-- Ejercicio B2 - Datos de prueba
-- =========================================================

INSERT INTO planes (nombre, precio_mensual)
VALUES
    ('Básico', 29.90),
    ('Completo', 44.90),
    ('Estudiante', 24.90),
    ('Mañanas', 19.90);

INSERT INTO socios (dni, nombre, email, fecha_alta, plan_id)
VALUES
    ('11111111A', 'Ana Pérez', 'ana@gym.com', '2026-01-10', 2),
    ('22222222B', 'Luis García', 'luis@gym.com', '2026-02-03', 1),
    ('33333333C', 'Marta López', 'marta@gym.com', '2026-03-15', 3),
    ('44444444D', 'Hugo Sanz', 'hugo@gym.com', '2026-03-20', 2),
    ('55555555E', 'Lucía Ruiz', 'lucia@gym.com', '2026-05-02', 3),
    ('66666666F', 'Pablo Martín', 'pablo@gym.com', '2026-06-11', 1),
    ('77777777G', 'Sara Gil', 'sara@gym.com', '2026-09-01', 2),
    ('88888888H', 'Diego Vidal', 'diego@gym.com', '2026-10-01', 1);

-- Diego (8) todavía no tiene tarjeta
INSERT INTO tarjetas (codigo, activa, socio_id)
VALUES
    ('TJ-0001', TRUE, 1),
    ('TJ-0002', TRUE, 2),
    ('TJ-0003', TRUE, 3),
    ('TJ-0004', FALSE, 4),
    ('TJ-0005', TRUE, 5),
    ('TJ-0006', TRUE, 6),
    ('TJ-0007', TRUE, 7);

INSERT INTO monitores (dni, nombre, email)
VALUES
    ('90000001J', 'Carla Navarro', 'carla@gym.com'),
    ('90000002K', 'Javier Ortega', 'javier@gym.com'),
    ('90000003L', 'Elena Romero', 'elena@gym.com'),
    ('90000004M', 'Rubén Castro', 'ruben@gym.com');

-- Rubén (4) es nuevo y todavía no da ninguna clase
INSERT INTO clases (actividad, sala, fecha_hora, plazas, monitor_id)
VALUES
    ('Spinning', 'Sala 1', '2026-11-02 09:00', 12, 1),
    ('Yoga', 'Sala 2', '2026-11-02 18:00', 10, 2),
    ('Pilates', 'Sala 2', '2026-11-03 10:00', 8, 3),
    ('Spinning', 'Sala 1', '2026-11-03 19:00', 12, 1),
    ('Zumba', 'Sala 3', '2026-11-04 18:30', 20, 3),
    ('Yoga', 'Sala 2', '2026-11-05 09:30', 10, 2),
    ('Crossfit', 'Sala 3', '2026-11-05 20:00', 3, 1);

-- La clase 6 (Yoga del jueves) no tiene reservas
INSERT INTO reservas (socio_id, clase_id, fecha_reserva)
VALUES
    (1, 1, '2026-10-28'),
    (1, 3, '2026-10-28'),
    (1, 7, '2026-10-29'),
    (2, 1, '2026-10-29'),
    (2, 2, '2026-10-29'),
    (3, 2, '2026-10-30'),
    (3, 5, '2026-10-30'),
    (4, 1, '2026-10-30'),
    (4, 7, '2026-10-31'),
    (5, 3, '2026-10-31'),
    (5, 5, '2026-10-31'),
    (6, 4, '2026-11-01'),
    (7, 5, '2026-11-01'),
    (7, 7, '2026-11-01');

INSERT INTO especialidades (nombre)
VALUES
    ('Ciclo indoor'),
    ('Yoga'),
    ('Pilates'),
    ('Baile'),
    ('Fuerza');

INSERT INTO monitor_especialidades (monitor_id, especialidad_id)
VALUES
    (1, 1),
    (1, 5),
    (2, 2),
    (2, 3),
    (3, 3),
    (3, 4),
    (4, 5);

-- Comprobación
SELECT * FROM planes;
SELECT * FROM socios;
SELECT * FROM tarjetas;
SELECT * FROM monitores;
SELECT * FROM clases;
SELECT * FROM reservas;
SELECT * FROM especialidades;
SELECT * FROM monitor_especialidades;


-- =========================================================
-- Ejercicio B3 - Romper la base de datos a propósito
-- (las predicciones y los errores están en respuestas.md)
-- =========================================================

-- Ejercicio B3.1 - Un socio con un plan que no existe
INSERT INTO socios (dni, nombre, email, fecha_alta, plan_id)
VALUES ('99999999Z', 'Nora Prueba', 'nora@gym.com', '2026-10-27', 99);

-- Ejercicio B3.2 - Un socio con el email de Ana
INSERT INTO socios (dni, nombre, email, fecha_alta, plan_id)
VALUES ('99999999Z', 'Nora Prueba', 'ana@gym.com', '2026-10-27', 1);

-- Ejercicio B3.3 - Una segunda tarjeta para Ana
INSERT INTO tarjetas (codigo, activa, socio_id)
VALUES ('TJ-0099', TRUE, 1);

-- Ejercicio B3.4 - Ana reserva otra vez el Spinning del lunes
INSERT INTO reservas (socio_id, clase_id, fecha_reserva)
VALUES (1, 1, '2026-10-30');

-- Ejercicio B3.5 - Una reserva para una clase que no existe
INSERT INTO reservas (socio_id, clase_id, fecha_reserva)
VALUES (2, 50, '2026-10-30');

-- Ejercicio B3.6 - Borrar el plan Básico
DELETE FROM planes WHERE nombre = 'Básico';

-- Ejercicio B3.7 - Borrar el plan Mañanas
DELETE FROM planes WHERE nombre = 'Mañanas';

-- Volvemos a insertar el plan Mañanas (lo necesitamos en B4.5)
INSERT INTO planes (nombre, precio_mensual) VALUES ('Mañanas', 19.90);


-- =========================================================
-- Ejercicio B4 - Consultas
-- =========================================================

-- Ejercicio B4.1 - Socio, plan y precio, ordenado por socio
SELECT s.nombre AS socio, p.nombre AS plan, p.precio_mensual
FROM socios s
INNER JOIN planes p ON s.plan_id = p.id
ORDER BY s.nombre;

-- Ejercicio B4.2 - Clases con su monitor, ordenadas por fecha
SELECT c.actividad, c.fecha_hora, c.sala, m.nombre AS monitor
FROM clases c
INNER JOIN monitores m ON c.monitor_id = m.id
ORDER BY c.fecha_hora;

-- Ejercicio B4.3 - Todos los socios con su tarjeta (también sin tarjeta)
SELECT s.nombre AS socio, t.codigo AS tarjeta
FROM socios s
LEFT JOIN tarjetas t ON t.socio_id = s.id
ORDER BY s.nombre;

-- Ejercicio B4.4 - Solo los socios sin tarjeta
SELECT s.nombre AS socio
FROM socios s
LEFT JOIN tarjetas t ON t.socio_id = s.id
WHERE t.id IS NULL;

-- Ejercicio B4.5 - Número de socios por plan (también los planes con 0)
SELECT p.nombre AS plan, COUNT(s.id) AS num_socios
FROM planes p
LEFT JOIN socios s ON s.plan_id = p.id
GROUP BY p.id, p.nombre
ORDER BY p.nombre;

-- Ejercicio B4.6 - Reservas: socio, actividad y fecha de la clase
SELECT s.nombre AS socio, c.actividad, c.fecha_hora
FROM reservas r
INNER JOIN socios s ON r.socio_id = s.id
INNER JOIN clases c ON r.clase_id = c.id
ORDER BY s.nombre, c.fecha_hora;

-- Ejercicio B4.7 - Socios apuntados a la clase 1
SELECT s.nombre AS socio
FROM reservas r
INNER JOIN socios s ON r.socio_id = s.id
WHERE r.clase_id = 1
ORDER BY s.nombre;

-- Ejercicio B4.8 - Cada clase con su número de reservas (también sin reservas)
SELECT c.actividad, c.fecha_hora, c.plazas, COUNT(r.id) AS num_reservas
FROM clases c
LEFT JOIN reservas r ON r.clase_id = c.id
GROUP BY c.id, c.actividad, c.fecha_hora, c.plazas
ORDER BY c.fecha_hora;

-- Ejercicio B4.9 - Monitores que no dan ninguna clase
SELECT m.nombre AS monitor
FROM monitores m
LEFT JOIN clases c ON c.monitor_id = m.id
WHERE c.id IS NULL;

-- Ejercicio B4.10 - Cada monitor con sus especialidades
SELECT m.nombre AS monitor, e.nombre AS especialidad
FROM monitor_especialidades me
INNER JOIN monitores m ON me.monitor_id = m.id
INNER JOIN especialidades e ON me.especialidad_id = e.id
ORDER BY m.nombre, e.nombre;


-- =========================================================
-- Ejercicio B5 - Modificar y borrar
-- =========================================================

-- Ejercicio B5.1 - Luis se cambia al plan Completo
SELECT * FROM socios WHERE email = 'luis@gym.com';

UPDATE socios
SET plan_id = (SELECT id FROM planes WHERE nombre = 'Completo')
WHERE email = 'luis@gym.com';

-- Ejercicio B5.2 - Activar la tarjeta de Hugo
SELECT * FROM tarjetas WHERE codigo = 'TJ-0004';

UPDATE tarjetas
SET activa = TRUE
WHERE codigo = 'TJ-0004';

-- Ejercicio B5.3 - Tarjeta TJ-0008 para Diego
SELECT * FROM socios WHERE email = 'diego@gym.com';

INSERT INTO tarjetas (codigo, activa, socio_id)
VALUES ('TJ-0008', TRUE, (SELECT id FROM socios WHERE email = 'diego@gym.com'));

-- Ejercicio B5.4 - Diego reserva el Yoga del jueves (clase 6)
INSERT INTO reservas (socio_id, clase_id, fecha_reserva)
VALUES ((SELECT id FROM socios WHERE email = 'diego@gym.com'), 6, '2026-11-02');

-- Ejercicio B5.5 - Luis cancela su reserva de la clase 2
SELECT r.*
FROM reservas r
WHERE r.socio_id = (SELECT id FROM socios WHERE email = 'luis@gym.com')
  AND r.clase_id = 2;

DELETE FROM reservas
WHERE socio_id = (SELECT id FROM socios WHERE email = 'luis@gym.com')
  AND clase_id = 2;

-- Ejercicio B5.6 - Pablo se da de baja
-- Primer intento: falla porque Pablo tiene tarjeta y reservas que apuntan a él
DELETE FROM socios WHERE email = 'pablo@gym.com';

-- Forma correcta: primero borro lo que apunta a Pablo y al final a Pablo
SELECT * FROM reservas WHERE socio_id = (SELECT id FROM socios WHERE email = 'pablo@gym.com');
SELECT * FROM tarjetas WHERE socio_id = (SELECT id FROM socios WHERE email = 'pablo@gym.com');

DELETE FROM reservas
WHERE socio_id = (SELECT id FROM socios WHERE email = 'pablo@gym.com');

DELETE FROM tarjetas
WHERE socio_id = (SELECT id FROM socios WHERE email = 'pablo@gym.com');

DELETE FROM socios WHERE email = 'pablo@gym.com';


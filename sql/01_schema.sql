# =====================================================================
# 01_schema.sql — Esquema de la base udg_analisis (modelo relacional)
# ATENCION: borra y recrea la base 'udg_analisis' si ya existe.
# =====================================================================


# Creamos una database para este analisis

# Reset para que no se duplique todo
DROP DATABASE IF EXISTS udg_analisis;

CREATE DATABASE IF NOT EXISTS udg_analisis;
# Usar la DB
USE udg_analisis;
# Verificar que es la DB correcta

# Creamos las tablas universitarias
	# Centro Universitario
CREATE TABLE IF NOT EXISTS centro_universitario(
	id_centro INT AUTO_INCREMENT PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL,
    tipo ENUM("metropolitano", "regional") NOT NULL
);

	# Ciclo Escolar
CREATE TABLE IF NOT EXISTS ciclo_escolar(
	id_ciclo INT AUTO_INCREMENT PRIMARY KEY,
	año YEAR NOT NULL,
    periodo ENUM('A', 'B') NOT NULL,
    UNIQUE (año, periodo)
);

	# Carrera
CREATE TABLE IF NOT EXISTS carrera (
    id_carrera        INT AUTO_INCREMENT PRIMARY KEY,
    nombre            VARCHAR(150) NOT NULL,
    area_conocimiento VARCHAR(100),
    id_centro         INT NOT NULL,
    es_virtual        BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_centro) REFERENCES centro_universitario(id_centro),
    UNIQUE (id_centro, nombre)
);


# Tablas de hechos

# Admision
CREATE TABLE IF NOT EXISTS admision (
    id_admision     INT AUTO_INCREMENT PRIMARY KEY,
    id_ciclo        INT NOT NULL,
    id_carrera      INT NOT NULL,
    aspirantes      INT NOT NULL,
    cupo            INT NOT NULL,
    admitidos       INT NOT NULL,
    puntaje_minimo  DECIMAL(7,4),
    FOREIGN KEY (id_ciclo)   REFERENCES ciclo_escolar(id_ciclo),
    FOREIGN KEY (id_carrera) REFERENCES carrera(id_carrera),
    UNIQUE (id_ciclo, id_carrera)
);

# Desercion
CREATE TABLE IF NOT EXISTS desercion (
    id_desercion        INT AUTO_INCREMENT PRIMARY KEY,
    id_ciclo            INT NOT NULL,
    id_carrera          INT NOT NULL,
    matricula_inicial   INT NOT NULL,
    desertores          INT NOT NULL,
    FOREIGN KEY (id_ciclo)   REFERENCES ciclo_escolar(id_ciclo),
    FOREIGN KEY (id_carrera) REFERENCES carrera(id_carrera),
    UNIQUE (id_ciclo, id_carrera)
);

# Egreso
CREATE TABLE IF NOT EXISTS egreso (
    id_egreso               INT AUTO_INCREMENT PRIMARY KEY,
    id_ciclo                INT NOT NULL,
    id_carrera              INT NOT NULL,
    generacion              YEAR NOT NULL,
    egresados               INT NOT NULL,
    FOREIGN KEY (id_ciclo)   REFERENCES ciclo_escolar(id_ciclo),
    FOREIGN KEY (id_carrera) REFERENCES carrera(id_carrera),
    UNIQUE (id_ciclo, id_carrera)
);

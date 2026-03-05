CREATE DATABASE edullinas;
USE edullinas;

CREATE TABLE roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombres VARCHAR(250) NOT NULL,
    apellidos VARCHAR(250) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    fecha_nacimiento DATE NOT NULL,
    clave VARCHAR(255) NOT NULL,
    id_rol INT NOT NULL,
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
);

INSERT INTO roles (nombre) values ('admin')
INSERT INTO roles (nombre) values ('estudiante')
INSERT INTO roles (nombre) values ('profesor')



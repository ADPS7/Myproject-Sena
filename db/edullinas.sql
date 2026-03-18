CREATE DATABASE edullinas;
USE edullinas;

CREATE TABLE Roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    correo VARCHAR(50) NOT NULL UNIQUE,
    fecha_nacimiento DATE NOT NULL,
    clave VARCHAR(200) NOT NULL,
    id_rol INT NOT NULL,
    FOREIGN KEY (id_rol) REFERENCES Roles(id_rol)
);

CREATE TABLE Cursos (
    id_curso INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50)
);

CREATE TABLE Alumnos (
    id_alumno INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_curso INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios (id_usuario),
    FOREIGN KEY (id_curso) REFERENCES Cursos (id_curso)
);

CREATE TABLE Modulos (
    id_modulo INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin Date NOT NULL,
    id_curso INT,
    FOREIGN KEY (id_curso) REFERENCES Cursos(id_curso)
);

CREATE TABLE Asistencia (
    id_asistencia INT PRIMARY KEY AUTO_INCREMENT,
    fecha Date NOT NULL,
    asistio ENUM('SI','NO') NOT NULL,
    id_usuario INT NOT NULL,
    id_modulo INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_modulo) REFERENCES Modulos(id_modulo)
);

CREATE TABLE CursosModulos (
    id_cursos_modulos INT PRIMARY KEY AUTO_INCREMENT,
    id_curso INT NOT NULL,
    id_modulo INT NOT NULL,
    FOREIGN KEY (id_curso) REFERENCES Cursos (id_curso),
    FOREIGN KEY (id_modulo) REFERENCES Modulos (id_modulo)
);

CREATE TABLE Notas (
    id_nota INT PRIMARY KEY AUTO_INCREMENT,
    nota DECIMAL(3,2) NOT NULL,
    id_modulo INT NOT NULL,
    id_usuario INT NOT NULL,
    FOREIGN KEY (id_modulo) REFERENCES Modulos (id_modulo),
    FOREIGN KEY (id_usuario) REFERENCES Usuarios (id_usuario)
);

CREATE TABLE NotaFinal(
    id_nota_final INT PRIMARY KEY AUTO_INCREMENT,
    nota_final DECIMAL(3,2) NOT NULL,
    id_alumno INT NOT NULL,
    id_nota INT NOT NULL,
    FOREIGN KEY (id_alumno) REFERENCES Alumnos(id_alumno),
    FOREIGN KEY (id_nota) REFERENCES Notas(id_nota)
);

CREATE TABLE Profesor(
    id_profesor INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_asistencia INT NOT NULL,
    id_nota INT NOT NULL,
    id_modulo INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_asistencia) REFERENCES Asistencia(id_asistencia),
    FOREIGN KEY (id_nota) REFERENCES Notas(id_nota),
    FOREIGN KEY (id_modulo) REFERENCES Modulos(id_modulo)
);

INSERT INTO Roles (nombre) values ('admin');
INSERT INTO Roles (nombre) values ('estudiante');
INSERT INTO Roles (nombre) values ('profesor');


/* INSERT INTO Cursos (nombre) VALUES ('Desarrollo de Aplicaciones Móviles'); */

/* INSERT INTO Modulos (nombre, fecha_inicio, fecha_fin, id_curso) VALUES ('Flutter Básico', '2026-02-01', '2026-03-15', 1),('Firebase y Backend', '2026-03-20', '2026-04-30', 1),('UI/UX Avanzado', '2026-05-01', '2026-06-15', 1); */

/* INSERT INTO Asistencia (fecha, asistio, id_usuario, id_modulo) VALUES('2026-02-05', 'SI', 1, 1),('2026-02-12', 'SI', 1, 1),('2026-02-19', 'NO', 1, 1),('2026-03-25', 'SI', 1, 2),('2026-04-01', 'SI', 1, 2),('2026-05-10', 'SI', 1, 3); */
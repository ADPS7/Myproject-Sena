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
    FOREIGN KEY (id_curso) REFERENCES Cursos (id_curso),
    UNIQUE(id_usuario)
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
    id_curso INT NOT NULL,
    FOREIGN KEY (id_curso) REFERENCES Cursos(id_curso),
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);

INSERT INTO Roles (nombre) values ('admin');
INSERT INTO Roles (nombre) values ('estudiante');
INSERT INTO Roles (nombre) values ('profesor');

INSERT INTO Usuarios (nombres, apellidos, correo, fecha_nacimiento, clave, id_rol) 
VALUES ('Andrés', 'Admin', 'admin@edullinas.com', '1990-01-01', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 1);

INSERT INTO Usuarios (nombres, apellidos, correo, fecha_nacimiento, clave, id_rol) 
VALUES ('Laura', 'Estudiante', 'estudiante@edullinas.com', '2005-05-20', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2);

INSERT INTO Usuarios (nombres, apellidos, correo, fecha_nacimiento, clave, id_rol) 
VALUES ('Roberto', 'Profesor', 'profesor@edullinas.com', '1980-11-30', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 3);

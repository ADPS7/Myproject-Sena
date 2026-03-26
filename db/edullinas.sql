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


INSERT INTO Cursos (nombre) VALUES ('Desarrollo de Aplicaciones Móviles');

INSERT INTO Modulos (nombre, fecha_inicio, fecha_fin, id_curso) VALUES ('Flutter Básico', '2026-02-01', '2026-03-15', 1),('Firebase y Backend', '2026-03-20', '2026-04-30', 1),('UI/UX Avanzado', '2026-05-01', '2026-06-15', 1);

INSERT INTO Asistencia (fecha, asistio, id_usuario, id_modulo) VALUES('2026-02-05', 'SI', 2, 1),('2026-02-12', 'SI', 2, 1),('2026-02-19', 'NO', 2, 1),('2026-03-25', 'SI', 2, 2),('2026-04-01', 'SI', 2, 2),('2026-05-10', 'SI', 2, 3);

INSERT INTO Cursos (nombre) VALUES ('Backend con Python y Flask');

INSERT INTO Profesor (id_usuario, id_curso) VALUES (3, 1);

INSERT INTO Modulos (nombre, fecha_inicio, fecha_fin, id_curso) VALUES ('Introducción a Flask', '2026-06-01', '2026-07-15', 2);

INSERT INTO Usuarios (nombres, apellidos, correo, fecha_nacimiento, clave, id_rol) VALUES
('Pedro', 'Hernández', 'pedro.h@email.com', '1997-03-10', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Clara', 'Ruiz', 'clara.r@email.com', '2003-09-12', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Miguel', 'Castro', 'miguel.c@email.com', '2000-11-11', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Isabel', 'Morales', 'isabel.m@email.com', '2001-05-05', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Jorge', 'Ortiz', 'jorge.o@email.com', '1999-02-28', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Marta', 'Jiménez', 'marta.j@email.com', '2002-12-01', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Ricardo', 'Álvarez', 'ricardo.a@email.com', '2000-08-14', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Valentina', 'Rojas', 'valentina.r@email.com', '2001-10-20', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Hugo', 'Mendoza', 'hugo.m@email.com', '1998-04-04', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Camila', 'Vargas', 'camila.v@email.com', '2002-07-07', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2);

INSERT INTO Usuarios (nombres, apellidos, correo, fecha_nacimiento, clave, id_rol) VALUES
('Gabriel', 'Soto', 'gabriel.s@email.com', '2000-01-01', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Sara', 'Vega', 'sara.v@email.com', '2001-03-03', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Felipe', 'Navarro', 'felipe.n@email.com', '1999-05-05', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Daniela', 'Flores', 'daniela.f@email.com', '2002-06-06', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Andrés', 'Silva', 'andres.s@email.com', '2000-09-09', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Paula', 'Molina', 'paula.m@email.com', '2001-11-11', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Esteban', 'Ríos', 'esteban.r@email.com', '1998-02-02', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Victoria', 'Suárez', 'victoria.s@email.com', '2002-04-04', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Oscar', 'Blanco', 'oscar.b@email.com', '2000-08-08', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2),
('Natalia', 'Paredes', 'natalia.p@email.com', '2001-10-10', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 2);

/*INSERT INTO Alumnos (id_usuario, id_curso) VALUES 
(14, 2), (15, 2), (16, 2), (17, 2), (18, 2), (19, 2), (20, 2), (21, 2), (22, 2), (23, 2);
INSERT INTO Alumnos (id_usuario, id_curso) VALUES 
(24, 1), (25, 1), (26, 1), (27, 1), (28, 1), (29, 1), (30, 1), (31, 1), (32, 1), (33, 1);*/

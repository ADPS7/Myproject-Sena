import mysql.connector
import hashlib
from collections import defaultdict

def get_db_connection():
    return mysql.connector.connect(host="localhost", user="root", password="", database="edullinas")

def db_create_user(data):
    try:
        conn = get_db_connection(); cursor = conn.cursor()
        hashed = hashlib.sha256(data['clave'].encode()).hexdigest()
        cursor.execute("INSERT INTO usuarios (nombres, apellidos, correo, fecha_nacimiento, clave, id_rol) VALUES (%s, %s, %s, %s, %s, 2)", 
                       (data['nombres'], data['apellidos'], data['correo'], data['fecha_nacimiento'], hashed))
        conn.commit(); return {"message": "Usuario creado"}
    except Exception as e: return {"error": str(e)}

def db_login(correo, clave):
    try:
        conn = get_db_connection(); cursor = conn.cursor(dictionary=True)
        hashed = hashlib.sha256(clave.encode()).hexdigest()
        cursor.execute("SELECT u.*, r.nombre as rol FROM usuarios u JOIN roles r ON u.id_rol = r.id_rol WHERE u.correo = %s AND u.clave = %s", (correo, hashed))
        user = cursor.fetchone()
        return {"success": True, "user": user} if user else {"error": "Credenciales inválidas"}
    except Exception as e: return {"error": str(e)}

def db_get_asistencias(id_usuario):
    conn = get_db_connection(); cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT a.fecha, a.asistio, m.nombre as modulo_nombre, c.nombre as curso_nombre FROM Asistencia a JOIN Modulos m ON a.id_modulo = m.id_modulo JOIN Cursos c ON m.id_curso = c.id_curso WHERE a.id_usuario = %s", (id_usuario,))
    return cursor.fetchall()

def db_get_cursos_profesor(id_usuario):
    conn = get_db_connection(); cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT c.id_curso, c.nombre FROM Cursos c JOIN Profesor p ON c.id_curso = p.id_curso WHERE p.id_usuario = %s", (id_usuario,))
    return cursor.fetchall()

def db_get_modulos_curso(id_curso):
    conn = get_db_connection(); cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT id_modulo, nombre FROM Modulos WHERE id_curso = %s", (id_curso,))
    return cursor.fetchall()

def db_get_estudiantes(id_modulo):
    conn = get_db_connection(); cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT u.id_usuario, u.nombres, u.apellidos FROM Usuarios u JOIN Alumnos a ON u.id_usuario = a.id_usuario JOIN Modulos m ON a.id_curso = m.id_curso WHERE m.id_modulo = %s", (id_modulo,))
    return cursor.fetchall()

def db_registrar_asistencia(data):
    conn = get_db_connection(); cursor = conn.cursor()
    for id_est in data['estudiantes']:
        cursor.execute("INSERT INTO Asistencia (id_usuario, id_modulo, fecha, asistio) VALUES (%s, %s, %s, 'SI') ON DUPLICATE KEY UPDATE asistio='SI'", (id_est, data['id_modulo'], data['fecha']))
    conn.commit(); return {"success": True}

def db_get_admin_asistencias():
    conn = get_db_connection(); cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT c.nombre as curso, m.nombre as modulo, u.nombres, a.fecha, a.asistio FROM Cursos c JOIN Modulos m ON m.id_curso = c.id_curso JOIN Alumnos al ON al.id_curso = c.id_curso JOIN Usuarios u ON u.id_usuario = al.id_usuario LEFT JOIN Asistencia a ON a.id_usuario = u.id_usuario AND a.id_modulo = m.id_modulo")
    return cursor.fetchall()

def db_get_admin_notas():
    conn = get_db_connection(); cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT c.nombre as curso, m.nombre as modulo, u.nombres, n.nota FROM Cursos c JOIN Modulos m ON m.id_curso = c.id_curso JOIN Alumnos a ON a.id_curso = c.id_curso JOIN Usuarios u ON u.id_usuario = a.id_usuario LEFT JOIN Notas n ON n.id_usuario = u.id_usuario AND n.id_modulo = m.id_modulo")
    return cursor.fetchall()

def db_get_notas_modulo(id_modulo):
    conn = get_db_connection(); cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT u.id_usuario, u.nombres, n.nota FROM Usuarios u JOIN Alumnos a ON u.id_usuario = a.id_usuario JOIN Modulos m ON a.id_curso = m.id_curso LEFT JOIN Notas n ON n.id_usuario = u.id_usuario AND n.id_modulo = m.id_modulo WHERE m.id_modulo = %s", (id_modulo,))
    return cursor.fetchall()

def db_guardar_nota(data):
    conn = get_db_connection(); cursor = conn.cursor()
    cursor.execute("INSERT INTO Notas (id_usuario, id_modulo, nota) VALUES (%s, %s, %s) ON DUPLICATE KEY UPDATE nota = %s", (data['id_usuario'], data['id_modulo'], data['nota'], data['nota']))
    conn.commit(); return {"success": True}

def db_eliminar_nota(id_nota):
    conn = get_db_connection(); cursor = conn.cursor()
    cursor.execute("DELETE FROM Notas WHERE id_nota = %s", (id_nota,))
    conn.commit(); return {"success": True}

def db_obtener_notas_estudiante(id_usuario):
    conn = get_db_connection(); cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT c.nombre as curso, m.nombre as modulo, n.nota FROM Alumnos a JOIN Cursos c ON a.id_curso = c.id_curso LEFT JOIN Modulos m ON m.id_curso = c.id_curso LEFT JOIN Notas n ON n.id_modulo = m.id_modulo AND n.id_usuario = a.id_usuario WHERE a.id_usuario = %s", (id_usuario,))
    return cursor.fetchall()

def db_get_cursos():
    conn = get_db_connection(); cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT id_curso, nombre FROM Cursos"); return cursor.fetchall()

def db_crear_curso(data):
    conn = get_db_connection(); cursor = conn.cursor()
    cursor.execute("INSERT INTO Cursos (nombre) VALUES (%s)", (data['nombre'],)); conn.commit(); return {"success": True}

def db_editar_curso(id_curso, data):
    conn = get_db_connection(); cursor = conn.cursor()
    cursor.execute("UPDATE Cursos SET nombre = %s WHERE id_curso = %s", (data['nombre'], id_curso)); conn.commit(); return {"success": True}

def db_eliminar_curso(id_curso):
    conn = get_db_connection(); cursor = conn.cursor()
    cursor.execute("DELETE FROM Cursos WHERE id_curso = %s", (id_curso,)); conn.commit(); return {"success": True}

def db_get_modulos():
    conn = get_db_connection(); cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT m.id_modulo, m.nombre, c.nombre as nombre_curso FROM Modulos m JOIN Cursos c ON m.id_curso = c.id_curso"); return cursor.fetchall()

def db_crear_modulo(data):
    conn = get_db_connection(); cursor = conn.cursor()
    cursor.execute("INSERT INTO Modulos (nombre, fecha_inicio, fecha_fin, id_curso) VALUES (%s, %s, %s, %s)", (data['nombre'], data['fecha_inicio'], data['fecha_fin'], data['id_curso'])); conn.commit(); return {"success": True}

def db_editar_modulo(id_modulo, data):
    conn = get_db_connection(); cursor = conn.cursor()
    cursor.execute("UPDATE Modulos SET nombre = %s, id_curso = %s WHERE id_modulo = %s", (data['nombre'], data['id_curso'], id_modulo)); conn.commit(); return {"success": True}

def db_eliminar_modulo(id_modulo):
    conn = get_db_connection(); cursor = conn.cursor()
    cursor.execute("DELETE FROM Modulos WHERE id_modulo = %s", (id_modulo,)); conn.commit(); return {"success": True}
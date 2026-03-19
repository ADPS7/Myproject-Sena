from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
import hashlib

app = Flask(__name__)
CORS(app)

def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="",
        database="edullinas"
    )

@app.route('/create_user', methods=['POST'])
def create_user():
    try:
        data = request.json
        nombres = data.get('nombres')
        apellidos = data.get('apellidos')
        correo = data.get('correo')
        fecha_nacimiento = data.get('fecha_nacimiento')
        clave = data.get('clave')
        
        if not all([nombres, apellidos, correo, fecha_nacimiento, clave]):
            return jsonify({"error": "Campos requeridos"}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        hashed_password = hashlib.sha256(clave.encode('utf-8')).hexdigest()
        
        cursor.execute(
            "INSERT INTO usuarios (nombres, apellidos, correo, fecha_nacimiento, clave, id_rol) VALUES (%s, %s, %s, %s, %s, %s)",
            (nombres, apellidos, correo, fecha_nacimiento, hashed_password, 2)
        )
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({"message": "Usuario creado exitosamente"}), 200
    except Error as e:
        return jsonify({"error": str(e)}), 400

@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.json
        correo = data.get('correo')
        clave = data.get('clave')

        if not correo or not clave:
            return jsonify({"error": "Correo y clave requeridos"}), 400

        # Encriptar la clave recibida para comparar
        hashed_password = hashlib.sha256(clave.encode('utf-8')).hexdigest()

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        query = """
            SELECT u.id_usuario, u.nombres, u.id_rol, r.nombre as rol 
            FROM usuarios u 
            JOIN roles r ON u.id_rol = r.id_rol 
            WHERE u.correo = %s AND u.clave = %s
        """
        cursor.execute(query, (correo, hashed_password))
        user = cursor.fetchone()
        
        cursor.close()
        conn.close()

        if user:
            return jsonify({"success": True, "user": user}), 200
        else:
            return jsonify({"error": "Correo o contraseña incorrectos"}), 401
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/asistencias/<int:id_usuario>', methods=['GET'])
def get_asistencias(id_usuario):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        query = """
            SELECT 
                a.fecha,
                a.asistio,
                m.nombre as modulo_nombre
            FROM Asistencia a
            JOIN Modulos m ON a.id_modulo = m.id_modulo
            WHERE a.id_usuario = %s
            ORDER BY a.fecha DESC
        """
        cursor.execute(query, (id_usuario,))
        asistencias = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return jsonify({
            "success": True,
            "asistencias": asistencias
        }), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        return jsonify({"error": "Error interno del servidor"}), 500
    
@app.route('/cursos/profesor/<int:id_usuario>', methods=['GET'])
def get_cursos_profesor(id_usuario):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        query = """
            SELECT 
                c.id_curso, 
                c.nombre 
            FROM Cursos c
            JOIN Profesor p ON c.id_curso = p.id_curso
            WHERE p.id_usuario = %s
        """
        
        cursor.execute(query, (id_usuario,))
        cursos = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return jsonify(cursos), 200
        
    except Error as e:
        print(f"Error en base de datos: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"Error interno: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500
    
@app.route('/modulos/curso/<int:id_curso>', methods=['GET'])
def get_modulos_curso(id_curso):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        # Consultamos los módulos asociados al curso seleccionado
        query = "SELECT id_modulo, nombre, fecha_inicio, fecha_fin FROM Modulos WHERE id_curso = %s"
        cursor.execute(query, (id_curso,))
        modulos = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return jsonify(modulos), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        return jsonify({"error": "Error interno del servidor"}), 500
    
@app.route('/modulo/<int:id_modulo>/students', methods=['GET'])
def get_estudiantes(id_modulo):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        # IMPORTANTE: u.id_usuario debe estar en el SELECT
        query = """
            SELECT 
                u.id_usuario, 
                u.nombres, 
                u.apellidos, 
                u.correo 
            FROM Usuarios u
            JOIN Alumnos a ON u.id_usuario = a.id_usuario
            JOIN Modulos m ON a.id_curso = m.id_curso
            WHERE m.id_modulo = %s
        """
        cursor.execute(query, (id_modulo,))
        estudiantes = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(estudiantes), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/asistencia/registrar', methods=['POST'])
def registrar_asistencia():
    try:
        data = request.json
        id_modulo = data.get('id_modulo')
        ids_estudiantes_presentes = data.get('estudiantes') # Es la lista [1, 2, 3...]
        fecha = data.get('fecha')

        if not id_modulo or ids_estudiantes_presentes is None:
            return jsonify({"error": "Faltan datos requeridos"}), 400

        conn = get_db_connection()
        cursor = conn.cursor()

        # 1. Primero buscamos a TODOS los estudiantes inscritos en ese módulo
        # Para saber quiénes NO vinieron (asistio = 0)
        query_todos = """
            SELECT u.id_usuario 
            FROM Usuarios u
            JOIN Alumnos al ON u.id_usuario = al.id_usuario
            JOIN Modulos m ON al.id_curso = m.id_curso
            WHERE m.id_modulo = %s
        """
        cursor.execute(query_todos, (id_modulo,))
        todos_los_estudiantes = [row[0] for row in cursor.fetchall()]

        # 2. Insertamos el registro para cada estudiante
        insert_query = """
            INSERT INTO Asistencia (id_usuario, id_modulo, fecha, asistio) 
            VALUES (%s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE asistio = VALUES(asistio)
        """

        for id_estudiante in todos_los_estudiantes:
            # Si el ID está en la lista de Flutter, asistio = 1, si no, 0
            asistio = 1 if id_estudiante in ids_estudiantes_presentes else 0
            cursor.execute(insert_query, (id_estudiante, id_modulo, fecha, asistio))

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({"success": True, "message": "Asistencia registrada correctamente"}), 200

    except Error as e:
        print(f"Error MySQL: {e}")
        return jsonify({"success": False, "error": str(e)}), 500
    except Exception as e:
        print(f"Error Interno: {e}")
        return jsonify({"success": False, "error": "Error interno"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
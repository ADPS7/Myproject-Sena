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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
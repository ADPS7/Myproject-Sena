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
        print(f"Datos recibidos: {data}")
        
        nombres = data.get('nombres')
        apellidos = data.get('apellidos')
        correo = data.get('correo')
        fecha_nacimiento = data.get('fecha_nacimiento')
        clave = data.get('clave')
        
        if not all([nombres, apellidos, correo, fecha_nacimiento, clave]):
            print("Faltan campos requeridos")
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
        print("Usuario creado exitosamente")
        return jsonify({"message": "Usuario creado exitosamente"}), 200
    except Error as e:
        print(f"Error de base de datos: {str(e)}")
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        print(f"Error general: {str(e)}")
        return jsonify({"error": str(e)}), 400

@app.route('/get_users', methods=['GET'])
def get_users():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT u.id_usuario, u.nombres, u.apellidos, u.correo, u.fecha_nacimiento, r.nombre as rol FROM usuarios u JOIN roles r ON u.id_rol = r.id_rol")
        users = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(users), 200
    except Error as e:
        return jsonify({"error": str(e)}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
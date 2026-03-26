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
                SELECT 
                    u.id_usuario, 
                    u.nombres, 
                    u.apellidos,
                    u.id_rol, 
                    r.nombre as rol 
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

        # Busca esta parte en tu ruta /asistencia/registrar
        for id_estudiante in todos_los_estudiantes:
            # CAMBIO AQUÍ: Guardamos "SI" o "NO" como texto
            asistio_texto = "SI" if id_estudiante in ids_estudiantes_presentes else "NO"
            cursor.execute(insert_query, (id_estudiante, id_modulo, fecha, asistio_texto))

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

@app.route('/asistencias/detalle/<int:id_usuario>', methods=['GET'])
def get_detalle_asistencias(id_usuario):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        # Quitamos el JOIN momentáneamente para ver si al menos trae las fechas
        query = "SELECT fecha, asistio, id_modulo FROM Asistencia WHERE id_usuario = %s"
        
        cursor.execute(query, (id_usuario,))
        resultado = cursor.fetchall()
        
        # Si esto imprime algo en tu terminal de Python, la conexión está bien
        print(f"Registros encontrados para el usuario {id_usuario}: {len(resultado)}")
        
        cursor.close()
        conn.close()
        
        return jsonify({
            "success": True,
            "asistencias": resultado
        }), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
    
from collections import defaultdict

@app.route('/admin/asistencias', methods=['GET'])
def get_admin_asistencias():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        query = """
            SELECT 
                c.id_curso,
                c.nombre as curso_nombre,
                m.id_modulo,
                m.nombre as modulo_nombre,
                u.id_usuario,
                CONCAT(u.nombres, ' ', u.apellidos) as estudiante_nombre,
                a.fecha,
                a.asistio
            FROM Cursos c
            JOIN Modulos m ON m.id_curso = c.id_curso
            JOIN Alumnos al ON al.id_curso = c.id_curso
            JOIN Usuarios u ON u.id_usuario = al.id_usuario
            LEFT JOIN Asistencia a ON a.id_usuario = u.id_usuario 
                                 AND a.id_modulo = m.id_modulo
            ORDER BY c.id_curso, m.id_modulo, u.id_usuario, a.fecha ASC
        """
        cursor.execute(query)
        rows = cursor.fetchall()

        # === AGRUPACIÓN EN PYTHON ===
        cursos_dict = defaultdict(lambda: {
            "id_curso": 0, "nombre": "", "modulos": defaultdict(lambda: {
                "id_modulo": 0, "nombre": "", "estudiantes": defaultdict(lambda: {
                    "id_usuario": 0, "nombre": "", "asistencias": [], "inasistencias": 0
                })
            })
        })

        for row in rows:
            c_key = row['id_curso']
            m_key = row['id_modulo']
            u_key = row['id_usuario']

            # Curso
            if cursos_dict[c_key]["id_curso"] == 0:
                cursos_dict[c_key]["id_curso"] = row['id_curso']
                cursos_dict[c_key]["nombre"] = row['curso_nombre']

            # Módulo
            if cursos_dict[c_key]["modulos"][m_key]["id_modulo"] == 0:
                cursos_dict[c_key]["modulos"][m_key]["id_modulo"] = row['id_modulo']
                cursos_dict[c_key]["modulos"][m_key]["nombre"] = row['modulo_nombre']

            # Estudiante
            est = cursos_dict[c_key]["modulos"][m_key]["estudiantes"][u_key]
            if est["id_usuario"] == 0:
                est["id_usuario"] = row['id_usuario']
                est["nombre"] = row['estudiante_nombre']

            # Asistencia (solo si existe)
            if row['fecha'] is not None:
                est["asistencias"].append({
                    "fecha": str(row['fecha']),
                    "asistio": row['asistio']
                })
                if row['asistio'] == 'NO':
                    est["inasistencias"] += 1

        # Convertir a listas normales
        cursos = []
        for curso in cursos_dict.values():
            modulos_list = []
            for mod in curso["modulos"].values():
                estudiantes_list = []
                for est in mod["estudiantes"].values():
                    est["alerta"] = est["inasistencias"] > 3
                    estudiantes_list.append(est)
                mod["estudiantes"] = estudiantes_list
                modulos_list.append(mod)
            curso["modulos"] = modulos_list
            cursos.append(curso)

        cursor.close()
        conn.close()
        return jsonify({"success": True, "cursos": cursos}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@app.route('/admin/notas', methods=['GET'])
def get_admin_notas():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        query = """
            SELECT 
                c.nombre AS curso,
                m.nombre AS modulo,
                CONCAT(u.nombres, ' ', u.apellidos) AS estudiante,
                n.nota
            FROM Cursos c
            JOIN Modulos m ON m.id_curso = c.id_curso
            JOIN Alumnos a ON a.id_curso = c.id_curso
            JOIN Usuarios u ON u.id_usuario = a.id_usuario
            LEFT JOIN Notas n 
                ON n.id_usuario = u.id_usuario 
                AND n.id_modulo = m.id_modulo
            ORDER BY c.nombre, m.nombre, estudiante
        """

        cursor.execute(query)
        rows = cursor.fetchall()

        from collections import defaultdict

        data = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))

        # Agrupar datos
        for row in rows:
            curso = row['curso']
            modulo = row['modulo']
            estudiante = row['estudiante']

            if row['nota'] is not None:
                data[curso][modulo][estudiante].append({
                    "nota": float(row['nota'])
                })

        resultado = []

        # Construir respuesta final
        for curso, modulos in data.items():
            curso_data = {"nombre": curso, "modulos": []}

            for modulo, estudiantes in modulos.items():
                modulo_data = {"nombre": modulo, "estudiantes": []}

                for estudiante, notas in estudiantes.items():
                    
                    if notas:
                        promedio = sum(n['nota'] for n in notas) / len(notas)
                    else:
                        promedio = 0

                    modulo_data["estudiantes"].append({
                        "nombre": estudiante,
                        "notas": notas,
                        "promedio": round(promedio, 2),
                        "alerta": promedio < 3.0
                    })

                curso_data["modulos"].append(modulo_data)

            resultado.append(curso_data)

        cursor.close()
        conn.close()

        return jsonify({"success": True, "cursos": resultado}), 200

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
    
@app.route('/notas/modulo/<int:id_modulo>', methods=['GET'])
def get_notas_modulo(id_modulo):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        query = """
            SELECT 
                u.id_usuario,
                CONCAT(u.nombres, ' ', u.apellidos) AS nombre,
                n.id_nota,
                n.nota
            FROM Usuarios u
            JOIN Alumnos a ON u.id_usuario = a.id_usuario
            JOIN Modulos m ON a.id_curso = m.id_curso
            LEFT JOIN Notas n 
                ON n.id_usuario = u.id_usuario 
                AND n.id_modulo = m.id_modulo
            WHERE m.id_modulo = %s
        """

        cursor.execute(query, (id_modulo,))
        data = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify(data), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@app.route('/notas', methods=['POST'])
def guardar_nota():
    try:
        data = request.json
        id_usuario = data['id_usuario']
        id_modulo = data['id_modulo']
        nota = data['nota']

        conn = get_db_connection()
        cursor = conn.cursor()

        query = """
            INSERT INTO Notas (id_usuario, id_modulo, nota)
            VALUES (%s, %s, %s)
            ON DUPLICATE KEY UPDATE nota = VALUES(nota)
        """

        cursor.execute(query, (id_usuario, id_modulo, nota))
        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({"success": True}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@app.route('/notas/<int:id_nota>', methods=['DELETE'])
def eliminar_nota(id_nota):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("DELETE FROM Notas WHERE id_nota = %s", (id_nota,))
        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({"success": True}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
    


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
from flask import Flask, request, jsonify, render_template, redirect
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
import hashlib

app = Flask(__name__)
CORS(app)
app = Flask(__name__)
app.secret_key = 'edullinas_secret_key_2026_pro_MADAN'

def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="",
        database="edullinas"
    )

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/<page_name>')
def render_static_page(page_name):
    try:
        return render_template(f"view/{page_name}.html")
    except Exception:
        return f"Error: El archivo 'templates/view/{page_name}.html' no existe.", 404

@app.route('/create_user', methods=['POST'])
def create_user():
    try:
        if request.is_json:
            data = request.json
        else:
            data = request.form

        nombres = data.get('nombres') or data.get('nombre')
        apellidos = data.get('apellidos') or data.get('apellido')
        correo = data.get('correo') or data.get('email')
        fecha_nacimiento = data.get('fecha_nacimiento')
        clave = data.get('clave') or data.get('password')
        
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
        if request.is_json:
            return jsonify({"message": "Usuario creado exitosamente"}), 200
        else:
            return redirect('/login') 

    except Error as e:
        return jsonify({"error": str(e)}), 400

from flask import session, redirect, url_for

@app.route('/login', methods=['POST'])
def login():
    try:
        # Detectar si los datos vienen de Flutter (JSON) o de la Web (Formulario)
        if request.is_json:
            data = request.json
            correo = data.get('correo')
            clave = data.get('clave')
        else:
            data = request.form
            # Usamos .get('email') porque así está en tu HTML
            correo = data.get('email') 
            clave = data.get('password')

        if not correo or not clave:
            return jsonify({"error": "Correo y clave requeridos"}), 400

        hashed_password = hashlib.sha256(clave.encode('utf-8')).hexdigest()

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        query = """
                SELECT u.id_usuario, u.nombres, u.apellidos, u.correo, u.id_rol, r.nombre as rol 
                FROM usuarios u 
                JOIN roles r ON u.id_rol = r.id_rol 
                WHERE u.correo = %s AND u.clave = %s
            """
        cursor.execute(query, (correo, hashed_password))
        user = cursor.fetchone()
        cursor.close()
        conn.close()

        if user:
            # Si es Flutter, devolvemos el JSON original
            if request.is_json:
                return jsonify({"success": True, "user": user}), 200
            
            # Si es la Web, guardamos en sesión y redirigimos
            session['usuario'] = user
            return redirect(url_for('dashboard'))
        else:
            if request.is_json:
                return jsonify({"error": "Correo o contraseña incorrectos"}), 401
            return "Correo o contraseña incorrectos", 401

    except Exception as e:
        return jsonify({"error": str(e)}), 500

from flask import session, redirect, url_for, render_template

@app.route('/dashboard')
def dashboard():
    if 'usuario' not in session:
        return redirect('/login')
    
    user = session['usuario']
    rol = user.get('rol').lower()
    if rol == 'administrador' or user.get('id_rol') == 1:
        return render_template('view/Admin/inicioAdmin.html', user=user)
    
    elif rol == 'profesor' or user.get('id_rol') == 3:
        return render_template('view/dashboard_profesor.html', user=user)
    
    else:
        return render_template('view/dashboard_estudiante.html', user=user)

@app.route('/asistencias/<int:id_usuario>', methods=['GET'])
def get_asistencias(id_usuario):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
       
        query = """
            SELECT 
                a.fecha,
                a.asistio,
                m.nombre as modulo_nombre,
                c.nombre as curso_nombre,
                m.id_curso
            FROM Asistencia a
            JOIN Modulos m ON a.id_modulo = m.id_modulo
            JOIN Cursos c ON m.id_curso = c.id_curso
            WHERE a.id_usuario = %s
            ORDER BY a.fecha DESC
        """
        cursor.execute(query, (id_usuario,))
        asistencias = cursor.fetchall()

        
        if not asistencias:
            cursor.execute("""
                SELECT c.nombre as curso_nombre, c.id_curso
                FROM Alumnos a
                JOIN Cursos c ON a.id_curso = c.id_curso
                WHERE a.id_usuario = %s
                LIMIT 1
            """, (id_usuario,))
            curso = cursor.fetchone()
            
            if curso:
                return jsonify({
                    "success": True,
                    "asistencias": [],
                    "curso_nombre": curso['curso_nombre'],
                    "id_curso": curso['id_curso']
                }), 200
            else:
                return jsonify({
                    "success": True,
                    "asistencias": [],
                    "curso_nombre": "Sin curso asignado",
                    "id_curso": None
                }), 200

        
        return jsonify({
            "success": True,
            "asistencias": asistencias
        }), 200
        
    except Exception as e:
        print(f"Error en get_asistencias: {e}")   
        return jsonify({"error": "Error interno del servidor"}), 500
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()
    
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
def get_estudiantes_modulo(id_modulo):
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
    
@app.route('/notas-alumno/<int:id_usuario>', methods=['GET'])
def obtener_notas_estudiante(id_usuario):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        query = """
            SELECT 
                c.nombre AS curso_nombre,
                m.nombre AS modulo_nombre,
                n.nota
            FROM alumnos a
            JOIN cursos c ON a.id_curso = c.id_curso
            LEFT JOIN modulos m ON m.id_curso = c.id_curso
            LEFT JOIN notas n ON n.id_modulo = m.id_modulo AND n.id_usuario = a.id_usuario
            WHERE a.id_usuario = %s
            ORDER BY m.id_modulo
        """

        cursor.execute(query, (id_usuario,))
        resultados = cursor.fetchall()

        if not resultados:
            return jsonify({
                "success": True,
                "curso": "Sin curso",
                "modulos": []
            }), 200

        curso_nombre = resultados[0]['curso_nombre']

        modulos_dict = {}

        for row in resultados:
            modulo = row['modulo_nombre']
            nota = row['nota']

            if modulo is None:
                continue

            if modulo not in modulos_dict:
                modulos_dict[modulo] = []

            if nota is not None:
                modulos_dict[modulo].append(nota)

        resultado_modulos = [
            {
                "nombre": modulo,
                "notas": notas
            }
            for modulo, notas in modulos_dict.items()
        ]

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "curso": curso_nombre,
            "modulos": resultado_modulos
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/cursos/crear', methods=['POST'])
def crear_curso():
    try:
        data = request.json
        nombre = data.get('nombre')
        
        if not nombre:
            return jsonify({"error": "Nombre del curso requerido"}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Verificar existencia
        cursor.execute("SELECT id_curso FROM Cursos WHERE nombre = %s", (nombre,))
        if cursor.fetchone():
            cursor.close()
            conn.close()
            return jsonify({"success": False, "error": "El curso ya existe"}), 409
            
        # Registrar
        cursor.execute("INSERT INTO Cursos (nombre) VALUES (%s)", (nombre,))
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({"success": True, "message": "Curso registrado exitosamente"}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/cursos', methods=['GET'])
def get_cursos():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT id_curso, nombre FROM Cursos")
        cursos = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(cursos), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/cursos/editar/<int:id_curso>', methods=['PUT'])
def editar_curso(id_curso):
    try:
        data = request.json
        nuevo_nombre = data.get('nombre')
        
        if not nuevo_nombre:
            return jsonify({"error": "Nombre requerido"}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("UPDATE Cursos SET nombre = %s WHERE id_curso = %s", (nuevo_nombre, id_curso))
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({"success": True, "message": "Curso actualizado"}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/cursos/eliminar/<int:id_curso>', methods=['DELETE'])
def eliminar_curso(id_curso):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM Cursos WHERE id_curso = %s", (id_curso,))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({"success": True, "message": "Curso eliminado"}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/modulos/crear', methods=['POST'])
def crear_modulo():
    data = request.json
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO Modulos (nombre, fecha_inicio, fecha_fin, id_curso) VALUES (%s, %s, %s, %s)",
        (data['nombre'], data['fecha_inicio'], data['fecha_fin'], data['id_curso'])
    )
    conn.commit()
    return jsonify({"success": True})

@app.route('/modulos', methods=['GET'])
def get_modulos():
    try:
        conn = get_db_connection()
        # Usamos un cursor de diccionario para manejar los datos como objetos JSON fácilmente
        cursor = conn.cursor(dictionary=True)
        
        # Hacemos un JOIN para obtener el nombre del curso junto con el módulo
        query = """
            SELECT m.id_modulo, m.nombre, m.fecha_inicio, m.fecha_fin, c.nombre as nombre_curso 
            FROM Modulos m
            JOIN Cursos c ON m.id_curso = c.id_curso
        """
        cursor.execute(query)
        modulos = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return jsonify(modulos), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/modulos/editar/<int:id_modulo>', methods=['PUT'])
def editar_modulo(id_modulo):
    data = request.json

    conn = get_db_connection() 
    cursor = conn.cursor()
    
    try:
        cursor.execute("""
            UPDATE Modulos 
            SET nombre = %s, fecha_inicio = %s, fecha_fin = %s, id_curso = %s 
            WHERE id_modulo = %s
        """, (data['nombre'], data['fecha_inicio'], data['fecha_fin'], data['id_curso'], id_modulo))
        
        conn.commit()
        return jsonify({"success": True}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/modulos/eliminar/<int:id_modulo>', methods=['DELETE'])
def eliminar_modulo(id_modulo):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM Modulos WHERE id_modulo = %s", (id_modulo,))
        conn.commit()
        return jsonify({"success": True}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/asignar-alumno', methods=['POST'])
def asignar_alumno():
    try:
        data = request.json
        id_usuario = data.get('id_usuario')
        id_curso = data.get('id_curso')
        
        if not id_usuario or not id_curso:
            return jsonify({"error": "id_usuario e id_curso requeridos"}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Verificar si el usuario existe y es estudiante
        cursor.execute("SELECT id_rol FROM Usuarios WHERE id_usuario = %s", (id_usuario,))
        user = cursor.fetchone()
        if not user or user[0] != 2:  # 2 es estudiante
            cursor.close()
            conn.close()
            return jsonify({"error": "Usuario no encontrado o no es estudiante"}), 400
        
        # Intentar insertar, el UNIQUE constraint evitará duplicados
        cursor.execute("INSERT INTO Alumnos (id_usuario, id_curso) VALUES (%s, %s)", (id_usuario, id_curso))
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({"success": True, "message": "Estudiante asignado al curso exitosamente"}), 200
    except mysql.connector.IntegrityError as e:
        if e.errno == 1062:  # Duplicate entry
            return jsonify({"error": "El estudiante ya está asignado a un curso"}), 409
        else:
            return jsonify({"error": str(e)}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/estudiantes', methods=['GET'])
def get_estudiantes():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        query = """
            SELECT id_usuario, nombres, apellidos, correo
            FROM Usuarios
            WHERE id_rol = 2
        """
        cursor.execute(query)
        estudiantes = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(estudiantes), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/estudiantes-sin-curso', methods=['GET'])
def get_estudiantes_sin_curso():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        query = """
            SELECT u.id_usuario, u.nombres, u.apellidos, u.correo
            FROM Usuarios u
            LEFT JOIN Alumnos a ON u.id_usuario = a.id_usuario
            WHERE u.id_rol = 2 AND a.id_usuario IS NULL
        """
        cursor.execute(query)
        estudiantes = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(estudiantes), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
from flask import Flask, request, jsonify, render_template, redirect, session, redirect, url_for
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
import hashlib
from datetime import datetime
from collections import defaultdict


app = Flask(__name__)
CORS(app)
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

@app.route('/logout')
def logout():
    session.clear() 
    return redirect(url_for('login'))

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

        cursor.execute("SELECT id_usuario FROM usuarios WHERE correo = %s", (correo,))
        if cursor.fetchone():
            cursor.close()
            conn.close()
            return jsonify({"error": "Este correo electrónico ya está registrado"}), 409
        
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
                SELECT u.id_usuario, u.nombres, u.apellidos, u.correo, u.fecha_nacimiento, u.id_rol, r.nombre as rol 
                FROM usuarios u 
                JOIN roles r ON u.id_rol = r.id_rol 
                WHERE u.correo = %s AND u.clave = %s
            """
        cursor.execute(query, (correo, hashed_password))
        user = cursor.fetchone()
        cursor.close()
        conn.close()

        if user:
            # Usuario inactivo
            if user.get('id_rol') == 5:
                return jsonify({
                    "error": "Tu cuenta está inactiva. Por favor contacta al administrador."
                }), 403

            # Login exitoso
            if request.is_json:
                return jsonify({"success": True, "user": user}), 200
            
            session['usuario'] = user
            return redirect(url_for('dashboard'))

        else:
            # Credenciales incorrectas - Mensaje genérico
            return jsonify({"error": "Correo o contraseña incorrectos"}), 401
        
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
        return render_template('view/Admin/menuAdmin.html', user=user)
    
    elif rol == 'profesor' or user.get('id_rol') == 3:
        return render_template('view/profesor/menuProfesor.html', user=user)
    
    elif rol == 'Coordinador' or user.get('id_rol') == 4:
        return render_template('view/Coordinador/menuCoordinador.html', user=user)
    
    else:
        return render_template('view/estudiante/menuEstudiante.html', user=user)


@app.route('/profesor/notaProfesor')
def profesor_nota_profesor():
    if 'usuario' not in session:
        return redirect('/login')
    user = session['usuario']
    return render_template('view/profesor/menuProfesor.html', user=user)



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

@app.route('/modulo/<int:id_modulo>/asistencia', methods=['GET'])
def get_asistencia_modulo_fecha(id_modulo):
    fecha = request.args.get('fecha')
    if not fecha:
        return jsonify({"success": False, "error": "Falta la fecha para consultar la asistencia."}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        query = "SELECT COUNT(*) as total FROM Asistencia WHERE id_modulo = %s AND fecha = %s"
        cursor.execute(query, (id_modulo, fecha))
        resultado = cursor.fetchone()
        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "registrada": resultado['total'] > 0,
            "total": resultado['total']
        }), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/modulo/<int:id_modulo>/asistencias', methods=['GET'])
def get_historial_asistencias_modulo(id_modulo):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        query = """
            SELECT 
                u.id_usuario,
                CONCAT(u.nombres, ' ', u.apellidos) AS estudiante,
                a.fecha,
                a.asistio
            FROM Asistencia a
            JOIN Usuarios u ON a.id_usuario = u.id_usuario
            WHERE a.id_modulo = %s
            ORDER BY a.fecha DESC, u.nombres
        """
        cursor.execute(query, (id_modulo,))
        historial_raw = cursor.fetchall()
        # Asegurarnos de devolver la fecha en formato YYYY-MM-DD (sin hora)
        historial = []
        for row in historial_raw:
            historial.append({
                'id_usuario': row.get('id_usuario'),
                'estudiante': row.get('estudiante'),
                'fecha': str(row.get('fecha')) if row.get('fecha') is not None else None,
                'asistio': row.get('asistio')
            })
        cursor.close()
        conn.close()

        return jsonify({"success": True, "historial": historial}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/asistencia/registrar', methods=['POST'])
def registrar_asistencia():
    try:
        data = request.json
        id_modulo = data.get('id_modulo')
        ids_estudiantes_presentes = data.get('estudiantes')
        asistencias = data.get('asistencias')
        fecha = data.get('fecha')

        if not id_modulo or (ids_estudiantes_presentes is None and asistencias is None):
            return jsonify({"error": "Faltan datos requeridos"}), 400

        if not fecha:
            return jsonify({"error": "Falta la fecha para registrar la asistencia."}), 400

        try:
            fecha_obj = datetime.strptime(fecha, "%Y-%m-%d").date()
        except ValueError:
            return jsonify({"error": "Formato de fecha inválido. Use YYYY-MM-DD."}), 400

        # Normalizamos la fecha a cadena YYYY-MM-DD para almacenar sin hora
        fecha_iso = fecha_obj.isoformat()

        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute(
            "SELECT fecha_inicio, fecha_fin FROM Modulos WHERE id_modulo = %s",
            (id_modulo,)
        )
        modulo_rango = cursor.fetchone()
        if not modulo_rango:
            cursor.close()
            conn.close()
            return jsonify({"error": "Módulo no encontrado."}), 404

        fecha_inicio = modulo_rango[0]
        fecha_fin = modulo_rango[1]
        if fecha_obj < fecha_inicio or fecha_obj > fecha_fin:
            cursor.close()
            conn.close()
            return jsonify({
                "success": False,
                "error": f"La fecha debe estar entre {fecha_inicio.isoformat()} y {fecha_fin.isoformat()}."
            }), 400

        # Evitamos que la asistencia se registre más de una vez por módulo y fecha.
        cursor.execute(
            "SELECT COUNT(*) as total FROM Asistencia WHERE id_modulo = %s AND fecha = %s",
            (id_modulo, fecha_iso)
        )
        registro_existente = cursor.fetchone()[0]
        if registro_existente > 0:
            cursor.close()
            conn.close()
            return jsonify({
                "success": False,
                "error": "No se puede registrar la asistencia porque ya la registraste para esta fecha y módulo."
            }), 409
        
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

        estado_por_estudiante = {}
        if asistencias is not None:
            for item in asistencias:
                try:
                    estado_por_estudiante[int(item.get('id_usuario'))] = 'SI' if str(item.get('asistio')).upper() == 'SI' else 'NO'
                except (ValueError, TypeError):
                    continue

        for id_estudiante in todos_los_estudiantes:
            if id_estudiante in estado_por_estudiante:
                asistio_texto = estado_por_estudiante[id_estudiante]
            else:
                asistio_texto = 'SI' if ids_estudiantes_presentes and id_estudiante in ids_estudiantes_presentes else 'NO'
            # Insertamos usando la fecha normalizada (sin hora)
            cursor.execute(insert_query, (id_estudiante, id_modulo, fecha_iso, asistio_texto))

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
                u.correo,
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

        if nota is None or float(nota) > 5.0:
            return jsonify({"error": "La nota no puede ser mayor a 5.0."}), 400

        conn = get_db_connection()
        cursor = conn.cursor()

        query = """
            INSERT INTO Notas (id_usuario, id_modulo, nota)
            VALUES (%s, %s, %s)
        """

        cursor.execute(query, (id_usuario, id_modulo, nota))
        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({"success": True}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/notas/<int:id_nota>', methods=['PUT'])
def actualizar_nota(id_nota):
    try:
        data = request.json
        nota = data['nota']

        if nota is None or float(nota) > 5.0:
            return jsonify({"error": "La nota no puede ser mayor a 5.0."}), 400

        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute(
            "UPDATE Notas SET nota = %s WHERE id_nota = %s",
            (nota, id_nota)
        )
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
                m.id_modulo,
                m.nombre AS modulo_nombre,
                n.id_nota,
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
            modulo_id = row['id_modulo']
            modulo_nombre = row['modulo_nombre']
            nota_id = row['id_nota']
            nota = row['nota']

            if modulo_id is None:
                continue

            if modulo_id not in modulos_dict:
                modulos_dict[modulo_id] = {'nombre': modulo_nombre, 'notas': []}

            if nota is not None:
                modulos_dict[modulo_id]['notas'].append({
                    'id_nota': nota_id,
                    'nota': float(nota)
                })

        resultado_modulos = [
            {
                "id_modulo": id_mod,
                "nombre": data['nombre'],
                "notas": data['notas']
            }
            for id_mod, data in modulos_dict.items()
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
        cursor = conn.cursor(dictionary=True)
        
        # FIX: Usamos DATE_FORMAT para retornar 'YYYY-MM-DD' directamente desde la base de datos
        query = """
            SELECT 
                m.id_modulo, 
                m.nombre, 
                DATE_FORMAT(m.fecha_inicio, '%Y-%m-%d') as fecha_inicio, 
                DATE_FORMAT(m.fecha_fin, '%Y-%m-%d') as fecha_fin, 
                m.id_curso, 
                c.nombre as nombre_curso 
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

@app.route('/cursos/<int:id_curso>/estudiantes', methods=['GET'])
def get_estudiantes_por_curso(id_curso):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        query = """
            SELECT u.id_usuario, u.nombres, u.apellidos, u.correo
            FROM Usuarios u
            JOIN Alumnos a ON u.id_usuario = a.id_usuario
            WHERE a.id_curso = %s AND u.id_rol = 2
        """
        cursor.execute(query, (id_curso,))
        estudiantes = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(estudiantes), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/profesores-sin-curso', methods=['GET'])
def getProfesoresSinCurso():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        query = """
            SELECT u.id_usuario, u.nombres, u.apellidos, u.correo
            FROM Usuarios u
            LEFT JOIN Profesor p ON u.id_usuario = p.id_usuario
            WHERE u.id_rol = 3 AND p.id_usuario IS NULL
        """
        cursor.execute(query)
        profesores = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(profesores), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/cursos/<int:id_curso>/profesores', methods=['GET'])
def getProfesoresPorCurso(id_curso):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        query = """
            SELECT u.id_usuario, u.nombres, u.apellidos, u.correo, p.id_profesor
            FROM Usuarios u
            JOIN Profesor p ON u.id_usuario = p.id_usuario
            WHERE p.id_curso = %s AND u.id_rol = 3
        """
        cursor.execute(query, (id_curso,))
        profesores = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(profesores), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/profesores-disponibles/<int:id_curso>', methods=['GET'])
def getProfesoresDisponiblesPorCurso(id_curso):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        query = """
            SELECT u.id_usuario, u.nombres, u.apellidos, u.correo
            FROM Usuarios u
            WHERE u.id_rol = 3
              AND NOT EXISTS (
                  SELECT 1
                  FROM Profesor p
                  WHERE p.id_usuario = u.id_usuario
                    AND p.id_curso = %s
              )
        """
        cursor.execute(query, (id_curso,))
        profesores = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(profesores), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/asignar-profesor', methods=['POST'])
def asignarProfesor():
    try:
        data = request.json
        id_usuario = data.get('id_usuario')
        id_curso = data.get('id_curso')

        if not id_usuario or not id_curso:
            return jsonify({"error": "id_usuario e id_curso requeridos"}), 400

        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT id_rol FROM Usuarios WHERE id_usuario = %s", (id_usuario,))
        usuario = cursor.fetchone()
        if not usuario or usuario[0] != 3:
            cursor.close()
            conn.close()
            return jsonify({"error": "Usuario no encontrado o no es profesor"}), 400

        cursor.execute("SELECT id_profesor FROM Profesor WHERE id_usuario = %s AND id_curso = %s", (id_usuario, id_curso))
        if cursor.fetchone():
            cursor.close()
            conn.close()
            return jsonify({"error": "El profesor ya está asignado a este curso"}), 409

        cursor.execute("INSERT INTO Profesor (id_usuario, id_curso) VALUES (%s, %s)", (id_usuario, id_curso))
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({"success": True, "message": "Profesor asignado al curso exitosamente"}), 200
    except mysql.connector.IntegrityError as e:
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/desasignar-profesor', methods=['POST'])
def desasignarProfesor():
    try:
        data = request.json
        id_usuario = data.get('id_usuario')
        id_curso = data.get('id_curso')

        if not id_usuario:
            return jsonify({"error": "id_usuario requerido"}), 400

        conn = get_db_connection()
        cursor = conn.cursor()

        if id_curso:
            cursor.execute("DELETE FROM Profesor WHERE id_usuario = %s AND id_curso = %s", (id_usuario, id_curso))
        else:
            cursor.execute("DELETE FROM Profesor WHERE id_usuario = %s", (id_usuario,))

        deleted = cursor.rowcount
        conn.commit()
        cursor.close()
        conn.close()

        if deleted == 0:
            return jsonify({"error": "No se encontró la asignación del profesor"}), 404

        return jsonify({"success": True, "message": "Profesor desasignado correctamente"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/desasignar-alumno', methods=['POST'])
def desasignar_alumno():
    try:
        data = request.json
        id_usuario = data.get('id_usuario')

        if not id_usuario:
            return jsonify({"error": "id_usuario requerido"}), 400

        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM Alumnos WHERE id_usuario = %s", (id_usuario,))
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({"success": True, "message": "Estudiante desasignado correctamente"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/admin/stats', methods=['GET'])
def get_admin_stats():
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        cursor.execute("SELECT COUNT(*) as total FROM Cursos")
        total_cursos = cursor.fetchone()['total']

        cursor.execute("SELECT COUNT(*) as total FROM Usuarios")
        total_usuarios = cursor.fetchone()['total']

        cursor.close()
        connection.close()

        return jsonify({
            "totalCursos": total_cursos,
            "totalUsuarios": total_usuarios
        }), 200

    except Exception as e:
        print(f"Error al obtener estadísticas: {e}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/student_stats/<int:id_usuario>', methods=['GET'])
def get_student_stats(id_usuario):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # 1. Obtener curso del estudiante
        cursor.execute("SELECT id_curso FROM Alumnos WHERE id_usuario = %s", (id_usuario,))
        alumno = cursor.fetchone()
        id_curso = alumno['id_curso'] if alumno else None

        # 2. Total de módulos del curso
        total_modulos = 0
        if id_curso:
            cursor.execute("SELECT COUNT(*) as total FROM Modulos WHERE id_curso = %s", (id_curso,))
            res = cursor.fetchone()
            total_modulos = res['total'] or 0

        # 3. Módulos con nota (completados)
        cursor.execute("SELECT COUNT(DISTINCT id_modulo) as hechos FROM Notas WHERE id_usuario = %s", (id_usuario,))
        res_hechos = cursor.fetchone()
        modulos_hechos = res_hechos['hechos'] or 0

        # 4. Porcentaje
        porcentaje_modulos = (modulos_hechos / total_modulos * 100) if total_modulos > 0 else 0

        # 5. Asistencia
        cursor.execute("SELECT asistio FROM Asistencia WHERE id_usuario = %s", (id_usuario,))
        registros_asist = cursor.fetchall()
        asistencias_si = sum(1 for r in registros_asist if r['asistio'] == 'SI')
        porcentaje_asist = (asistencias_si / len(registros_asist) * 100) if len(registros_asist) > 0 else 0

        # 6. Notas
        cursor.execute("SELECT nota FROM Notas WHERE id_usuario = %s", (id_usuario,))
        notas = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "notas": notas,
            "asistencia_porcentaje": f"{round(porcentaje_asist, 1)}%",
            "modulos_completados": f"{round(porcentaje_modulos, 1)}%",
            "total_modulos": total_modulos,
            "modulos_hechos": modulos_hechos
        })

    except Exception as e:
        print(f"Error en get_student_stats: {str(e)}")
        return jsonify({"success": False, "message": str(e)}), 500
    

@app.route('/get_usuarios/<rol_nombre>')
def get_usuarios(rol_nombre):
    db = None
    cursor = None
    try:
        db = get_db_connection()
        cursor = db.cursor(dictionary=True)
        query = """
            SELECT u.id_usuario, u.nombres, u.apellidos, u.correo, u.fecha_nacimiento, u.id_rol 
            FROM Usuarios u
            JOIN Roles r ON u.id_rol = r.id_rol
            WHERE r.nombre = %s
        """
        cursor.execute(query, (rol_nombre,))
        usuarios = cursor.fetchall()
        
        resultado = []
        for u in usuarios:
            resultado.append({
                "id_usuario": u['id_usuario'],
                "nombres": u['nombres'],
                "apellidos": u['apellidos'],
                "nombre_completo": f"{u['nombres']} {u['apellidos']}",
                "correo": u['correo'],
                "id_rol": u['id_rol'],
                "fecha_nacimiento": u['fecha_nacimiento'].strftime('%Y-%m-%d') if u['fecha_nacimiento'] else ""
            })
        return jsonify(resultado)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if cursor: cursor.close()
        if db: db.close()

@app.route('/actualizar_usuario/<int:id_usuario>', methods=['POST'])
def actualizar_usuario(id_usuario):
    db = None
    cursor = None
    try:
        datos = request.get_json()
        db = get_db_connection()
        cursor = db.cursor()
        query = """
            UPDATE Usuarios 
            SET nombres = %s, apellidos = %s, correo = %s, fecha_nacimiento = %s, id_rol = %s 
            WHERE id_usuario = %s
        """
        valores = (datos['nombres'], datos['apellidos'], datos['correo'], 
                   datos['fecha_nacimiento'], datos['id_rol'], id_usuario)
        cursor.execute(query, valores)
        db.commit()
        return jsonify({"status": "success"})
    except Exception as e:
        if db: db.rollback()
        return jsonify({"status": "error", "message": str(e)}), 500
    finally:
        if cursor: cursor.close()
        if db: db.close()

@app.route('/eliminar_usuario/<int:id_usuario>', methods=['DELETE'])
def eliminar_usuario(id_usuario):
    db = None
    cursor = None
    try:
        db = get_db_connection()
        cursor = db.cursor()
        
        # Eliminación directa por ID
        cursor.execute("DELETE FROM Usuarios WHERE id_usuario = %s", (id_usuario,))
        db.commit()
        
        return jsonify({"status": "success"})
    except Exception as e:
        if db: db.rollback()
        return jsonify({"status": "error", "message": str(e)}), 500
    finally:
        if cursor: cursor.close()
        if db: db.close()

@app.route('/actualizar_perfil/<int:id_usuario>', methods=['PUT'])
def actualizar_perfil(id_usuario):
    try:
        data = request.json
        nombres = data.get('nombres')
        apellidos = data.get('apellidos')
        correo = data.get('correo')
        fecha_nacimiento = data.get('fecha_nacimiento')
        nueva_clave = data.get('nueva_clave') or data.get('clave')

        conn = get_db_connection()
        cursor = conn.cursor()

        if nueva_clave:  # Solo actualizar contraseña si se envió
            hashed_password = hashlib.sha256(nueva_clave.encode('utf-8')).hexdigest()
            query = """
                UPDATE usuarios 
                SET nombres = %s, apellidos = %s, correo = %s, 
                    fecha_nacimiento = %s, clave = %s
                WHERE id_usuario = %s
            """
            cursor.execute(query, (nombres, apellidos, correo, fecha_nacimiento, hashed_password, id_usuario))
        else:
            query = """
                UPDATE usuarios 
                SET nombres = %s, apellidos = %s, correo = %s, 
                    fecha_nacimiento = %s
                WHERE id_usuario = %s
            """
            cursor.execute(query, (nombres, apellidos, correo, fecha_nacimiento, id_usuario))

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({
            "success": True, 
            "message": "Perfil actualizado correctamente"
        }), 200

    except Exception as e:
        print(f"Error actualizando perfil: {e}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/usuarios', methods=['GET'])
def obtener_todos_usuarios():

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        query = """
            SELECT 
                u.id_usuario,
                u.nombres,
                u.apellidos,
                u.correo,
                r.nombre AS rol
            FROM Usuarios u
            JOIN Roles r ON u.id_rol = r.id_rol
        """

        cursor.execute(query)
        usuarios = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "usuarios": usuarios
        }), 200

    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500


@app.route('/usuarios/<int:id_usuario>/rol', methods=['PUT'])
def actualizar_rol(id_usuario):
    try:
        data = request.json
        rol = data.get('rol')

        roles = {
            'admin': 1,
            'estudiante': 2,
            'profesor': 3
        }

        if rol not in roles:
            return jsonify({
                "success": False,
                "error": "Rol inválido"
            }), 400

        id_rol = roles[rol]

        conn = get_db_connection()
        cursor = conn.cursor()

        query = """
            UPDATE Usuarios
            SET id_rol = %s
            WHERE id_usuario = %s
        """

        cursor.execute(query, (id_rol, id_usuario))
        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "message": "Rol actualizado correctamente"
        }), 200

    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500
    
@app.route('/verificar_datos_vacios')
def verificar_datos_vacios():
    id_usuario = request.args.get('id_usuario')
    
    if not id_usuario:
        return jsonify({"error": "Falta el id de usuario"}), 400
        
    try:
        conn = get_db_connection()
        # Usamos dictionary=True para poder leer los campos por su nombre
        cursor = conn.cursor(dictionary=True)
        
        # Traemos todos los campos obligatorios del perfil
        query = """
            SELECT Sexo, tipo_documento, numero_documento, departamento, 
                   municipio, direccion, telefono, telefono_emergencia, Estrato, eps 
            FROM DatosUsuarios 
            WHERE id_usuario = %s
        """
        cursor.execute(query, (id_usuario,))
        registro = cursor.fetchone()
        
        cursor.close()
        conn.close()
        
        # Caso 1: Ni siquiera tiene una fila creada en la tabla DatosUsuarios
        if registro is None:
            return jsonify({"vacios": True, "mensaje": "Por favor, complete su perfil de estudiante."})
            
        # Lista de campos que queremos verificar estrictamente uno por uno
        campos_a_verificar = [
            'Sexo', 'tipo_documento', 'numero_documento', 'departamento', 
            'municipio', 'direccion', 'telefono', 'telefono_emergencia', 'Estrato', 'eps'
        ]
        
        # Caso 2: La fila existe, pero iteramos para revisar si algún campo está vacío o NULL
        for campo in campos_a_verificar:
            valor = registro.get(campo)
            if valor is None or str(valor).strip() == "":
                return jsonify({"vacios": True, "mensaje": f"El campo '{campo}' está incompleto. Debe actualizar su perfil."})
                
        # Caso 3: Encontró la fila y absolutamente todos los campos tienen datos
        return jsonify({"vacios": False})

    except Exception as err:
        return jsonify({"error": f"Error interno: {str(err)}"}), 500   

@app.route('/completar-perfil')
def completar_perfil():
    # Capturamos el id_usuario que mandamos desde el window.location.href
    id_usuario = request.args.get('id_usuario')
    
    if not id_usuario:
        return "Error: ID de usuario no proporcionado", 400
        
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        # Consultamos los datos actuales de la cuenta del usuario para pre-llenar el formulario limpio
        query = """
            SELECT u.id_usuario, u.nombres, u.apellidos, u.correo, u.fecha_nacimiento, r.nombre AS rol 
            FROM Usuarios u
            JOIN Roles r ON u.id_rol = r.id_rol
            WHERE u.id_usuario = %s
        """
        cursor.execute(query, (id_usuario,))
        user_data = cursor.fetchone()
        
        cursor.close()
        conn.close()
        
        if not user_data:
            return "Usuario no encontrado", 404
            
        # Renderizamos tu nueva plantilla HTML pasándole los datos del usuario
        return render_template('view/datosPersonales.html', user=user_data)

    except mysql.connector.Error as err:
        return f"Error en la base de datos: {str(err)}", 500
    


@app.route('/obtener_perfil_completo')
def obtener_perfil_completo():
    # 1. Capturamos el id_usuario que viene en la URL (?id_usuario=X)
    id_usuario = request.args.get('id_usuario')
    
    if not id_usuario:
        return jsonify({"error": "ID de usuario no proporcionado"}), 400
        
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        # 2. Consulta SQL con LEFT JOIN 
        # Esto asegura que si la tabla DatosUsuarios está vacía, igual traiga los Datos de Cuenta
        query = """
            SELECT 
                u.id_usuario, u.nombres, u.apellidos, u.correo, u.fecha_nacimiento, 
                r.nombre AS rol,
                d.id_datos_usuario, d.estado, d.Sexo, d.tipo_documento, 
                d.numero_documento, d.departamento, d.municipio, d.direccion, 
                d.telefono, d.telefono_emergencia, d.Estrato, d.eps
            FROM Usuarios u
            JOIN Roles r ON u.id_rol = r.id_rol
            LEFT JOIN DatosUsuarios d ON u.id_usuario = d.id_usuario
            WHERE u.id_usuario = %s
        """
        cursor.execute(query, (id_usuario,))
        usuario = cursor.fetchone()
        
        cursor.close()
        conn.close()
        
        # 3. Si el usuario existe, procesamos y respondemos
        if usuario:
            # Formateamos la fecha de nacimiento a 'YYYY-MM-DD' para que el input type="date" la reconozca
            if usuario['fecha_nacimiento']:
                usuario['fecha_nacimiento'] = usuario['fecha_nacimiento'].strftime('%Y-%m-%d')
            
            # Si el estado viene como None (porque la tabla DatosUsuarios estaba vacía), le ponemos 'Pendiente'
            if not usuario['estado']:
                usuario['estado'] = 'Pendiente'
                
            return jsonify(usuario)
        else:
            return jsonify({"error": "Usuario no encontrado en el sistema"}), 404

    except Exception as err:
        return jsonify({"error": f"Error en el servidor o base de datos: {str(err)}"}), 500

# 2. RUTA PARA GUARDAR LOS DATOS ACTUALIZADOS
@app.route('/guardar_datos_perfil', methods=['POST'])
def guardar_datos_perfil():
    datos = request.get_json()
    
    campos_obligatorios = [
        'id_usuario', 'nombres', 'apellidos', 'correo', 'fecha_nacimiento',
        'sexo', 'tipo_documento', 'numero_documento', 'departamento',
        'municipio', 'direccion', 'telefono', 'telefono_emergencia', 'estrato', 'eps'
    ]
    
    # 1. Validación de campos vacíos
    for campo in campos_obligatorios:
        if not datos.get(campo) or str(datos.get(campo)).strip() == "":
            return jsonify({"exito": False, "tipo_error": "advertencia", "mensaje": "Todos los campos son estrictamente obligatorios."}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True) # Usamos dictionary=True para leer fácil por nombre de columna
        
        # 2. NUEVA VALIDACIÓN: Verificar si el documento ya existe en OTRO usuario
        query_verificar_doc = """
            SELECT id_usuario FROM DatosUsuarios 
            WHERE numero_documento = %s AND id_usuario != %s
        """
        cursor.execute(query_verificar_doc, (datos['numero_documento'], datos['id_usuario']))
        documento_duplicado = cursor.fetchone()
        
        if documento_duplicado:
            cursor.close()
            conn.close()
            # Retornamos un flag "tipo_error" para que JS sepa que debe ser un Toast Amarillo
            return jsonify({
                "exito": False, 
                "tipo_error": "advertencia", 
                "mensaje": f"El número de documento {datos['numero_documento']} ya se encuentra registrado en el sistema por otro usuario."
            }), 200 # Lo enviamos con 200 para que el .then() de JS lo procese limpiamente

        # 3. Actualizar Datos de Cuenta básicos en Usuarios
        query_usuarios = """
            UPDATE Usuarios 
            SET nombres = %s, apellidos = %s, correo = %s, fecha_nacimiento = %s
            WHERE id_usuario = %s
        """
        cursor.execute(query_usuarios, (datos['nombres'], datos['apellidos'], datos['correo'], datos['fecha_nacimiento'], datos['id_usuario']))

        # 4. Verificar si ya existe fila en DatosUsuarios para el usuario actual
        cursor.execute("SELECT id_datos_usuario FROM DatosUsuarios WHERE id_usuario = %s", (datos['id_usuario'],))
        existe_perfil = cursor.fetchone()
        
        if existe_perfil:
            # UPDATE
            query_datos = """
                UPDATE DatosUsuarios 
                SET Sexo = %s, tipo_documento = %s, numero_documento = %s, departamento = %s, 
                    municipio = %s, direccion = %s, telefono = %s, telefono_emergencia = %s, 
                    Estrato = %s, eps = %s, estado = 'Activo'
                WHERE id_usuario = %s
            """
            cursor.execute(query_datos, (
                datos['sexo'], datos['tipo_documento'], datos['numero_documento'], datos['departamento'],
                datos['municipio'], datos['direccion'], datos['telefono'], datos['telefono_emergencia'],
                datos['estrato'], datos['eps'], datos['id_usuario']
            ))
        else:
            # INSERT
            query_datos = """
                INSERT INTO DatosUsuarios (id_usuario, Sexo, tipo_documento, numero_documento, departamento, 
                                          municipio, direccion, telefono, telefono_emergencia, Estrato, eps, estado)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'Activo')
            """
            cursor.execute(query_datos, (
                datos['id_usuario'], datos['sexo'], datos['tipo_documento'], datos['numero_documento'], 
                datos['departamento'], datos['municipio'], datos['direccion'], datos['telefono'], 
                datos['telefono_emergencia'], datos['estrato'], datos['eps']
            ))
            
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({"exito": True, "mensaje": "Perfil actualizado exitosamente."})

    except Exception as err:
        return jsonify({"exito": False, "tipo_error": "error", "mensaje": f"Error en el servidor: {str(err)}"}), 500

#Actualizar perfil flutter 
@app.route('/actualizar_perfil_completo/<int:id_usuario>', methods=['PUT'])
def actualizar_perfil_completo(id_usuario):
    try:
        data = request.json
        
        # 1. Obtener datos destinados a la tabla 'Usuarios'
        nombres = data.get('nombres')
        apellidos = data.get('apellidos')
        correo = data.get('correo')
        fecha_nacimiento = data.get('fecha_nacimiento')
        nueva_clave = data.get('nueva_clave') or data.get('clave')

        # 2. Obtener datos destinados a la tabla 'DatosUsuarios'
        direccion = data.get('direccion')
        departamento = data.get('departamento')
        municipio = data.get('municipio')
        telefono = data.get('telefono')
        telefono_emergencia = data.get('telefono_emergencia')
        tipo_documento = data.get('tipo_documento')
        numero_documento = data.get('numero_documento')
        estrato = data.get('estrato')
        sexo = data.get('sexo')
        eps = data.get('eps')

        conn = get_db_connection()
        cursor = conn.cursor()

        try:
            # 3. Actualizar datos en la tabla 'Usuarios'
            if nueva_clave:  
                hashed_password = hashlib.sha256(nueva_clave.encode('utf-8')).hexdigest()
                query_user = """
                    UPDATE Usuarios 
                    SET nombres = %s, apellidos = %s, correo = %s, fecha_nacimiento = %s, clave = %s
                    WHERE id_usuario = %s
                """
                cursor.execute(query_user, (nombres, apellidos, correo, fecha_nacimiento, hashed_password, id_usuario))
            else:            
                query_user = """
                    UPDATE Usuarios 
                    SET nombres = %s, apellidos = %s, correo = %s, fecha_nacimiento = %s
                    WHERE id_usuario = %s
                """
                cursor.execute(query_user, (nombres, apellidos, correo, fecha_nacimiento, id_usuario))

            # 4. Verificar si el usuario ya tiene una fila creada en 'DatosUsuarios'
            cursor.execute("SELECT id_datos_usuario FROM DatosUsuarios WHERE id_usuario = %s", (id_usuario,))
            existe_registro_datos = cursor.fetchone()

            if existe_registro_datos:
                query_datos = """
                    UPDATE DatosUsuarios 
                    SET direccion = %s, departamento = %s, municipio = %s, telefono = %s, 
                        telefono_emergencia = %s, tipo_documento = %s, numero_documento = %s, 
                        Estrato = %s, Sexo = %s, eps = %s
                    WHERE id_usuario = %s
                """
                cursor.execute(query_datos, (direccion, departamento, municipio, telefono, 
                                             telefono_emergencia, tipo_documento, numero_documento, 
                                             estrato, sexo, eps, id_usuario))
            else:
                query_datos = """
                    INSERT INTO DatosUsuarios (estado, direccion, departamento, municipio, telefono, 
                                               telefono_emergencia, tipo_documento, numero_documento, Estrato, Sexo, eps, id_usuario)
                    VALUES ('Activo', %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """
                cursor.execute(query_datos, (direccion, departamento, municipio, telefono, 
                                             telefono_emergencia, tipo_documento, numero_documento, 
                                             estrato, sexo, eps, id_usuario))

            conn.commit()

        # --- CAPTURA DE ERROR CORREGIDA PARA CUALQUIER CONECTOR ---
        except Exception as db_error:
            conn.rollback()
            error_msg = str(db_error)
            
            # El código 1062 es universal en MySQL para entradas duplicadas (Unique Key)
            if "1062" in error_msg:
                if 'numero_documento' in error_msg:
                    return jsonify({
                        "success": False, 
                        "error": "El número de documento ya está registrado por otro usuario."
                    }), 400
                elif 'correo' in error_msg:
                    return jsonify({
                        "success": False, 
                        "error": "El correo electrónico ya está registrado por otro usuario."
                    }), 400
            
            # Si es otro error de base de datos lo mandamos directamente
            return jsonify({"success": False, "error": f"Error interno en base de datos: {error_msg}"}), 400

        finally:
            cursor.close()
            conn.close()

        return jsonify({
            "success": True, 
            "message": "Todos los datos del perfil se han actualizado con éxito"
        }), 200

    except Exception as e:
        print(f"Error en actualizar_perfil_completo: {e}")
        return jsonify({"success": False, "error": str(e)}), 500
    

#mostrar datos del perfil completo flutter
@app.route('/obtener_datos_adicionales/<int:id_usuario>', methods=['GET'])
def obtener_datos_adicionales(id_usuario):
    try:
        conn = get_db_connection()
        # Usamos el cursor normal para evitar problemas de compatibilidad con DictCursor
        cursor = conn.cursor()

        # Seleccionamos las columnas explícitamente en un orden conocido
        query = """
            SELECT direccion, departamento, municipio, telefono, 
                   telefono_emergencia, tipo_documento, numero_documento, 
                   Estrato, Sexo, eps 
            FROM DatosUsuarios 
            WHERE id_usuario = %s
        """
        cursor.execute(query, (id_usuario,))
        row = cursor.fetchone()

        cursor.close()
        conn.close()

        if row:
            # Construimos el diccionario manualmente mapeando cada posición de la tupla
            datos = {
                "direccion": row[0],
                "departamento": row[1],
                "municipio": row[2],
                "telefono": row[3],
                "telefono_emergencia": row[4],
                "tipo_documento": row[5],
                "numero_documento": row[6],
                "Estrato": row[7],
                "Sexo": row[8],
                "eps": row[9]
            }
            return jsonify({
                "success": True,
                "existe": True,
                "data": datos
            }), 200
        else:
            return jsonify({
                "success": True,
                "existe": False,
                "data": {}
            }), 200

    except Exception as e:
        # Esto imprimirá el error exacto en tu consola de Python si algo más ocurre
        print(f"Error detallado en el servidor: {e}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/get_usuarios/coordinador', methods=['GET'])
def get_coordinadores():
    connection = None
    cursor = None
    try:
        # Abrimos la conexión usando tu función
        connection = get_db_connection()
        
        # 'dictionary=True' hace que mysql.connector devuelva los datos como dict en vez de tuplas
        cursor = connection.cursor(dictionary=True) 
        
        query = """
            SELECT 
                id_usuario, 
                nombres, 
                apellidos, 
                CONCAT(nombres, ' ', apellidos) AS nombre_completo, 
                correo, 
                DATE_FORMAT(fecha_nacimiento, '%Y-%m-%d') AS fecha_nacimiento, 
                id_rol 
            FROM Usuarios 
            WHERE id_rol = 4
        """
        cursor.execute(query)
        coordinadores = cursor.fetchall()
        
        return jsonify(coordinadores), 200
        
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
        
    finally:
        # Buena práctica: Cerramos cursor y conexión siempre al terminar
        if cursor:
            cursor.close()
        if connection and connection.is_connected():
            connection.close()


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
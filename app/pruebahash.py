import mysql.connector

def conectar_base_datos():
    # Configura las credenciales de la base de datos
    db_config = {
        'host': 'localhost',
        'user': 'root',
        'password': 'password',
        'database': 'myapp',  # Reemplaza con el nombre de tu base de datos
    }

    # Conecta a la base de datos
    conn = mysql.connector.connect(**db_config)
    return conn

def cerrar_conexion(conn):
    # Cierra la conexión a la base de datos
    conn.close()

def registrar_usuario(usuario, contraseña):
    # Conecta a la base de datos
    conn = conectar_base_datos()

    try:
        # Ejecuta el procedimiento almacenado para insertar un usuario
        cursor = conn.cursor()
        cursor.callproc('InsertarUsuarioConSalt', (usuario, contraseña))
        conn.commit()
        cursor.close()

        print(f"Usuario '{usuario}' registrado exitosamente.")
    except Exception as e:
        print(f"Error al registrar el usuario: {e}")
    finally:
        # Cierra la conexión a la base de datos
        cerrar_conexion(conn)

def validar_login(usuario, contraseña):
    # Conecta a la base de datos
    conn = conectar_base_datos()

    try:
        # Ejecuta la función para validar el inicio de sesión
        cursor = conn.cursor()
        cursor.execute("SELECT ValidarLogin(%s, %s)", (usuario, contraseña))
        result = cursor.fetchone()

        if result:
            if result[0] == 1:
                print(f"Inicio de sesión exitoso para el usuario '{usuario}'.")
            else:
                print(f"Error: Usuario '{usuario}' o contraseña incorrectos.")
        else:
            print(f"Error: Usuario '{usuario}' no encontrado.")
    except Exception as e:
        print(f"Error al validar el inicio de sesión: {e}")
    finally:
        # Cierra la conexión a la base de datos
        cerrar_conexion(conn)

# Ejemplo de uso
#registrar_usuario("usuario_prueba23", "contraseña_prueba")
validar_login("usuario_prueba23", "contraseña_prueba")

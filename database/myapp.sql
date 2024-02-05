-- Crear la base de datos
-- drop database myapp;
CREATE DATABASE IF NOT EXISTS myapp;
-- Usar la base de datos
USE myapp;

-- Crear la tabla de usuarios con salt y restricción de unicidad en el usuario
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(255) NOT NULL,
    contraseña VARBINARY(255) NOT NULL,
    salt VARCHAR(255) NOT NULL,
    CONSTRAINT unique_usuario UNIQUE (usuario)
);

-- Procedimiento almacenado para insertar un nuevo usuario con salt
DELIMITER $$

CREATE PROCEDURE InsertarUsuarioConSalt(
    IN p_usuario VARCHAR(255),
    IN p_contraseña VARCHAR(255)
)
BEGIN
    DECLARE v_salt VARCHAR(255);

    -- Generar un salt aleatorio
    SET v_salt = SUBSTRING(MD5(RAND()), 1, 16);

    -- Encriptar la contraseña con el salt
    SET p_contraseña = CONCAT(v_salt, p_contraseña);
    SET p_contraseña = SHA2(p_contraseña, 256);

    -- Insertar el usuario en la tabla
    INSERT INTO usuarios (usuario, contraseña, salt) VALUES (p_usuario, p_contraseña, v_salt);
END $$

DELIMITER ;

-- Función para validar un usuario y contraseña
DELIMITER $$

CREATE FUNCTION ValidarLogin(
    p_usuario VARCHAR(255),
    p_contraseña VARCHAR(255)
)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_salt VARCHAR(255);
    DECLARE v_contraseña_encriptada VARCHAR(255);

    -- Obtener el salt correspondiente al usuario
    SELECT salt INTO v_salt FROM usuarios WHERE usuario = p_usuario;

    -- Si el usuario no existe, la validación falla
    IF v_salt IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Encriptar la contraseña ingresada con el salt almacenado
    SET p_contraseña = CONCAT(v_salt, p_contraseña);
    SET v_contraseña_encriptada = SHA2(p_contraseña, 256);

    -- Validar la contraseña encriptada
    RETURN EXISTS (
        SELECT 1
        FROM usuarios
        WHERE usuario = p_usuario AND contraseña = v_contraseña_encriptada
    );
END $$

DELIMITER ;
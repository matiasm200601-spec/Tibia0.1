-- Script de reparación para la base de datos del OT Server
-- Esto recreará la tabla accounts con la estructura correcta

-- Verificar integridad
PRAGMA integrity_check;

-- Crear backup de la tabla actual
DROP TABLE IF EXISTS accounts_backup;
CREATE TABLE accounts_backup AS SELECT * FROM accounts;

-- Recrear la tabla accounts con estructura limpia
DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(32) NOT NULL DEFAULT '',
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL DEFAULT '',
    premdays INTEGER NOT NULL DEFAULT 0,
    lastday INTEGER UNSIGNED NOT NULL DEFAULT 0,
    key VARCHAR(20) NOT NULL DEFAULT '0',
    blocked TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'internal usage',
    warnings INTEGER NOT NULL DEFAULT 0,
    group_id INTEGER NOT NULL DEFAULT 1
);

-- Crear índice único para el nombre
CREATE UNIQUE INDEX account_name_unique ON accounts(name);

-- Restaurar datos desde el backup
INSERT INTO accounts (id, name, password, email, premdays, lastday, key, blocked, warnings, group_id)
SELECT id, name, password, email, premdays, lastday, key, blocked, warnings, group_id 
FROM accounts_backup;

-- Verificar que los datos se restauraron correctamente
SELECT COUNT(*) as total_accounts FROM accounts;

-- Limpiar
DROP TABLE accounts_backup;

-- Verificar integridad final
PRAGMA integrity_check;

SELECT 'Base de datos reparada exitosamente!' as resultado;

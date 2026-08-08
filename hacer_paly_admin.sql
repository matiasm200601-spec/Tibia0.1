-- Hacer al jugador "Paly" administrador (God)
-- Group ID 6 = God/Administrator

-- Ver estado actual
SELECT name, group_id, level, vocation FROM players WHERE name = 'Paly';

-- Cambiar group_id a 6 (God)
UPDATE players 
SET group_id = 6
WHERE name = 'Paly';

-- Verificar cambio
SELECT name, group_id, level, vocation FROM players WHERE name = 'Paly';

-- Información de grupos:
-- group_id = 1: Player (jugador normal)
-- group_id = 2: Tutor
-- group_id = 3: Senior Tutor
-- group_id = 4: Gamemaster
-- group_id = 5: Community Manager
-- group_id = 6: God/Administrator

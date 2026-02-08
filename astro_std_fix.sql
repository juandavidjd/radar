-- Detectar y eliminar vista o tabla astro_luna_std de forma segura
PRAGMA writable_schema=1;

-- Si existe como vista:
DELETE FROM sqlite_master WHERE type='view' AND name='astro_luna_std';

-- Si existe como tabla:
DELETE FROM sqlite_master WHERE type='table' AND name='astro_luna_std';

PRAGMA writable_schema=0;
VACUUM;
PRAGMA integrity_check;

-- >>>>>> RECREAR astro_luna_std AQUÍ (ajusta a tu definición real) <<<<<<
CREATE VIEW astro_luna_std AS
SELECT fecha,
       CAST(num AS TEXT) AS num,
       signo,
       'astro_luna' AS juego
FROM astro_luna
WHERE num IS NOT NULL;

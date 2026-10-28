# =====================================================================
# Consultas analíticas clave (se ejecutan sobre la base udg_analisis)
# Todas excluyen programas virtuales (es_virtual = 0): su puntaje es fijo.
# =====================================================================
USE udg_analisis;

# 1. Totales globales 2015-2025 y tasa de admisión
SELECT
    SUM(a.aspirantes)                                AS total_aspirantes,
    SUM(a.admitidos)                                 AS total_admitidos,
    ROUND(SUM(a.admitidos) / SUM(a.aspirantes) * 100, 2) AS tasa_admision
FROM admision a
JOIN carrera ca ON a.id_carrera = ca.id_carrera
WHERE ca.es_virtual = 0;

# 2. Evolución anual: aspirantes, admitidos, cupo y tasa
SELECT
    ce.año,
    SUM(a.aspirantes) AS aspirantes,
    SUM(a.admitidos)  AS admitidos,
    SUM(a.cupo)       AS cupo,
    ROUND(SUM(a.admitidos) / SUM(a.aspirantes) * 100, 2) AS tasa_admision
FROM admision a
JOIN carrera ca       ON a.id_carrera = ca.id_carrera
JOIN ciclo_escolar ce ON a.id_ciclo   = ce.id_ciclo
WHERE ca.es_virtual = 0
GROUP BY ce.año
ORDER BY ce.año;

# 3. Comparativo por periodo: pre-pandemia, pandemia y post-pandemia
SELECT
    CASE WHEN ce.año <= 2019 THEN '1. Pre-pandemia (2015-2019)'
         WHEN ce.año <= 2021 THEN '2. Pandemia (2020-2021)'
         ELSE                     '3. Post-pandemia (2022-2025)' END AS etapa,
    SUM(a.aspirantes) AS aspirantes,
    SUM(a.admitidos)  AS admitidos,
    SUM(a.cupo)       AS cupo,
    ROUND(AVG(a.puntaje_minimo), 2) AS puntaje_minimo_promedio,
    ROUND(SUM(a.admitidos) / SUM(a.aspirantes) * 100, 2) AS tasa_admision
FROM admision a
JOIN carrera ca       ON a.id_carrera = ca.id_carrera
JOIN ciclo_escolar ce ON a.id_ciclo   = ce.id_ciclo
WHERE ca.es_virtual = 0
GROUP BY etapa
ORDER BY etapa;

# 4. Carreras con mayor caída de aspirantes, 2019 vs 2025
SELECT
    t.carrera,
    t.asp_2019,
    t.asp_2025,
    ROUND((t.asp_2025 - t.asp_2019) / t.asp_2019 * 100, 1) AS cambio_pct
FROM (
    SELECT
        ca.nombre AS carrera,
        SUM(CASE WHEN ce.año = 2019 THEN a.aspirantes END) AS asp_2019,
        SUM(CASE WHEN ce.año = 2025 THEN a.aspirantes END) AS asp_2025
    FROM admision a
    JOIN carrera ca       ON a.id_carrera = ca.id_carrera
    JOIN ciclo_escolar ce ON a.id_ciclo   = ce.id_ciclo
    WHERE ca.es_virtual = 0 AND ce.año IN (2019, 2025)
    GROUP BY ca.nombre
) t
WHERE t.asp_2019 IS NOT NULL AND t.asp_2025 IS NOT NULL
ORDER BY cambio_pct
LIMIT 10;

# 5. Control de calidad: registros con más admitidos que aspirantes
SELECT
    ce.año,
    COUNT(*) AS registros_con_admitidos_mayor_que_aspirantes
FROM admision a
JOIN carrera ca       ON a.id_carrera = ca.id_carrera
JOIN ciclo_escolar ce ON a.id_ciclo   = ce.id_ciclo
WHERE ca.es_virtual = 0 AND a.admitidos > a.aspirantes
GROUP BY ce.año
ORDER BY ce.año;

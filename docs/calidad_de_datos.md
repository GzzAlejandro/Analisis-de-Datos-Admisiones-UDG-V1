# Calidad de datos: problemas encontrados y cómo se trataron

Los archivos de resultados de admisión de la UdeG
([escolar.udg.mx/estadisticas-puntajes-minimos](https://escolar.udg.mx/estadisticas-puntajes-minimos))
no están estandarizados. Parte del trabajo de este proyecto fue limpiar, normalizar y cargar 2015-2025 en una base relacional (MySQL).

## Problemas en las fuentes oficiales

|#|Problema|Tratamiento|
|-|-|-|
|1|**Ciclo 2017A:** el portal publicó en la sección de 2017A el mismo archivo que 2017B.|Para corregir esto se accedió a la base de datos de Transparencia UDG (https://transparencia.udg.mx/datos-abiertos/datos\_abiertos\_control\_escolar) y acceder a una base de datos especifica la cual muestra los puntajes minimos de 2016By 2017A|
|2|**Más admitidos que aspirantes (2020):** 109 registros carrera-ciclo en 2020 tienen más admitidos que aspirantes (tasas de hasta 1,000%). El reporte lo atribuye al proceso de admisión de emergencia al inicio del confinamiento.|Se conservan en la base; `no\_admitidos` se fija en 0 cuando sale negativo|
|3|**Formatos de columnas:** al menos 5 estructuras distintas entre 2015 y 2025.|Un método de lectura por formato en el proceso de carga|
|4|**Nombres de carreras inconsistentes:** la misma carrera aparece hasta con 4 variantes (por ejemplo `LICENCIADO EN BIOLOGIA` y `LICENCIATURA EN BIOLOGIA`).|Mapa de normalización de nombres|
|5|**Nombres de centros inconsistentes:** antes de 2019 los centros regionales no usaban el prefijo CU (`ALTOS` en lugar de `CUALTOS`).|Normalizados al nombre oficial|
|6|**Caracteres corruptos:** el reporte 2016B tiene `Ñ` dañada (`DISEÃ'O` en lugar de `DISEÑO`).|Corregidos al cargar|
|7|**Fila de totales dentro de los datos:** algunos reportes de CUVALLES incluían una fila `TOTALES` como si fuera una carrera.|Excluida|
|8|**Deserción y egreso:** los informes de rectoría dan cifras aproximadas ("aproximadamente desertaron X") y los de ciclos antiguos son difíciles de encontrar.|Las tablas `desercion` y `egreso` existen en el esquema pero quedaron vacías: no hay datos viables|

## Decisiones de análisis

* **Programas virtuales excluidos** (`es\_virtual = 0`): tienen puntaje mínimo fijo de 60 y no son comparables en selectividad.
* **Periodos:** pre-pandemia 2015-2019 (5 años), pandemia 2020-2021 (2 años), post-pandemia 2022-2025 (4 años). Los totales absolutos no son directamente comparables entre periodos; las tasas sí.
* **Cobertura:** la tabla `admision` cubre 2015-2025 (22 ciclos). El catálogo de ciclos llega hasta 2005, pero los datos de 2005-2014 no se cargaron.

## Verificaciones realizadas

Al reconstruir la base desde `sql/01\_schema.sql` y `sql/02\_datos.sql`, el notebook `01\_analisis\_red\_udg.ipynb` reproduce las cifras del reporte:
891,574 aspirantes, 356,073 admitidos, 39.94% de tasa global, 91,022 aspirantes en 2020 y la tabla de indicadores por periodo.

## Pendientes conocidos (se atenderán en la V2)

* Quedan **nombres sin normalizar** en la base: `LICENCIATURA EN DISELO DE INTERIORES  Y AMBIENTACION` (error de captura, variante de `DISEÑO DE INTERIORES Y AMBIENTACION`), un nombre de Humanidades con texto concatenado y espacios dobles en `PSICOLOGIA DE  LA  SALUD COMUNITARIA`.
* Algunos programas pueden ser **el mismo programa con distinto nombre** (por ejemplo, `INGENIERIA EN ELECTRONICA Y SISTEMAS INTELIGENTES` y `LICENCIATURA EN INGENIERIA EN ELECTRONICA Y SISTEMAS INTELIGENTES`). Consolidarlos afectaría los comparativos por carrera.
* La columna `carrera.area\_conocimiento` existe pero **no está poblada**: la clasificación por áreas que aparece en el reporte no está versionada en este repositorio.
* Hay 3 registros con más admitidos que aspirantes fuera de 2020 (uno en 2018 y dos en 2019, por pocas unidades): revisar contra la fuente.


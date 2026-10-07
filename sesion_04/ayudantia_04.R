# Ayudantía 04: Estadística I - Ciencia Política UAH ----------------------

# Autor: Diego Iturrieta
# Base de datos: Encuesta CEP N°94 (mayo-junio 2025, ISSP Orientaciones laborales)
# https://www.cepchile.cl/encuesta/encuesta-cep-n-94-mayo-junio-2025-issp-orientaciones-laborales/

# Contenidos:
# PARTE I  (procedimiento): RProject, librerías, carga, revisión y procesamiento de datos.
# PARTE II (análisis):      frecuencias, tablas de contingencia, gráficos con ggplot2
#                           y medidas de tendencia central (media, mediana y moda).

# Flujo de trabajo --------------------------------------------------------

# Todo análisis en R sigue el mismo orden. Si respetamos este orden, cualquier
# persona (incluido/a tú en un mes más) puede abrir el script y reproducirlo.
#
#   1. RProject         -> dónde trabajamos.
#   2. Librerías        -> con qué herramientas trabajamos.
#   3. Cargar datos     -> qué datos usamos.
#   4. Revisar datos    -> cómo vienen los datos.
#   5. Procesar datos   -> dejar los datos listos para analizar.
#   ------------------- (desde aquí no se modifican los datos, solo se analizan)
#   6. Frecuencias
#   7. Tablas de contingencia
#   8. Visualizar con ggplot2
#   9. Medidas de tendencia central
#  10. Preguntas

# Para ver el índice del script: botón "Outline" (arriba a la derecha del script)
# o Ctrl + Shift + O. Cada línea que termina en "----" es una sección.


# PARTE I: PROCEDIMIENTO --------------------------------------------------


# 1. RProject -------------------------------------------------------------

# Un RProject es una carpeta que R reconoce como "lugar de trabajo". Al abrir
# el proyecto, R sabe automáticamente dónde están nuestros archivos, por lo que
# no necesitamos setwd() ni rutas largas como "C:/Users/.../Desktop".
#
# Pasos (se hacen una sola vez):
#   a) File > New Project > New Directory > New Project.
#   b) Nombre del proyecto: ayudantia_04. Elegir dónde guardarlo > Create Project.
#   c) Dentro de la carpeta del proyecto crear una carpeta llamada "datos".
#   d) Guardar base_94.Rds dentro de "datos".
#   e) Guardar este script en la carpeta del proyecto.
#
# Estructura esperada:
#   ayudantia_04/                  <- carpeta del proyecto
#       ayudantia_04.Rproj         <- se abre con doble clic para trabajar
#       ayudantia_04_UAH.R         <- este script
#       datos/                     <- carpeta de datos
#           base_94.Rds

# 2. Cargar librerías -----------------------------------------------------

# pacman revisa si cada librería está instalada: si no lo está, la instala;
# si ya lo está, solo la carga. Si nunca han usado pacman: install.packages("pacman")

pacman::p_load(tidyr,     # ordenar datos (ej. drop_na() para sacar casos perdidos).
               dplyr,     # manipular datos: select(), filter(), mutate(), count(), summarise().
               ggplot2,   # crear gráficos.
               haven,     # leer datos con etiquetas (Stata, SPSS) y usar as_factor().
               srvyr,     # calcular estadísticos ponderados en datos tipo encuesta.
               DescTools) # funciones estadísticas; la usaremos para la moda: Mode().

# pacman::p_load(tidyr, dplyr, ggplot2, haven, srvyr)


options(scipen = 999) # evita que R muestre resultados en notación científica (ej. 1e-04).

# Para profundizar: ¿Qué hace cada librería? -----------------------------

# tidyr:     https://tidyr.tidyverse.org/
# dplyr:     https://dplyr.tidyverse.org/
# ggplot2:   https://ggplot2.tidyverse.org/
# haven:     https://haven.tidyverse.org/
# srvyr:     http://gdfe.co/srvyr/
# DescTools: https://andrisignorell.github.io/DescTools/

# 3. Cargar datos ---------------------------------------------------------

data <- readRDS("base_94.Rds") # ruta relativa: parte desde la carpeta del proyecto.

# 4. Revisar datos --------------------------------------------------------

dim(data)      # filas (personas encuestadas) y columnas (variables): 1507 x 214.
colnames(data) # nombre de todas las variables.
glimpse(data)  # cada variable, su tipo y sus primeros valores.

# Las variables de la CEP vienen "etiquetadas" (haven_labelled): guardan un
# número, pero cada número tiene una etiqueta. Para ver qué significa cada código:

attr(data$eval_gob_1, "label")  # la pregunta.
attr(data$eval_gob_1, "labels") # los códigos y sus etiquetas.

table(data$eval_gob_1) # frecuencia de cada código.

# Ojo: -9 = "No contesta" y -8 = "No sabe". No son respuestas válidas.
# Si no los transformamos en NA (dato perdido), R los usará como números
# y, por ejemplo, la media de la escala izquierda-derecha quedaría mal calculada.
# Siempre revisar el diccionario de variables y el manual de usuario de la CEP.

# 5. Procesar datos (opcional) -------------------------------------------

# En un solo bloque, unido con el pipe %>% ("y luego"), vamos a:
#   a) select():  quedarnos solo con las variables que usaremos y darles nombres claros.
#   b) mutate():  transformar -9 y -8 en NA.
#   c) mutate():  convertir las variables categóricas en factor, para que R
#                 muestre etiquetas ("Aprueba") en vez de códigos (1).

datos_proc <- data %>%
  select(sexo     = sexo,           # Sexo (Hombre / Mujer). Nominal.
         edad     = edad,           # Edad en años. Razón (numérica).
         gse      = gse,            # Grupo socioeconómico (ABC1 a E). Ordinal.
         zona     = zona_u_r,       # Zona urbana / rural. Nominal.
         eval_gob = eval_gob_1,     # Aprueba / desaprueba al gobierno. Nominal.
         pais     = percepcion_4,   # Chile está progresando / estancado / en decadencia. Ordinal.
         pos_pol  = iden_pol_2,     # Escala izquierda (1) - derecha (10). Ordinal tratada como numérica.
         n_hogar  = info_hogar_1,   # N° de personas en el hogar. Razón (numérica).
         pond, estrato, secu) %>%   # variables de diseño muestral (para ponderar).
  mutate(across(c(eval_gob, pais, pos_pol),
                ~ replace(.x, .x %in% c(-9, -8), NA))) %>%  # -9 y -8 pasan a NA.
  mutate(across(c(sexo, gse, zona, eval_gob, pais),
                ~ droplevels(as_factor(.x))))               # números -> etiquetas.
# droplevels() elimina categorías que quedaron vacías ("No sabe", "No contesta").

# pos_pol queda numérica para poder calcular media y mediana, pero le sacamos
# las etiquetas para que R la trate solo como número:
datos_proc <- datos_proc %>%
  mutate(pos_pol = as.numeric(zap_labels(pos_pol)))

# Comprobamos el resultado


glimpse(datos_proc)         # sexo, gse, zona, eval_gob y pais ahora son <fct> (factor).
colSums(is.na(datos_proc))  # cuántos NA quedaron en cada variable.

# Guardamos la base procesada. Así, en la próxima ayudantía partimos desde aquí.
saveRDS(datos_proc, "base_94_proc.Rds")

# Declaramos el diseño muestral (lo sugiere CEP en su manual de usuario).
# Lo usaremos para obtener resultados representativos de la población.
cep <- datos_proc %>%
  as_survey(weights = pond, strata = estrato, ids = secu, nest = TRUE)


# PARTE II: ANÁLISIS ESTADÍSTICO ------------------------------------------


# 6. Tablas de frecuencia (una variable) ----------------------------------

# Frecuencia absoluta: cuántas personas hay en cada categoría.
table(datos_proc$eval_gob)

# Frecuencia relativa: qué proporción representa cada categoría (suma 1).
prop.table(table(datos_proc$eval_gob))

# En porcentaje y con 1 decimal (suma 100).
round(prop.table(table(datos_proc$eval_gob)) * 100, 1)

# La misma tabla con dplyr: n = frecuencia absoluta, porcentaje = relativa.
datos_proc %>%
  drop_na(eval_gob) %>%                         # sacamos los NA.
  count(eval_gob) %>%                           # cuenta casos por categoría.
  mutate(porcentaje = round(n / sum(n) * 100, 1))

# 7. Tablas de contingencia (dos variables) -------------------------------

# Una tabla de contingencia cruza dos variables categóricas. Cada celda
# indica cuántos casos tienen, al mismo tiempo, una categoría de la variable
# en filas y una categoría de la variable en columnas.
#
# Regla práctica: la variable que "explica" (independiente) va en las filas
# y la que queremos explicar (dependiente) va en las columnas.
# Pregunta: ¿la evaluación del gobierno es distinta entre hombres y mujeres?
#   filas    = sexo      (independiente)
#   columnas = eval_gob  (dependiente)

# 7.1 Frecuencias absolutas

tabla_sexo <- table(datos_proc$sexo, datos_proc$eval_gob) # table(FILAS, COLUMNAS)
tabla_sexo

addmargins(tabla_sexo) # agrega los totales ("Sum") por fila y por columna.

# 7.2 Porcentajes por fila (margin = 1): cada fila suma 100%.
# Se lee: "Del total de MUJERES, ¿qué % aprueba?". Compara hombres vs mujeres.

round(prop.table(tabla_sexo, margin = 1) * 100, 1)

# 7.3 Porcentajes por columna (margin = 2): cada columna suma 100%.
# Se lee: "Del total de quienes APRUEBAN, ¿qué % son mujeres?".

round(prop.table(tabla_sexo, margin = 2) * 100, 1)

# 7.4 Porcentajes sobre el total (sin margin): toda la tabla suma 100%.

round(prop.table(tabla_sexo) * 100, 1)

# Para responder nuestra pregunta usamos porcentajes por fila (7.2):
# comparamos el % que aprueba entre hombres y entre mujeres. Si los
# porcentajes son parecidos, el sexo no parece marcar diferencias.

# 7.5 Otro cruce: cambiando una sola variable cambia la pregunta.
# ¿La evaluación del gobierno cambia según grupo socioeconómico?

tabla_gse <- table(datos_proc$gse, datos_proc$eval_gob)
addmargins(tabla_gse)
round(prop.table(tabla_gse, margin = 1) * 100, 1)
# Ojo: el grupo E tiene muy pocos casos (revisar addmargins), así que sus
# porcentajes cambian mucho con muy pocas personas. Hay que leerlos con cuidado.

# 7.6 Tabla de contingencia ponderada (sugerida por CEP)
# Las tablas anteriores describen la MUESTRA. Con el ponderador, estimamos
# los porcentajes para la POBLACIÓN. Este resultado equivale a 7.2, pero ponderado.

cep %>%
  filter(!is.na(eval_gob)) %>%                   # sacamos los NA.
  group_by(sexo, eval_gob) %>%                   # filas = sexo, columnas = eval_gob.
  summarise(porcentaje = survey_prop(vartype = NULL) * 100) %>%  # % dentro de cada sexo.
  pivot_wider(names_from = eval_gob,             # (tidyr) pasa eval_gob a columnas
              values_from = porcentaje)          # para que se vea como tabla.

# 8. Visualizar con ggplot2 -----------------------------------------------

# Todo gráfico en ggplot2 se arma con el mismo molde de 3 piezas, unidas con "+":
#
#   datos %>%
#     ggplot(aes(x = VARIABLE)) +   # 1. aes(): qué variable va en cada eje.
#     geom_TIPO() +                 # 2. geom: qué forma tiene el gráfico.
#     labs(title = "...")           # 3. labs(): títulos y etiquetas.
#
# Cambiando UNA pieza obtenemos un gráfico distinto. Eso es lo que haremos.

# 8.1 Gráfico de barras: una variable categórica

datos_proc %>%
  drop_na(eval_gob) %>%
  ggplot(aes(x = eval_gob)) +   # pieza 1: variable en el eje x.
  geom_bar() +                  # pieza 2: barras (cuenta los casos de cada categoría).
  labs(title = "Evaluación del gobierno",
       x = NULL,
       y = "Frecuencia (n° de personas)",
       caption = "Fuente: Encuesta CEP N°94, 2025")

# 8.2 Cambiamos solo la variable (pieza 1): pais en vez de eval_gob.

datos_proc %>%
  drop_na(pais) %>%
  ggplot(aes(x = pais)) +       # <- único cambio importante.
  geom_bar() +
  labs(title = "¿Chile está progresando, estancado o en decadencia?",
       x = NULL,
       y = "Frecuencia (n° de personas)",
       caption = "Fuente: Encuesta CEP N°94, 2025")

# 8.3 Agregamos color con fill =: ahora el gráfico cruza dos variables.
# Es una tabla de contingencia en forma de gráfico (frecuencias absolutas, 7.1).

datos_proc %>%
  drop_na(eval_gob) %>%
  ggplot(aes(x = sexo, fill = eval_gob)) +    # <- fill = segunda variable.
  geom_bar() +
  labs(title = "Evaluación del gobierno según sexo",
       x = NULL,
       y = "Frecuencia (n° de personas)",
       fill = "Evaluación",                   # título de la leyenda.
       caption = "Fuente: Encuesta CEP N°94, 2025")

# 8.4 Cambiamos la posición de las barras con position =

# position = "dodge": barras una al lado de la otra.
datos_proc %>%
  drop_na(eval_gob) %>%
  ggplot(aes(x = sexo, fill = eval_gob)) +
  geom_bar(position = "dodge") +              # <- único cambio.
  labs(title = "Evaluación del gobierno según sexo",
       x = NULL,
       y = "Frecuencia (n° de personas)",
       fill = "Evaluación",
       caption = "Fuente: Encuesta CEP N°94, 2025")

# position = "fill": cada barra suma 100%. Es el gráfico de los porcentajes
# por fila (7.2): permite comparar hombres y mujeres aunque haya más mujeres en la muestra.
datos_proc %>%
  drop_na(eval_gob) %>%
  ggplot(aes(x = sexo, fill = eval_gob)) +
  geom_bar(position = "fill") +               # <- único cambio.
  scale_y_continuous(labels = scales::percent) +  # eje y en % en vez de 0 a 1.
  labs(title = "Evaluación del gobierno según sexo (%)",
       x = NULL,
       y = "Porcentaje dentro de cada sexo",
       fill = "Evaluación",
       caption = "Fuente: Encuesta CEP N°94, 2025")

# 8.5 Cambiamos x: mismo gráfico, ahora según grupo socioeconómico (tabla 7.5).

datos_proc %>%
  drop_na(eval_gob) %>%
  ggplot(aes(x = gse, fill = eval_gob)) +     # <- sexo cambia por gse.
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Evaluación del gobierno según grupo socioeconómico (%)",
       x = "Grupo socioeconómico",
       y = "Porcentaje dentro de cada GSE",
       fill = "Evaluación",
       caption = "Fuente: Encuesta CEP N°94, 2025")

# 8.6 Variable numérica: cambiamos el geom (pieza 2) por geom_histogram().
# El histograma agrupa los valores en tramos (binwidth = ancho de cada tramo).

datos_proc %>%
  ggplot(aes(x = edad)) +
  geom_histogram(binwidth = 5,              # <- tramos de 5 años. Prueben con 1 o 10.
                 fill = "steelblue",        # color de relleno.
                 color = "white") +         # color del borde de cada barra.
  labs(title = "Distribución de la edad",
       x = "Edad (años)",
       y = "Frecuencia (n° de personas)",
       caption = "Fuente: Encuesta CEP N°94, 2025")

# 8.7 Último toque opcional: theme_minimal() cambia el fondo del gráfico.
# Se puede agregar a cualquiera de los gráficos anteriores con un "+".

datos_proc %>%
  drop_na(pos_pol) %>%
  ggplot(aes(x = pos_pol)) +
  geom_bar(fill = "steelblue") +
  scale_x_continuous(breaks = 1:10) +       # muestra todos los valores del 1 al 10.
  labs(title = "Autoubicación en la escala izquierda (1) - derecha (10)",
       x = "Posición política",
       y = "Frecuencia (n° de personas)",
       caption = "Fuente: Encuesta CEP N°94, 2025") +
  theme_minimal()                           # <- único cambio.

# Resumen: qué cambiar para obtener otro gráfico
#   Otra variable              -> aes(x = OTRA_VARIABLE)
#   Cruzar con otra variable   -> aes(x = ..., fill = OTRA_VARIABLE)
#   Barras lado a lado / en %  -> geom_bar(position = "dodge") / geom_bar(position = "fill")
#   Variable numérica          -> geom_histogram() en vez de geom_bar()
#   Títulos                    -> labs(title = , x = , y = , fill = , caption = )

# 9. Medidas de tendencia central -----------------------------------------

# Resumen en un solo valor el "centro" de una variable:
#   Media   : promedio. Suma de los valores dividida por el n° de casos. mean()
#   Mediana : valor del medio al ordenar los casos; deja 50% abajo y 50% arriba. median()
#   Moda    : valor o categoría más frecuente. Mode() (de DescTools)
#
# Qué medida usar según el nivel de medición de la variable:
#   Nominal (sexo, eval_gob)               -> solo moda.
#   Ordinal (gse, pais)                    -> moda y mediana.
#   Intervalo / razón (edad, n_hogar)      -> moda, mediana y media.
#
# na.rm = TRUE: le pide a R que ignore los NA. Sin esto, si hay un NA el resultado es NA.

# 9.1 Variable numérica: edad

mean(datos_proc$edad, na.rm = TRUE)    # media.
median(datos_proc$edad, na.rm = TRUE)  # mediana.
Mode(datos_proc$edad, na.rm = TRUE)    # moda ("freq" indica cuántas personas tienen esa edad).
# Resultado: 64 y 65. Una variable puede tener más de una moda (bimodal).

# Las tres juntas con summarise() (dplyr):
datos_proc %>%
  summarise(media   = mean(edad, na.rm = TRUE),
            mediana = median(edad, na.rm = TRUE),
            moda    = Mode(edad, na.rm = TRUE)[1])  # [1]: primer valor si hay más de una moda.

# 9.2 Variable nominal: solo moda

Mode(datos_proc$eval_gob, na.rm = TRUE) # categoría más frecuente.

# 9.3 Variable ordinal: moda y mediana
# La mediana de una variable ordinal es la categoría donde el porcentaje
# acumulado alcanza o supera el 50%.

Mode(datos_proc$gse, na.rm = TRUE)

datos_proc %>%
  count(gse) %>%
  mutate(porcentaje           = round(n / sum(n) * 100, 1),
         porcentaje_acumulado = cumsum(porcentaje))   # cumsum(): suma acumulada.
# La mediana es la primera categoría cuyo porcentaje acumulado llega a 50%.

# 9.4 Escala izquierda-derecha (1 a 10)
# Recordar: aquí fue clave transformar -9 y -8 en NA (sección 5).

datos_proc %>%
  summarise(media   = mean(pos_pol, na.rm = TRUE),
            mediana = median(pos_pol, na.rm = TRUE),
            moda    = Mode(pos_pol, na.rm = TRUE)[1])

# 9.5 Tendencia central por grupos: group_by() + summarise()
# Cambiando la variable dentro de group_by() comparamos otros grupos.

datos_proc %>%
  group_by(sexo) %>%                    # <- prueben con zona o gse.
  summarise(media   = mean(edad, na.rm = TRUE),
            mediana = median(edad, na.rm = TRUE),
            moda    = Mode(edad, na.rm = TRUE)[1])

# 9.6 Media y mediana ponderadas (población)

cep %>%
  summarise(media_edad   = survey_mean(edad, na.rm = TRUE, vartype = NULL),
            mediana_edad = survey_median(edad, na.rm = TRUE, vartype = NULL))

# 9.7 Juntamos ggplot2 y tendencia central
# geom_vline() agrega una línea vertical en el valor que le indiquemos.
# Primero guardamos los valores en objetos y luego los usamos en el gráfico.

media_edad   <- mean(datos_proc$edad, na.rm = TRUE)
mediana_edad <- median(datos_proc$edad, na.rm = TRUE)

datos_proc %>%
  ggplot(aes(x = edad)) +
  geom_histogram(binwidth = 5, fill = "grey70", color = "white") +
  geom_vline(xintercept = media_edad, color = "firebrick", linewidth = 1) +   # media.
  geom_vline(xintercept = mediana_edad, color = "steelblue", linewidth = 1,
             linetype = "dashed") +                                           # mediana.
  labs(title = "Distribución de la edad: media y mediana",
       subtitle = paste0("Media (línea roja) = ", round(media_edad, 1),
                         " años | Mediana (línea azul punteada) = ", mediana_edad, " años"),
       x = "Edad (años)",
       y = "Frecuencia (n° de personas)",
       caption = "Fuente: Encuesta CEP N°94, 2025") +
  theme_minimal()

# Cuando la media y la mediana son muy parecidas, la distribución es
# aproximadamente simétrica. Si una variable tiene valores extremos (por ejemplo, hogares muy numerosos), la media se "arrastra" hacia ellos y la mediana no.

datos_proc %>%
  summarise(media   = mean(n_hogar, na.rm = TRUE),
            mediana = median(n_hogar, na.rm = TRUE),
            moda    = Mode(n_hogar, na.rm = TRUE)[1],
            maximo  = max(n_hogar, na.rm = TRUE))

# 10. Preguntas -----------------------------------------------------------

# P1. En la tabla de porcentajes por fila de sexo y evaluación del gobierno (7.2),
#     ¿qué porcentaje de hombres y qué porcentaje de mujeres aprueba al gobierno?
#     ¿Parece haber diferencias por sexo?
# R1. Aprueba el 24,9% de los hombres y el 21,1% de las mujeres (3,8 puntos de
#     diferencia). En ambos grupos la gran mayoría desaprueba (66,1% y 70,0%),
#     por lo que el sexo marca diferencias pequeñas en la evaluación del gobierno.

# P2. ¿Por qué para comparar hombres y mujeres usamos porcentajes por fila
#     y no frecuencias absolutas?
# R2. Porque en la muestra hay más mujeres (924) que hombres (583). Con
#     frecuencias absolutas las mujeres siempre parecerán "más" en todas las
#     categorías. Los porcentajes por fila ponen a ambos grupos sobre 100.

# P3. ¿Qué pieza del molde de ggplot2 hay que cambiar para pasar del gráfico
#     8.4 (position = "fill" por sexo) al gráfico 8.5 (por GSE)?
# R3. Solo la variable de aes(x = ): sexo por gse (y, por orden, los títulos en labs()).

# P4. ¿Cuál es la media, la mediana y la moda de la edad? ¿Qué nos dice que
#     media y mediana sean parecidas?
# R4. Media = 49,7 años; mediana = 50 años. La moda no es un solo valor:
#     64 y 65 años se repiten 35 veces cada una (distribución bimodal).
#     Media y mediana casi iguales indican una distribución de la edad
#     aproximadamente simétrica. La moda se aleja porque la edad tiene muchos
#     valores posibles con frecuencias parecidas, así que la edad "más repetida"
#     dice poco del centro de esta variable.

# P5. ¿Por qué no podemos calcular la media de eval_gob? ¿Qué medida sí corresponde?
# R5. Porque es nominal: sus categorías no tienen orden ni distancia numérica.
#     Solo corresponde la moda, que es "Desaprueba".

# P6. ¿Cuál es la mediana del grupo socioeconómico (gse)?
# R6. C3. El porcentaje acumulado pasa de 24,0% en C2 a 81,6% en C3, por lo
#     que el 50% se alcanza en C3. C3 también es la moda.

# P7. En la escala izquierda-derecha, ¿cuál es la media, mediana y moda?
#     ¿Qué habría pasado si no transformábamos -9 y -8 en NA?
# R7. Media = 5,5; mediana = 5; moda = 5. Si no transformábamos esos códigos,
#     411 respuestas "No sabe" / "No contesta" se habrían sumado como -8 y -9
#     y la media habría bajado artificialmente a 1,7, un valor que ubicaría
#     a la población en la extrema izquierda sin que eso sea cierto.

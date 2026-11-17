
# 0. preparar el proyecto ----------------------------------------------------
# abre el rproject de la ayudantía y mueve la base cep95_clase.csv a su carpeta.

pacman::p_load(dplyr, tidyr, ggplot2)

cep95 <- read.csv("cep95_clase.csv")


# 1. seleccionar variables y casos -------------------------------------------
# el operador %>% (pipe) encadena pasos: "toma esto y luego haz esto otro".
# usa estas funciones como referencia:

# select() # se queda con algunas columnas (variables).
# filter() # se queda con algunas filas (personas) que cumplen una condición.
# nrow()   # cuenta el número de filas.

# ejemplo:
# cep95 %>% select(sexo, edad)
# cep95 %>% filter(sexo == "Mujer")

# ejercicio 1:
# a) crea un objeto llamado cep_sel con las variables sexo, edad, voto_1v,
#    interes_pol, aprob_pdte y escala_izq_der.
# b) ¿cuántas variables tenía cep95 y cuántas tiene cep_sel?
# c) usando filter(), ¿cuántas personas tienen 60 años o más?
# d) ¿cuántas mujeres menores de 30 años hay en la base?

# escribe aquí tu código:




# 2. limpiar y recodificar ---------------------------------------------------
# recodificar es crear una variable nueva a partir de otra.
# usa estas funciones como referencia:

# rename()    # cambia el nombre de una variable: rename(nuevo = antiguo).
# mutate()    # crea o modifica una variable.
# case_when() # asigna categorías según condiciones.

# ejemplo:
# cep_sel %>%
#   mutate(mayor_60 = case_when(edad >= 60 ~ "Sí",
#                               edad <  60 ~ "No"))

# ejercicio 2:
# a) cambia el nombre de escala_izq_der por ideologia.
# b) crea la variable tramo_edad con las categorías "18-29", "30-44",
#    "45-59" y "60 o más".
# c) crea la variable interes con dos categorías:
#    "Bajo interés" = Nada y No muy.
#    "Alto interés" = Algo, Bastante y Muy interesado.
# d) revisa ambas variables nuevas con table(). ¿qué tramo tiene más personas?
# e) ¿por qué es mejor crear variables nuevas en vez de reemplazar las originales?

# escribe aquí tu código:




# 3. valores perdidos (NA) ---------------------------------------------------
# NA indica que la persona no respondió (o no sabe).
# usa estas funciones como referencia:

# is.na()            # indica TRUE si el dato es NA.
# sum(is.na())       # cuenta los NA de una variable.
# colSums(is.na())   # cuenta los NA de todas las variables a la vez.
# drop_na()          # elimina las filas con NA (en todas o en algunas variables).
# na.rm = TRUE       # ignora los NA al calcular, por ejemplo, mean().

# ejercicio 3:
# a) ¿cuántos NA tiene cada variable de cep_sel? ¿cuál tiene más?
# b) ¿qué porcentaje de personas no respondió la escala de ideología?
#    pista: mean(is.na(variable)) * 100
# c) ¿por qué crees que tantas personas no se ubican en la escala izquierda-derecha?
# d) compara el número de filas de drop_na(cep_sel) y drop_na(cep_sel, ideologia).
#    ¿por qué son distintos?
# e) calcula la media de ideologia. ¿qué pasa si no usas na.rm = TRUE?

# escribe aquí tu código:




# 4. tabla de contingencia ---------------------------------------------------
# una tabla de contingencia cruza dos variables categóricas.
# usa estas funciones como referencia:

# table(x, y)                   # cuenta las combinaciones de dos variables.
# prop.table(tabla, margin = 1) # proporciones por fila (cada fila suma 1).
# * 100                         # convierte la proporción en porcentaje.
# round(x, 1)                   # redondea a un decimal.

# ejercicio 4:
# a) cruza tramo_edad (filas) con interes (columnas) y guárdala como tabla_1.
# b) calcula los porcentajes por fila y redondéalos a un decimal.
# c) ¿qué tramo de edad tiene mayor porcentaje de alto interés en política?
# d) ¿por qué usamos porcentajes por fila y no solo las frecuencias?

# escribe aquí tu código:




# 5. gráficos sencillos ------------------------------------------------------
# usa estas funciones como referencia:

# filter(!is.na(x))         # elimina los NA de una variable antes de graficar.
# geom_bar()                # gráfico de barras.
# aes(fill = y)             # colorea las barras según otra variable.
# position = "fill"         # barras al 100% (muestra proporciones).
# labs()                    # títulos y nombres de los ejes.

# ejercicio 5:
# a) crea un gráfico de barras de aprob_pdte. ¿qué aparece además de las
#    tres categorías?
# b) repite el gráfico eliminando antes los NA con filter(!is.na(aprob_pdte)).
# c) crea un gráfico de barras de tramo_edad coloreado por interes, usando
#    position = "fill". agrega título y nombres a los ejes.
# d) ¿el gráfico confirma lo que observaste en la tabla de contingencia?

# escribe aquí tu código:




# 6. objeto con media y mediana ----------------------------------------------
# podemos calcular la media y la mediana de una variable para varios grupos
# a la vez y guardar el resultado en un objeto.
# usa estas funciones como referencia:

# group_by()  # separa la base en grupos según una variable.
# summarise() # resume cada grupo en una sola fila.
# n()         # cuenta las personas de cada grupo.
# %in%        # filtra varias categorías a la vez: x %in% c("a", "b").

# ejemplo:
# cep_sel %>%
#   group_by(sexo) %>%
#   summarise(media = mean(edad))

# ejercicio 6:
# a) filtra a los votantes de Jara, Kast y Parisi (variable voto_1v).
# b) crea un objeto llamado resumen_edad con el número de personas, la media
#    y la mediana de edad de cada grupo.
# c) agrega con mutate() una columna diferencia = media - mediana.
# d) ¿en qué grupo la media y la mediana se alejan más?
# e) ¿en qué grupo son casi iguales?

# escribe aquí tu código:




# 7. graficar media y mediana ------------------------------------------------
# cuando una distribución es simétrica, la media y la mediana son parecidas.
# cuando es asimétrica, la media se "arrastra" hacia la cola (los valores extremos).
# usa estas funciones como referencia:

# geom_histogram()                   # histograma (visto en la sesión 06).
# geom_vline(xintercept = valor)     # dibuja una línea vertical en ese valor.
# color = "red"                      # color de la línea.
# linetype = "dashed"                # línea punteada.
# labs(subtitle = "")                # subtítulo para explicar las líneas.

# ejemplo:
# parisi <- cep_sel %>% filter(voto_1v == "Parisi")
# ggplot(parisi, aes(x = edad)) +
#   geom_histogram(binwidth = 5) +
#   geom_vline(xintercept = mean(parisi$edad), color = "red")

# ejercicio 7:
# a) crea un histograma de la edad de los votantes de Parisi con intervalos
#    de 5 años.
# b) agrega una línea roja para la media y una azul punteada para la mediana.
# c) agrega un título y un subtítulo que explique qué es cada línea.
# d) repite el gráfico con los votantes de Jara.
# e) ¿cuál de las dos distribuciones es asimétrica? ¿hacia qué lado está la cola?
# f) en la distribución asimétrica, ¿la media queda a la izquierda o a la
#    derecha de la mediana? ¿por qué?

# escribe aquí tu código:



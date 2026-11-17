
# 0. Crea el rproject -----------------------------------------------------
# recuerda que es file -> new project -> new directory -> new project ->
# asigna nombre -> asigna lugar donde quedará en el computador -> 
# mueve el data set a la carpeta.

# 1. cargar paquetes ---------------------------------------------------------
# instale/cargue dplyr y ggplot2

# ejercicio 1:
# instala los paquetes necesarios y cargalos en RStudio.

# escribe aquí tu código:




# 2. cargar datos ------------------------------------------------------------
# usa este código como referencia:

# readRDS("archivo.rds")         # archivos .rds
# haven::read_sav("archivo.sav") # archivos .sav
# read.csv("archivo.csv")        # archivos .csv
# haven::read_dta("archivo.dta") # archivos .dta

# ejercicio 2:
# carga la base CEP 95 y guardala con el nombre cep95.

# escribe aquí tu código:



# 3. revisar variables -------------------------------------------------------
# usa estas funciones como referencia:

# dim()     # n° de filas (personas) y n° de columnas (variables).
# glimpse() # muestra las variables y sus tipos.

# ejercicio 3:
# a) ¿cuántas personas y variables tiene la base de datos?
# b) identifica dos variables categóricas y dos numéricas.

# escribe aquí tu código:




# 4. tablas de frecuencia ----------------------------------------------------
# una tabla de frecuencia permite contar las respuestas.
# usa estas funciones como referencia:

# table()      # cuenta la frecuencia de cada categoría.
# prop.table() # calcula la proporción de cada categoría.
# * 100        # convierte una proporción en porcentaje.

# ejercicio 4:
# a) crea una tabla de frecuencia para la variable sexo.
# b) calcula el porcentaje de cada categoría.
# c) ¿cuál es la categoría con mayor frecuencia?
# d) ¿qué diferencia existe entre frecuencia y porcentaje?

# escribe aquí tu código:




# 5. medidas de tendencia central -------------------------------------------
# na.rm = TRUE: ignora los NA (personas sin respuesta).
# usa estas funciones como referencia:

# mean()   # media.
# median() # mediana.
# table()  # permite identificar la moda (valor más frecuente).

# ejercicio 5:
# a) calcula la media y mediana de la edad de los entrevistados.
# b) ¿son similares los resultados?
# c) ¿qué medida utilizarías para describir la variable sexo?
# d) ¿por qué no podemos calcular la media de una variable nominal?

# escribe aquí tu código:




# 6. medidas de variabilidad -------------------------------------------------
# permiten conocer qué tan dispersos están los datos.
# usa estas funciones como referencia:

# max() # valor máximo.
# min() # valor mínimo.
# var() # varianza.
# sd()  # desviación estándar.

# recuerda: rango = valor máximo - valor mínimo.

# ejercicio 6:
# a) calcula el rango de edad de los entrevistados.
# b) calcula la varianza y desviación estándar de la edad.
# c) ¿qué nos indica la desviación estándar?
# d) ¿puede una desviación estándar ser negativa? ¿por qué?

# escribe aquí tu código:




# 7. comparar distribuciones -------------------------------------------------
# dos grupos pueden tener la misma media y distinta dispersión.
# utiliza los siguientes datos de ejemplo:

grupo_a <- c(4, 5, 5, 5, 6)
grupo_b <- c(1, 3, 5, 7, 9)

# ejercicio 7:
# a) calcula la media de ambos grupos utilizando mean().
# b) calcula la desviación estándar utilizando sd().
# c) ¿qué grupo presenta mayor variabilidad?
# d) ¿por qué la media no permite identificar esta diferencia?

# escribe aquí tu código:




# 8. crear un gráfico de barras ----------------------------------------------
# los gráficos de barras permiten representar variables categóricas.
# usa estas funciones como referencia:

# ggplot()   # indica los datos que utilizaremos.
# aes()      # indica las variables de los ejes.
# geom_bar() # crea un gráfico de barras.
# labs()     # permite agregar títulos y nombres a los ejes.

# ejercicio 8:
# a) crea un gráfico de barras para la variable sexo.
# b) agrega un título y nombres a los ejes.
# c) ¿cuál es la categoría más frecuente?

# escribe aquí tu código:




# 9. crear un histograma -----------------------------------------------------
# los histogramas representan la distribución de variables numéricas.
# usa estas funciones como referencia:

# ggplot()          # indica los datos que utilizaremos.
# aes()             # indica la variable del eje x.
# geom_histogram()  # crea un histograma.
# binwidth          # permite definir el ancho de los intervalos.
# labs()            # permite agregar títulos y nombres a los ejes.

# ejercicio 9:
# a) crea un histograma para la variable edad.
# b) utiliza intervalos de 10 años.
# c) modifica los intervalos a 5 años.
# d) ¿en qué edades se concentra la mayor cantidad de personas?
# e) ¿qué diferencia existe entre un histograma y un gráfico de barras?

# escribe aquí tu código:




# 10. exportar los gráficos --------------------------------------------------
# ggsave() permite guardar gráficos en la carpeta del proyecto.
# usa este código como referencia:

# ggsave("nombre_del_archivo.png")

# ejercicio 10:
# a) exporta el histograma de edad en formato PNG.
# b) exporta el gráfico de barras como grafico_sexo.png.
# c) comprueba que ambos archivos estén guardados en tu proyecto.

# escribe aquí tu código:
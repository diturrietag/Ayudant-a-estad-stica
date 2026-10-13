# 1. cargar paquetes ---------------------------------------------------------
# instale/cargue dplyr y ggplot2

# escribe aquí tu código:


# 2. cargar datos ------------------------------------------------------------
# usa este código como referencia:

# readRDS("cep95_clase.rds") # carga de datos para archivos .rds
# read_sav("cep95_clase.sav") # carga de datos para archivos .sav
# read.csv("cep95_clase.csv") # carga de datos para archivos .csv
# read_dta("cep95_clase.dta") # carga de datos para archivos .dta

# escribe aquí tu código:


# 3. revisar variables -------------------------------------------------------
# usa este código como referencia
dim(cep95)     # n° de filas (personas) y n° de columnas (variables).
glimpse(cep95) # tipo de cada variable: <fct> nominal, <ord> ordinal, <int> numérica.

# escribe aquí tu código:


# 4. medidas de tendencia central --------------------------------------------
# na.rm = TRUE: ignora los NA (personas sin respuesta).
# usa este código como rererencia
mean(cep95$edad, na.rm = TRUE)   # media.
median(cep95$edad, na.rm = TRUE) # mediana.
table(cep95$sexo)                # moda: la categoría con más personas.

# escribe aquí tu código:


# 5. crear un gráfico --------------------------------------------------------
# usa este código como referencia
ggplot(cep95, aes(x = sexo)) +   # datos y variable del eje x.
  geom_bar() +                   # gráfico de barras.
  labs(title = "Sexo de los entrevistados",
       x = "Sexo",
       y = "N° de personas")

# escribe aquí tu código:


# 6. exportar el gráfico -----------------------------------------------------

ggsave("grafico_sexo.png") # guarda el último gráfico en la carpeta del proyecto.

# escribe aquí tu código:


# 1. cargar paquetes ---------------------------------------------------------

# instalar y cargar los paquetes necesarios
pacman::p_load(dplyr, ggplot2)


# 2. cargar datos ------------------------------------------------------------

# cargar base de datos CEP 95
cep95 <- readRDS("cep95_clase.rds")


# 3. revisar variables -------------------------------------------------------

# a) cantidad de personas y variables
dim(cep95)

# b) identificar variables y sus tipos
glimpse(cep95)

# identificar dos variables categóricas y dos numéricas
# revisar los resultados de glimpse()


# 4. tablas de frecuencia ----------------------------------------------------

# a) tabla de frecuencia de sexo
table(cep95$sexo)

# b) porcentaje de cada categoría
prop.table(table(cep95$sexo)) * 100

# c) identificar la categoría más frecuente
sort(table(cep95$sexo), decreasing = TRUE)

# d) diferencia entre frecuencia y porcentaje
# frecuencia: cantidad de personas en cada categoría.
# porcentaje: proporción de personas en cada categoría multiplicada por 100.


# 5. medidas de tendencia central -------------------------------------------

# a) media y mediana de edad
mean(cep95$edad, na.rm = TRUE)
median(cep95$edad, na.rm = TRUE)

# b) comparar los resultados
# si son similares, la distribución podría ser aproximadamente simétrica.

# c) medida adecuada para sexo
table(cep95$sexo)

# la moda es la categoría que aparece con mayor frecuencia.

# d) ¿por qué no podemos calcular la media de sexo?
# porque es una variable nominal y sus categorías no son valores numéricos.


# 6. medidas de variabilidad -------------------------------------------------

# a) rango de edad
max(cep95$edad, na.rm = TRUE) - min(cep95$edad, na.rm = TRUE)

# b) varianza y desviación estándar
var(cep95$edad, na.rm = TRUE)
sd(cep95$edad, na.rm = TRUE)

# c) interpretación
# la desviación estándar indica qué tan dispersos están los datos
# alrededor de su media, en las mismas unidades de la variable.

# d) ¿puede ser negativa?
# no, la desviación estándar nunca puede ser negativa.


# 7. comparar distribuciones -------------------------------------------------

# datos de ejemplo
grupo_a <- c(4, 5, 5, 5, 6)
grupo_b <- c(1, 3, 5, 7, 9)

# a) media de ambos grupos
mean(grupo_a) # 5
mean(grupo_b) # 5

# b) desviación estándar
sd(grupo_a) # 0.71
sd(grupo_b) # 3.16

# c) ¿qué grupo tiene mayor variabilidad?
# el grupo B, porque tiene una desviación estándar mayor.

# d) ¿por qué la media no identifica esta diferencia?
# porque ambos grupos tienen la misma media,
# pero sus valores están distribuidos de manera diferente.


# 8. crear un gráfico de barras ----------------------------------------------

# a) gráfico de barras para sexo
ggplot(cep95, aes(x = sexo)) +
  geom_bar() +
  labs(title = "Sexo de los entrevistados",
       x = "Sexo",
       y = "N° de personas")

# b) modificar el título y los nombres de los ejes
# los títulos se modifican utilizando labs().

# c) identificar la categoría más frecuente
table(cep95$sexo)


# 9. crear un histograma -----------------------------------------------------

# a) histograma de edad con intervalos de 10 años
ggplot(cep95, aes(x = edad)) +
  geom_histogram(binwidth = 10) +
  labs(title = "Distribución de edad",
       x = "Edad",
       y = "N° de personas")

# b) modificar los intervalos a 5 años
ggplot(cep95, aes(x = edad)) +
  geom_histogram(binwidth = 5) +
  labs(title = "Distribución de edad",
       x = "Edad",
       y = "N° de personas")

# c) identificar las edades con mayor frecuencia
# observar las barras más altas del histograma.

# d) diferencia entre gráficos
# gráfico de barras: representa variables categóricas.
# histograma: representa variables numéricas agrupadas en intervalos.


# 10. exportar los gráficos --------------------------------------------------

# a) crear y exportar histograma de edad
ggplot(cep95, aes(x = edad)) +
  geom_histogram(binwidth = 10) +
  labs(title = "Distribución de edad",
       x = "Edad",
       y = "N° de personas")

ggsave("grafico_edad.png")


# b) crear y exportar gráfico de barras
ggplot(cep95, aes(x = sexo)) +
  geom_bar() +
  labs(title = "Sexo de los entrevistados",
       x = "Sexo",
       y = "N° de personas")

ggsave("grafico_sexo.png")


# c) comprobar archivos guardados
list.files()
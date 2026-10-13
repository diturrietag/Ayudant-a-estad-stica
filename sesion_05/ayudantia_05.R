# 1. carga de librerias/paquetes ---------------------------------------------

pacman::p_load(tidyr, # para trabajar variables como columnas, cada columna es una variable. Cada observación es una fila, cada fila es una observación. Cada valor es una celda, cada celda es un único valor.
               dplyr, # para manipular datos.
               ggplot2, # para crear gráficos.
               haven, # carga datos tipo sav y dta.
               readxl, # para abrir archivos excel.
               srvyr) # para calcular estadisticos en datos tipo encuesta.

options(scipen = 999) # evita que R muestre resultados en notación científica.


# 2. cargar datos ------------------------------------------------------------
# comando dependiendo del tipo de archivo a trabajar.

cep95rds <- readRDS("cep95_clase.rds") # carga de datos para archivos .rds
cep95sav <- read_sav("cep95_clase.sav") # carga de datos para archivos .sav
cep95csv <- read.csv("cep95_clase.csv") # carga de datos para archivos .csv
cep95dta <- read_dta("cep95_clase.dta") # carga de datos para archivos .dta


# 3. revisar dataset ---------------------------------------------------------
# Variables: nominales (sexo, voto_1v, aprob_pdte), ordinales (interes_pol,
# conf_partidos) y numéricas (edad, escala_izq_der, satisf_vida).

colnames(cep95rds) # muestra el nombre de todas las columnas.

dim(cep95rds) # muestra cuántas filas y columnas tiene la base.

glimpse(cep95rds) # <fct> nominal, <ord> ordinal, <int> numérica.

head(cep95rds) # muestra las primeras 6 observaciones.

summary(cep95rds) # entrega un resumen descriptivo básico de cada variable.


# 4. medidas de tendencia central --------------------------------------------
# Resumen en un solo valor el "centro" de una variable:
#   Media   : promedio. Suma de los valores dividida por el n° de casos. mean()
#   Mediana : valor del medio al ordenar los casos; deja 50% abajo y 50% arriba. median()
#   Moda    : valor o categoría más frecuente. table() muestra cuántas veces aparece cada valor.

# Qué medida usar según el nivel de medición de la variable para este caso en especifico:
# Es imporatante tener en cuenta el propio criterio de los casos.
#   Nominal (sexo, voto_1v, aprob_pdte)            -> solo moda.
#   Ordinal (interes_pol, conf_partidos)           -> moda y mediana.
#   Intervalo / razón (edad, escala_izq_der, satisf_vida) -> moda, mediana y media.

# na.rm = TRUE: le pide a R que ignore los NA. Sin esto, si hay un NA el resultado es NA.

# 4.1 Variable numérica: edad
mean(cep95rds$edad, na.rm = TRUE)    # media.
median(cep95rds$edad, na.rm = TRUE)  # mediana.
sort(table(cep95rds$edad), decreasing = TRUE) # moda: la primera edad de la lista es la más frecuente.

# 4.2 Variable numérica: escala izquierda-derecha (1 a 10)
mean(cep95rds$escala_izq_der)                 # sin na.rm = TRUE el resultado es NA.
mean(cep95rds$escala_izq_der, na.rm = TRUE)   # media.
median(cep95rds$escala_izq_der, na.rm = TRUE) # mediana.
table(cep95rds$escala_izq_der)                # moda: el valor con más personas.

# 4.3 Variable nominal: solo moda
table(cep95rds$voto_1v)     # moda: la categoría con más personas.
table(cep95rds$aprob_pdte)
table(cep95rds$sexo)

# 4.4 Variable ordinal: moda y mediana
table(cep95rds$interes_pol)                             # moda: la categoría con más personas.
median(as.numeric(cep95rds$interes_pol), na.rm = TRUE)  # mediana: entrega la posición de la categoría.
levels(cep95rds$interes_pol)                            # orden de las categorías: 1 = Nada, 2 = No muy...

# 4.5 Tendencia central por grupos: group_by() + summarise()
cep95rds %>%
  group_by(aprob_pdte) %>%                                # <- prueben con sexo.
  summarise(media = mean(escala_izq_der, na.rm = TRUE))   # media de la escala en cada grupo.


# 5. gráficos básicos con ggplot2 -------------------------------------------
# Estructura: ggplot(datos, aes(x = variable)) + geom_tipo() + labs(textos)

# 5.1 Barras: variable nominal
cep95rds %>%
  filter(!is.na(aprob_pdte)) %>%     # sacamos los NA del gráfico.
  ggplot(aes(x = aprob_pdte)) +
  geom_bar() +                       # una barra por categoría.
  labs(title = "Aprobación del Presidente",
       x = "Respuesta",
       y = "Frecuencia (n° de personas)",
       caption = "Fuente: Encuesta CEP N°95, 2025") +
  theme_minimal()

# 5.2 Barras: variable ordinal (respeta el orden de las categorías)
cep95rds %>%
  filter(!is.na(conf_partidos)) %>%
  ggplot(aes(x = conf_partidos)) +
  geom_bar() +
  labs(title = "Confianza en los partidos políticos",
       x = "Nivel de confianza",
       y = "Frecuencia (n° de personas)",
       caption = "Fuente: Encuesta CEP N°95, 2025") +
  theme_minimal()

# 5.3 Histograma: variable numérica, con su media y mediana
# Primero guardamos los valores en objetos y luego los usamos en el gráfico.
media_edad   <- mean(cep95rds$edad, na.rm = TRUE)
mediana_edad <- median(cep95rds$edad, na.rm = TRUE)

cep95rds %>%
  ggplot(aes(x = edad)) +
  geom_histogram(binwidth = 5, fill = "grey70", color = "white") +            # barras de 5 años.
  geom_vline(xintercept = media_edad, color = "firebrick", linewidth = 1) +   # media.
  geom_vline(xintercept = mediana_edad, color = "steelblue", linewidth = 1,
             linetype = "dashed") +                                           # mediana.
  labs(title = "Distribución de la edad: media y mediana",
       subtitle = "Media: línea roja | Mediana: línea azul punteada",
       x = "Edad (años)",
       y = "Frecuencia (n° de personas)",
       caption = "Fuente: Encuesta CEP N°95, 2025") +
  theme_minimal()

# 5.4 Boxplot: variable numérica comparada entre grupos
cep95rds %>%
  filter(!is.na(aprob_pdte), !is.na(escala_izq_der)) %>%
  ggplot(aes(x = aprob_pdte, y = escala_izq_der)) +
  geom_boxplot() +                   # la línea gruesa es la mediana.
  labs(title = "Escala izquierda-derecha según aprobación del Presidente",
       x = "Aprobación del Presidente",
       y = "Escala izquierda (1) - derecha (10)",
       caption = "Fuente: Encuesta CEP N°95, 2025") +
  theme_minimal()

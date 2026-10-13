# 1. carga de librerias/paquetes ---------------------------------------------

pacman::p_load(tidyr, # para trabajar variables como columnas, cada columna es una variable. Cada observación es una fila, cada fila es una observación. Cada valor es una celda, cada celda es un único valor.
               dplyr, # para manipular datos.
               ggplot2, # para crear gráficos.
               haven, # carga datos tipo sav y dta.
               readxl, # para abrir archivos excel.
               srvyr, # para calcular estadisticos en datos tipo encuesta.
               DescTools) # para calcular la moda con Mode().

options(scipen = 999) # evita que R muestre resultados en notación científica.


# 2. cargar datos ------------------------------------------------------------
# comando dependiendo del archivo a trabajar.

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
#   Moda    : valor o categoría más frecuente. Mode() (de DescTools)

# na.rm = TRUE: le pide a R que ignore los NA. Sin esto, si hay un NA el resultado es NA.

# 4.1 Variable numérica: edad
mean(cep95rds$edad, na.rm = TRUE)    # media.
median(cep95rds$edad, na.rm = TRUE)  # mediana.
Mode(cep95rds$edad, na.rm = TRUE)    # moda ("freq" indica cuántas personas tienen esa edad).

# 4.2 Variable numérica: escala izquierda-derecha (1 a 10)
mean(cep95rds$escala_izq_der)                # sin na.rm = TRUE el resultado es NA.
mean(cep95rds$escala_izq_der, na.rm = TRUE)  # media.
median(cep95rds$escala_izq_der, na.rm = TRUE) # mediana.
Mode(cep95rds$escala_izq_der, na.rm = TRUE)   # moda.

# Las tres juntas con summarise() (dplyr):
cep95rds %>%
  summarise(media   = mean(satisf_vida, na.rm = TRUE),
            mediana = median(satisf_vida, na.rm = TRUE),
            moda    = Mode(satisf_vida, na.rm = TRUE)[1])  # [1]: primer valor si hay más de una moda.

# 4.3 Variable nominal: solo moda
Mode(cep95rds$voto_1v, na.rm = TRUE)    # categoría más frecuente.
Mode(cep95rds$aprob_pdte, na.rm = TRUE)
Mode(cep95rds$sexo, na.rm = TRUE)

# 4.4 Variable ordinal: moda y mediana
# La mediana de una variable ordinal es la categoría donde el porcentaje
# acumulado alcanza o supera el 50%.
Mode(cep95rds$interes_pol, na.rm = TRUE) # moda.

cep95rds %>%
  filter(!is.na(interes_pol)) %>%                              # dejamos fuera los NA.
  count(interes_pol) %>%                                       # frecuencia de cada categoría.
  mutate(porcentaje           = round(n / sum(n) * 100, 1),
         porcentaje_acumulado = cumsum(porcentaje))            # cumsum(): suma acumulada.
# La mediana es la primera categoría cuyo porcentaje acumulado llega a 50%.

# 4.5 Tendencia central por grupos: group_by() + summarise()
# Cambiando la variable dentro de group_by() comparamos otros grupos.
cep95rds %>%
  group_by(aprob_pdte) %>%                   # <- prueben con sexo.
  summarise(media   = mean(escala_izq_der, na.rm = TRUE),
            mediana = median(escala_izq_der, na.rm = TRUE))


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

# 1. carga de librerias/paquetes ---------------------------------------------

pacman::p_load(tidyr, # para trabajar variables como columnas, cada columna es una variable. Cada observación es una fila, cada fila es una observación. Cada valor es una celda, cada celda es un único valor.
               dplyr, # para manipular datos.
               ggplot2, # para crear gráficos.
               haven, # carga datos tipo sav y dta.
               readxl, # para abrir archivos excel.
               srvyr) # para calcular estadisticos en datos tipo encuesta.

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
# nominal -> moda | ordinal -> moda y mediana | numérica -> moda, mediana y media

# 4.1 Numéricas: media y mediana
cep95rds %>%
  summarise(media_edad      = mean(edad, na.rm = TRUE),          # na.rm = TRUE ignora los NA.
            mediana_edad    = median(edad, na.rm = TRUE),
            media_izq_der   = mean(escala_izq_der, na.rm = TRUE),
            mediana_izq_der = median(escala_izq_der, na.rm = TRUE),
            media_satisf    = mean(satisf_vida, na.rm = TRUE),
            mediana_satisf  = median(satisf_vida, na.rm = TRUE))

# Media por grupos: group_by() + summarise()
cep95rds %>%
  group_by(aprob_pdte) %>%
  summarise(media_izq_der = mean(escala_izq_der, na.rm = TRUE))

# 4.2 Nominales: la moda es la categoría más frecuente
cep95rds %>%
  count(voto_1v, sort = TRUE) # sort = TRUE ordena de mayor a menor: la primera fila es la moda.

# 4.3 Ordinales: moda y mediana
cep95rds %>%
  count(interes_pol, sort = TRUE) # moda.

median(as.numeric(cep95rds$interes_pol), na.rm = TRUE) # as.numeric() usa la posición: 1 = Nada ... 5 = Muy interesado.
levels(cep95rds$interes_pol)[2]                        # traduce la posición 2 a su etiqueta.


# 5. gráficos básicos con ggplot2 -------------------------------------------
# Estructura: ggplot(datos, aes(x = variable)) + geom_tipo() + labs(textos)

# 5.1 Barras: variable nominal
cep95rds %>%
  filter(!is.na(voto_1v)) %>%                           # sacamos los NA del gráfico.
  ggplot(aes(x = forcats::fct_infreq(voto_1v))) +       # ordena las barras de mayor a menor.
  geom_bar(fill = "steelblue") +
  labs(title = "Voto simulado en primera vuelta presidencial",
       subtitle = "Encuesta CEP N°95 (2025)",
       x = "Candidato/a u opción",
       y = "Número de personas") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) # gira las etiquetas para que se lean.

# 5.2 Barras: variable ordinal (respeta el orden de las categorías)
cep95rds %>%
  filter(!is.na(conf_partidos)) %>%
  ggplot(aes(x = conf_partidos)) +
  geom_bar(fill = "darkred") +
  labs(title = "Confianza en los partidos políticos",
       subtitle = "Encuesta CEP N°95 (2025)",
       x = "Nivel de confianza",
       y = "Número de personas") +
  theme_minimal()

# 5.3 Histograma: variable numérica
ggplot(cep95rds, aes(x = edad)) +
  geom_histogram(binwidth = 5, fill = "grey40", color = "white") + # barras de 5 años.
  geom_vline(xintercept = mean(cep95rds$edad), color = "red", linetype = "dashed") + # media.
  labs(title = "Distribución de la edad de los entrevistados",
       subtitle = "La línea roja marca la edad promedio",
       x = "Edad (años)",
       y = "Número de personas") +
  theme_minimal()

# 5.4 Barras de una escala 1 a 10
cep95rds %>%
  filter(!is.na(escala_izq_der)) %>%
  ggplot(aes(x = factor(escala_izq_der))) +             # factor() da una barra por valor.
  geom_bar(fill = "purple4") +
  labs(title = "Autoubicación en la escala izquierda-derecha",
       subtitle = "1 = izquierda, 10 = derecha. Excluye a quienes no se ubican",
       x = "Posición en la escala",
       y = "Número de personas") +
  theme_minimal()

# 5.5 Boxplot: variable numérica comparada entre grupos
cep95rds %>%
  filter(!is.na(aprob_pdte), !is.na(escala_izq_der)) %>%
  ggplot(aes(x = aprob_pdte, y = escala_izq_der)) +
  geom_boxplot(fill = "lightblue") +                     # la línea gruesa es la mediana.
  labs(title = "Posición izquierda-derecha según aprobación del Presidente",
       x = "Aprobación del Presidente",
       y = "Escala izquierda (1) - derecha (10)") +
  theme_minimal()

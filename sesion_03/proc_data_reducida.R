
# Link a cep 94 -----------------------------------------------------------

# https://www.cepchile.cl/encuesta/encuesta-cep-n-94-mayo-junio-2025-issp-orientaciones-laborales/

# 1. Instalar librerias ---------------------------------------------------

pacman::p_load(tidyr, # para trabajar variables como columnas, cada columna es una variable. Cada observación es una fila, cada fila es una observación. Cada valor es una celda, cada celda es un único valor.
               dplyr, # para manipular datos.
               ggplot2, # para crear gráficos.
               haven, # permite cargar datos en varios formatos.
               readxl, # para abrir archivos excel.
               srvyr) # para calcular estadisticos en datos tipo encuesta.


# Para profundizar: ¿Qué hace cada librería? -----------------------------

# tidyr: https://tidyr.tidyverse.org/
# dplyr: https://dplyr.tidyverse.org/
# ggplot2: https://ggplot2.tidyverse.org/
# haven: https://haven.tidyverse.org/
# readxl: https://readxl.tidyverse.org/
# srvyr: http://gdfe.co/srvyr/


# 2. Cargar datos ---------------------------------------------------------

data <- readRDS("base_94_reducida.Rds")


# 3. Revisar datos --------------------------------------------------------

colnames(data) # muestra el nombre de todas las columnas.

dim(data) # muestra cuántas filas y columnas tiene la base.

glimpse(data) # muestra las variables, su tipo y algunos de sus valores.

head(data) # muestra las primeras 6 observaciones.

summary(data) # entrega un resumen descriptivo básico de cada variable.


# Para profundizar: ¿Cómo reviso datos perdidos? -------------------------

# Con datos perdidos nos vamos a referir cuando en nuestras observaciones
# veamos "NA". Conviene revisar el diccionario de variables y el manual
# para interpretar qué significa específicamente en cada variable.

colSums(is.na(data)) # cuenta cuántos valores perdidos hay en cada variable.


# 4. Revisar algunas variables -------------------------------------------

count(data, sexo) # cuenta observaciones según sexo.

count(data, zona_u_r) # cuenta observaciones según zona urbana o rural.

count(data, eval_gob_1) # cuenta observaciones según evaluación del gobierno.


# 5. Ejemplos de manipulación --------------------------------------------

# Filtrar únicamente a las personas que viven en zonas urbanas.
data_urbana <- data %>%
  filter(zona_u_r == 1)

# Contar observaciones por sexo dentro de la zona urbana.
data_urbana %>%
  count(sexo)

# Agrupar por sexo y resumir la edad.
data %>%
  group_by(sexo) %>%
  summarise(
    media_edad = mean(edad, na.rm = TRUE),
    mediana_edad = median(edad, na.rm = TRUE)
  )


# 6. Revisión sugerida por CEP -------------------------------------------

# CEP sugiere al final de su manual de usuario utilizar el paquete srvyr,
# es por esto que lo tenemos previamente cargado con pacman.

# Se declara el diseño de la encuesta.
cep <- data %>%
  as_survey(weights = pond,
            strata = estrato,
            ids = secu,
            nest = TRUE)


# Estimación del porcentaje de aprobación por sexo -----------------------

# Independiente de su posición política, usted ¿aprueba o desaprueba
# la forma como está conduciendo el PRESIDENTE el gobierno?

cep %>%
  group_by(sexo, eval_gob_1) %>%
  summarise(proportion = survey_prop())


# Estimación del porcentaje de aprobación de las personas que viven ------
# en zonas urbanas, por sexo ---------------------------------------------

cep %>%
  filter(zona_u_r == 1) %>%
  group_by(sexo, eval_gob_1) %>%
  summarise(proportion = survey_prop())

# 7. Visualizar variables -------------------------------------------------


# Evaluación del gobierno -------------------------------------------------

cep %>%
  group_by(eval_gob_1) %>%
  summarise(proportion = survey_prop()) %>%
  ggplot(aes(x = as_factor(eval_gob_1),
             y = proportion)) +
  geom_col() +
  labs(
    x = NULL,
    y = "Proporción",
    title = "Evaluación del gobierno"
  )


# Evaluación del gobierno por sexo ----------------------------------------

cep %>%
  group_by(sexo, eval_gob_1) %>%
  summarise(proportion = survey_prop()) %>%
  ggplot(aes(x = as_factor(eval_gob_1),
             y = proportion,
             fill = as_factor(sexo))) +
  geom_col(position = "dodge") +
  labs(
    x = NULL,
    y = "Proporción",
    fill = "Sexo",
    title = "Evaluación del gobierno por sexo"
  )


# Identificación política -------------------------------------------------

cep %>%
  group_by(iden_pol_2) %>%
  summarise(proportion = survey_prop()) %>%
  ggplot(aes(x = as_factor(iden_pol_2),
             y = proportion)) +
  geom_col() +
  labs(
    x = NULL,
    y = "Proporción",
    title = "Identificación política"
  )


# Identificación política por zona ----------------------------------------

cep %>%
  group_by(zona_u_r, iden_pol_2) %>%
  summarise(proportion = survey_prop()) %>%
  ggplot(aes(x = as_factor(iden_pol_2),
             y = proportion,
             fill = as_factor(zona_u_r))) +
  geom_col(position = "dodge") +
  labs(
    x = NULL,
    y = "Proporción",
    fill = "Zona",
    title = "Identificación política por zona"
  )



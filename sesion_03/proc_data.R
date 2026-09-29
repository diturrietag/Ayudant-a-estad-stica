
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

data <- readRDS("base_94.Rds")


# 3. Revisar datos --------------------------------------------------------

colnames(data) # muestra el nombre de todas las columnas.

dim(data) # muestra cuántas filas y columnas tiene la base.

glimpse(data) # muestra las variables, su tipo y algunos de sus valores.

head(data) # muestra las primeras 6 observaciones.

summary(data) # entrega un resumen descriptivo básico de cada variable.

# Para profundizar: ¿Cómo reviso datos perdidos? --------------------------

# Con datos perdidos nos vamos a referir cuando en nuestras observaciones veamos "NA" escrito con letras rojas, esto corresponde a valores que no fueron digitados en la encuesta, conviene revisar el diccionario de variables y los manuales para asegurarnos que significa especificamente según la institución.

colSums(is.na(data)) # cuenta cuántos valores perdidos hay en cada variable.

# 4. revision sugerida por cep --------------------------------------------

# CEP sugiere al final de su manual de usuario utilizar el paquete srvyr, es por esto que lo tenemos previamente cargado con pacman.

# Se declara el diseño de la encuesta
cep <- data %>% 
  as_survey(weights=pond, strata=estrato, ids=secu, nest=T)

# Estimación del pocentaje de aprobación por sexo

# Independiente de su posición política, usted ¿aprueba o desaprueba la forma como está conduciendo el PRESIDENTE el gobierno?
cep %>% 
  group_by(sexo, eval_gob_1) %>% 
  summarise(proportion = survey_prop())

# Estimación del porcentaje de aprobación de las personas que viven en zonas urbanas, por sexo

cep %>% 
  filter(zona_u_r==1) %>% 
  group_by(sexo, eval_gob_1) %>% 
  summarise(proportion = survey_prop())

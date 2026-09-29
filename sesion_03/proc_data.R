# instalar librerias ------------------------------------------------------

pacman::p_load(tidyr, # para trabajar variables como columnas, cada columna es una variable. Cada observación es una fila, cada fila es una observación. Cada valor es una celda, cada celda es un único valor.
               dplyr, # para manipular datos.
               ggplot2, # para crear gráficos.
               haven, # permite cargar datos en varios formatos.
               readxl, # para abrir archivos excel.
               srvyr) # para calcular estadisticos en datos tipo encuesta.


# Para profundizar: ¿Cómo se que hace cada librería? ----------------------

# tidyr: https://tidyr.tidyverse.org/
# dplyr: https://dplyr.tidyverse.org/
# ggplot2: https://ggplot2.tidyverse.org/
# haven: https://haven.tidyverse.org/
# readxl: https://readxl.tidyverse.org/
# srvyr: http://gdfe.co/srvyr/

# cargar datos ------------------------------------------------------------

data <- readRDS("base_94.Rds")


# revisar datos -----------------------------------------------------------

colnames(data)


data2 <- select(data, 
                )

# revision sugerida por cep -----------------------------------------------

# CEP sugiere utilizar el paquete srvyr, es por esto que lo tenemos previamente cargado con pacman.

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

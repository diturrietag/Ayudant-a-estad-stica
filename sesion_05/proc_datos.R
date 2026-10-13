
# carga de librerias/paquetes ---------------------------------------------

pacman::p_load(tidyr, # para trabajar variables como columnas, cada columna es una variable. Cada observación es una fila, cada fila es una observación. Cada valor es una celda, cada celda es un único valor.
               dplyr, # para manipular datos.
               ggplot2, # para crear gráficos.
               haven, # permite cargar datos en varios formatos.
               readxl, # para abrir archivos excel.
               srvyr, # para calcular estadisticos en datos tipo encuesta.
               haven) # carga datos tipo sav y dta


# cargar datos ------------------------------------------------------------
# comando dependiendo del archivo a trabajar.

cep95rds <- readRDS("cep95.rds") # carga de datos para archivos .rds
cep95sav <- read_sav("cep95.sav") # carga de datos para archivos .sav
cep95csv <- read.csv("cep95.csv") # carga de datos para archivos .csv
cep95dta <- read_dta("cep95.dta") # carga de datos para archivos .dta


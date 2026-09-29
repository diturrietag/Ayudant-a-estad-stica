# instalar librerias ------------------------------------------------------

pacman::p_load(tidyr,
               dplyr,
               ggplot,
               haven,
               readxl) # para abrir archivos excel.


# cargar datos ------------------------------------------------------------

data <- readRDS("base_94.Rds")

data2 <- select(data, 
                )
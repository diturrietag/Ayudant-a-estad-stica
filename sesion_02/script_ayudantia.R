
# presentación y manual metodológico --------------------------------------

# https://manual-metodologico-elsoc.netlify.app/

# objetos -----------------------------------------------------------------

1+2
suma <- 1+3
mensaje <- "Buenos días estudiantes"
mensaje

# Vectores ----------------------------------------------------------------

vector_1 <- c(1,2,3,4)
vector_2 <- 1:4
vector_3 <- seq(1, 4, by = 0.5)
vector_4 <- rep(1, times = 5)

# data frame --------------------------------------------------------------

ejemplo <- data.frame(
  edad=c(15,18,22),
  genero=c("Masculino", "Femenino", "No binario"),
  trabaja=c("Sí", "No", "NS/NR")
)

# librerias ----------------------------------------------------------------

library(haven) #Este comando nos permite ejecutar el paquete

#si aun no esta instalado se intala con: install.packages("dplyr")
library(dplyr)

# carga dataset -----------------------------------------------------------

base <- read_sav("ELSOC_2021.sav")

# explorar base
head(base) #solo muestra 6 primeros casos

# ver estructura datos
str(base[,1:5])

# selección variables y casos

colnames(base[,1:10]) #los corchetes son solo para seleccionar los primeros 10 casos, si queremos conocer los nombres de todas las variables utilizamos solo: colnames(base)



# definir nomrbes más amigables con el lenguaje natural -------------------

basefiltrada <- select(base,
                       comuna=comuna,
                       region=region, 
                       perseg=t10, 
                       pol=c15, 
                       esp=c18_08,
                       edad=m0_edad,
                       ingreso=m13,
                       horas= m12)


basefiltradametro <- filter(basefiltrada, region %in% 
                              c("Metropolitana 
                    De Santiago",
                                "Biobío", 
                                "Valparaíso"))


# misma operación pero con pipes ------------------------------------------

basefiltradametro <- base %>% 
  select(comuna=comuna, region=region,perseg=t10, 
         pol=c15, esp=c18_08, edad=m0_edad, ingreso=m13,horas= m12) %>%
  filter(region %in% c("Metropolitana De Santiago",
                       "Biobío", "Valparaíso"))

# Crear el resumen de los datos y renderizarlo en HTML
#para poder utilizarla primero instalamos install.packages(summarytools)
install.packages("summarytools")
library (summarytools)

resumen <- dfSummary(basefiltrada)

print(resumen, headings = FALSE)



# valores perdidos --------------------------------------------------------
# En el caso de la encuesta ELSOC, todos los valores negativos representan valores perdidos. Por ello, debemos decidir si quitarlos o recodificarlos.

# En este caso los declaramos de la siguiente manera:


basefiltrada[] <- lapply(basefiltrada, function(x) replace(x, x %in% c(0,888,999,-888,-999), NA))


# revisión valores perdidos -----------------------------------------------

sum(is.na(basefiltrada)) #solo NA

#En la variable
summary(basefiltrada$ingreso)


# eliminar valores perdidos -----------------------------------------------

#y si los queremos eliminar lo hacemos con la funcion 

basefiltrada <- na.omit(basefiltrada)


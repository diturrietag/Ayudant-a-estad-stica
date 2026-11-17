
# 0. preparar el proyecto ----------------------------------------------------
# abre el rproject de la ayudantía y mueve la base cep95_clase.csv a su carpeta.

pacman::p_load(dplyr, tidyr, ggplot2)

cep95 <- read.csv("cep95_clase.csv")


# 1. seleccionar variables y casos -------------------------------------------

# a) objeto con seis variables
cep_sel <- cep95 %>%
  select(sexo, edad, voto_1v, interes_pol, aprob_pdte, escala_izq_der)

# b) comparar el número de variables
ncol(cep95)   # 8 variables
ncol(cep_sel) # 6 variables
# respuesta: cep95 tiene 8 variables y cep_sel tiene 6. las filas no cambian (1.217).

# c) personas de 60 años o más
cep_sel %>% filter(edad >= 60) %>% nrow()
# respuesta: 409 personas.

# d) mujeres menores de 30 años (dos condiciones separadas por coma)
cep_sel %>% filter(sexo == "Mujer", edad < 30) %>% nrow()
# respuesta: 121 mujeres.


# 2. limpiar y recodificar ---------------------------------------------------

cep_sel <- cep_sel %>%
  rename(ideologia = escala_izq_der) %>%                     # a) nuevo nombre
  mutate(tramo_edad = case_when(edad < 30 ~ "18-29",         # b) tramos de edad
                                edad < 45 ~ "30-44",
                                edad < 60 ~ "45-59",
                                edad >= 60 ~ "60 o más"),
         interes = case_when(interes_pol %in% c("Nada", "No muy") ~ "Bajo interés",   # c)
                             interes_pol %in% c("Algo", "Bastante",
                                                "Muy interesado") ~ "Alto interés"))

# d) revisar las variables nuevas
table(cep_sel$tramo_edad)
table(cep_sel$interes)
# respuesta: el tramo "60 o más" es el más numeroso (409 personas).
# interes queda casi en partes iguales: 604 alto y 607 bajo.

# e) respuesta: al conservar la variable original podemos comparar y corregir
# errores de recodificación sin volver a cargar la base.


# 3. valores perdidos (NA) ---------------------------------------------------

# a) NA por variable
colSums(is.na(cep_sel))
# respuesta: ideologia tiene más NA (265), seguida de aprob_pdte (49) y voto_1v (9).
# interes hereda los 6 NA de interes_pol: case_when no inventa respuestas.

# b) porcentaje de NA en ideologia
mean(is.na(cep_sel$ideologia)) * 100
# respuesta: 21,8% no se ubicó en la escala.

# c) respuesta: muchas personas no se identifican con la izquierda ni la derecha,
# no conocen la escala o prefieren no responder. el NA también es información.

# d) eliminar NA en todas las variables vs. solo en ideologia
nrow(drop_na(cep_sel))            # 920 filas
nrow(drop_na(cep_sel, ideologia)) # 952 filas
# respuesta: drop_na(cep_sel) elimina a quien tenga NA en cualquier variable,
# por eso pierde más casos. conviene eliminar NA solo en las variables que usaremos.

# e) media de ideologia
mean(cep_sel$ideologia)               # NA
mean(cep_sel$ideologia, na.rm = TRUE) # 5,58
# respuesta: sin na.rm = TRUE el resultado es NA, porque R no puede promediar
# un valor desconocido. con na.rm = TRUE la media es 5,58 (centro de la escala).


# 4. tabla de contingencia ---------------------------------------------------

# a) frecuencias
tabla_1 <- table(cep_sel$tramo_edad, cep_sel$interes)
tabla_1

# b) porcentajes por fila
round(prop.table(tabla_1, margin = 1) * 100, 1)

# c) respuesta: el tramo 18-29 tiene el mayor porcentaje de alto interés (60,3%).
# el interés baja con la edad: en "60 o más" solo el 36,9% tiene alto interés.

# d) respuesta: los tramos tienen distinto tamaño (210 vs. 409 personas), así que
# las frecuencias no se pueden comparar directamente. los porcentajes por fila
# ponen a todos los tramos en la misma base (100).


# 5. gráficos sencillos ------------------------------------------------------

# a) barras con NA
ggplot(cep_sel, aes(x = aprob_pdte)) +
  geom_bar()
# respuesta: aparece una barra "NA" con las 49 personas que no respondieron.

# b) barras sin NA
cep_sel %>%
  filter(!is.na(aprob_pdte)) %>%
  ggplot(aes(x = aprob_pdte)) +
  geom_bar() +
  labs(title = "Aprobación del presidente",
       x = "Evaluación", y = "Número de personas")

# c) barras al 100% de tramo_edad según interes
cep_sel %>%
  filter(!is.na(interes)) %>%
  ggplot(aes(x = tramo_edad, fill = interes)) +
  geom_bar(position = "fill") +
  labs(title = "Interés en política según tramo de edad",
       x = "Tramo de edad", y = "Proporción", fill = "Interés")

# d) respuesta: sí. la parte de "Alto interés" se achica a medida que aumenta
# la edad, igual que en los porcentajes por fila de la tabla_1.


# 6. objeto con media y mediana ----------------------------------------------

# a), b) y c) objeto con n, media, mediana y diferencia por candidato
resumen_edad <- cep_sel %>%
  filter(voto_1v %in% c("Jara", "Kast", "Parisi")) %>%   # a) tres grupos
  group_by(voto_1v) %>%                                   # b) un resumen por grupo
  summarise(n = n(),
            media = round(mean(edad), 1),
            mediana = median(edad)) %>%
  mutate(diferencia = media - mediana)                    # c) distancia entre ambas

resumen_edad
# voto_1v   n   media  mediana  diferencia
# Jara     301  50.7     52       -1.3
# Kast     266  48.9     48        0.9
# Parisi   102  41.4     38        3.4

# d) respuesta: en los votantes de Parisi (la media supera a la mediana en 3,4 años).
# e) respuesta: en Jara y Kast la diferencia es de alrededor de 1 año: sus
# distribuciones de edad son casi simétricas.


# 7. graficar media y mediana ------------------------------------------------

# a), b) y c) histograma de los votantes de Parisi
parisi <- cep_sel %>% filter(voto_1v == "Parisi")

ggplot(parisi, aes(x = edad)) +
  geom_histogram(binwidth = 5, fill = "grey70", color = "white") +
  geom_vline(xintercept = mean(parisi$edad), color = "red") +                       # media
  geom_vline(xintercept = median(parisi$edad), color = "blue", linetype = "dashed") + # mediana
  labs(title = "Edad de los votantes de Parisi",
       subtitle = "Línea roja = media (41,4) | línea azul punteada = mediana (38)",
       x = "Edad", y = "Número de personas")

# d) histograma de los votantes de Jara
jara <- cep_sel %>% filter(voto_1v == "Jara")

ggplot(jara, aes(x = edad)) +
  geom_histogram(binwidth = 5, fill = "grey70", color = "white") +
  geom_vline(xintercept = mean(jara$edad), color = "red") +
  geom_vline(xintercept = median(jara$edad), color = "blue", linetype = "dashed") +
  labs(title = "Edad de los votantes de Jara",
       subtitle = "Línea roja = media (50,7) | línea azul punteada = mediana (52)",
       x = "Edad", y = "Número de personas")

# e) respuesta: la de Parisi es asimétrica. la mayoría de sus votantes tiene
# entre 20 y 35 años, y hay menos personas mayores que forman una cola hacia
# la derecha (asimetría positiva). la de Jara se reparte de forma pareja entre
# los 20 y los 80 años, y ambas líneas quedan casi juntas.

# f) respuesta: la media queda a la derecha de la mediana. la media usa el valor
# de cada persona, así que las edades altas de la cola la "arrastran" hacia
# arriba. la mediana solo mira el centro de los datos ordenados, por eso
# no se mueve tanto. en una distribución asimétrica, la mediana describe
# mejor el caso típico.

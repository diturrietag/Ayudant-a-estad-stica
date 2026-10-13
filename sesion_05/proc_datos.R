
# 1. carga de librerias/paquetes ---------------------------------------------

pacman::p_load(tidyr, # para trabajar variables como columnas, cada columna es una variable. Cada observación es una fila, cada fila es una observación. Cada valor es una celda, cada celda es un único valor.
               dplyr, # para manipular datos.
               ggplot2, # para crear gráficos.
               haven, # permite cargar datos en varios formatos.
               readxl, # para abrir archivos excel.
               srvyr, # para calcular estadisticos en datos tipo encuesta.
               haven) # carga datos tipo sav y dta


# 2. cargar datos ------------------------------------------------------------
# comando dependiendo del archivo a trabajar.

cep95rds <- readRDS("cep95.rds") # carga de datos para archivos .rds
cep95sav <- read_sav("cep95.sav") # carga de datos para archivos .sav
cep95csv <- read.csv("cep95.csv") # carga de datos para archivos .csv
cep95dta <- read_dta("cep95.dta") # carga de datos para archivos .dta

# Pregunta: donde debo clickear para eliminar los objetos creados?

# 3. revisar dataset ---------------------------------------------------------

colnames(cep95rds) # muestra el nombre de todas las columnas.

dim(cep95rds) # muestra cuántas filas y columnas tiene la base.

glimpse(cep95rds) # muestra las variables, su tipo y algunos de sus valores.

head(cep95rds) # muestra las primeras 6 observaciones.

summary(cep95rds) # entrega un resumen descriptivo básico de cada variable.

# 4. selección de variables --------------------------------------------------
# Creamos un objeto nuevo solo con las variables que usaremos en clase.
# Con select() elegimos columnas y, en el mismo paso, les damos un nombre
# más fácil de recordar (nombre_nuevo = nombre_original).

options(scipen = 999) # evita que R muestre resultados en notación científica.

cep95_clase <- cep95rds %>%
  zap_labels() %>% # quita las etiquetas de haven para trabajar con números simples.
  select(
    # sociodemográficas
    sexo            = sexo,             # sexo del entrevistado.
    edad            = edad,             # edad en años.
    zona            = zona_u_r,         # zona urbana o rural.
    region          = region_3,         # región de residencia.
    gse             = gse,              # grupo socioeconómico (ABC1 a E).
    educacion       = esc_nivel_1_c,    # nivel educacional alcanzado.
    ingreso_hogar   = info_hogar_3_c,   # tramo de ingreso líquido del hogar.
    # identificación y comportamiento político
    escala_izq_der  = iden_pol_2,       # autoubicación 1 (izquierda) a 10 (derecha).
    interes_pol     = interes_pol_1_b,  # interés en la política.
    voto_1v         = elec_pres_urna_30,# voto simulado en urna, primera vuelta 2025.
    intencion_voto  = elec_part_4,      # intención de ir a votar.
    aprob_pdte      = eval_gob_1,       # aprobación del Presidente.
    # democracia e instituciones
    apoyo_democ     = democracia_21,    # preferencia por la democracia.
    funciona_democ  = democracia_20,    # evaluación del funcionamiento de la democracia.
    conf_partidos   = confianza_6_j,    # confianza en partidos políticos.
    conf_congreso   = confianza_6_k,    # confianza en el Congreso.
    conf_gobierno   = confianza_6_i,    # confianza en el Gobierno.
    conf_elecciones = confianza_17,     # confianza en el proceso electoral.
    # actitudes y opiniones (escalas numéricas)
    termo_derecha   = polarizacion_1_a, # opinión sobre personas de derecha (0 a 10).
    termo_izquierda = polarizacion_1_b, # opinión sobre personas de izquierda (0 a 10).
    igualdad_esfuerzo = pobreza_62,     # 1 ingresos más iguales ... 10 premiar el esfuerzo.
    estado_individuo  = pobreza_63,     # 1 responsabilidad del Estado ... 10 de las personas.
    libertad_orden    = democracia_38,  # 0 garantizar libertades ... 10 suprimir libertades.
    satisf_vida     = bienestar_2,      # satisfacción con la vida (1 a 10).
    # percepciones y temas
    econ_pais       = percepcion_2,     # evaluación de la situación económica del país.
    rumbo_pais      = percepcion_4,     # Chile progresando, estancado o en decadencia.
    problema_1      = percepcion_1_a,   # primer problema al que el gobierno debería dedicar esfuerzo.
    aborto          = religion_14,      # postura frente al aborto.
    # ponderador
    pond            = pond              # factor de expansión de la encuesta.
  )

dim(cep95_clase) # comprobamos: mismas filas (personas) y menos columnas.

# Pregunta: ¿cuántas filas y columnas tiene cep95_clase? ¿por qué las filas no cambian?
# Respuesta: 1217 filas y 29 columnas. Las filas no cambian porque select()
# solo elige columnas (variables); no elimina personas.


# 5. valores perdidos --------------------------------------------------------
# En la encuesta CEP, -8 = "No sabe" y -9 = "No contesta". No son valores reales
# de la variable: si los dejamos, R los usaría para calcular promedios.

summary(cep95_clase$escala_izq_der) # el mínimo es -9: el promedio está distorsionado.

cep95_clase <- cep95_clase %>%
  mutate(across(everything(), ~ replace(.x, .x %in% c(-8, -9), NA)), # -8 y -9 pasan a NA.
         voto_1v = replace(voto_1v, voto_1v == 12, NA))               # 12 = folio no pareado.

summary(cep95_clase$escala_izq_der) # ahora el mínimo es 1 y aparecen los NA.

# Pregunta: ¿cuántas personas no se ubicaron en la escala izquierda-derecha?
# Respuesta: 265 personas (158 "No sabe" y 107 "No contesta").


# 6. nivel de medición: crear factores --------------------------------------
# Variables nominales -> factor(): categorías sin orden.
# Variables ordinales -> factor(..., ordered = TRUE): categorías con orden.
# Variables intervalares/razón -> se quedan numéricas (edad, escalas 0-10 y 1-10).
# En los ordinales ponemos los niveles de menor a mayor, para que "más alto" signifique "más".

cep95_clase <- cep95_clase %>%
  mutate(
    # nominales
    sexo = factor(sexo, levels = 1:2, labels = c("Hombre", "Mujer")),
    zona = factor(zona, levels = 1:2, labels = c("Urbana", "Rural")),
    region = factor(region, levels = c(15, 1:5, 13, 6, 7, 16, 8, 9, 14, 10, 11, 12), # orden norte a sur.
                    labels = c("Arica y Parinacota", "Tarapacá", "Antofagasta", "Atacama",
                               "Coquimbo", "Valparaíso", "Metropolitana", "O'Higgins", "Maule",
                               "Ñuble", "Biobío", "La Araucanía", "Los Ríos", "Los Lagos",
                               "Aysén", "Magallanes")),
    voto_1v = factor(voto_1v, levels = 1:11,
                     labels = c("Artés", "Enríquez-Ominami", "Jara", "Kaiser", "Kast",
                                "Matthei", "Mayne-Nicholls", "Parisi", "Nulo", "Blanco", "No vota")),
    aprob_pdte = factor(aprob_pdte, levels = c(1, 3, 2),
                        labels = c("Aprueba", "Ni aprueba ni desaprueba", "Desaprueba")),
    apoyo_democ = factor(apoyo_democ, levels = 1:3,
                         labels = c("Democracia siempre preferible",
                                    "A veces autoritarismo preferible",
                                    "Da lo mismo")),
    problema_1 = factor(problema_1,
                        levels = c(1:14, 16, 17, 26),
                        labels = c("Pensiones", "Corrupción", "Delincuencia", "Derechos humanos",
                                   "Educación", "Empleo", "Pobreza", "Medio ambiente",
                                   "Narcotráfico", "Salud", "Sueldos", "Transporte público",
                                   "Vivienda", "Inmigración", "Desigualdad", "Inflación",
                                   "Violencia")),
    aborto = factor(aborto, levels = 1:3,
                    labels = c("Siempre prohibido", "Solo en casos especiales",
                               "Opción de la mujer en cualquier caso")),
    
    # ordinales
    gse = factor(gse, levels = 5:1, labels = c("E", "D", "C3", "C2", "ABC1"), ordered = TRUE),
    educacion = factor(educacion, levels = 0:10,
                       labels = c("Sin estudios", "Básica incompleta", "Básica completa",
                                  "Media incompleta", "Media completa", "Técnica incompleta",
                                  "Técnica completa", "Universitaria incompleta",
                                  "Universitaria completa", "Postgrado incompleto",
                                  "Postgrado completo"),
                       ordered = TRUE),
    ingreso_hogar = factor(ingreso_hogar, levels = 1:11,
                           labels = c("Menos de $95 mil", "$95 mil a $387 mil",
                                      "$387 mil a $551 mil", "$551 mil a $670 mil",
                                      "$670 mil a $842 mil", "$842 mil a $1,04 millones",
                                      "$1,04 a $1,16 millones", "$1,16 a $1,50 millones",
                                      "$1,50 a $2,00 millones", "$2,00 a $3,16 millones",
                                      "Más de $3,16 millones"),
                           ordered = TRUE),
    interes_pol = factor(interes_pol, levels = 5:1,
                         labels = c("Nada", "No muy", "Algo", "Bastante", "Muy interesado"),
                         ordered = TRUE),
    intencion_voto = factor(intencion_voto, levels = 4:1,
                            labels = c("Seguro no vota", "Probablemente no",
                                       "Probablemente sí", "Seguro vota"),
                            ordered = TRUE),
    funciona_democ = factor(funciona_democ, levels = 1:5,
                            labels = c("Muy mal", "Mal", "Regular", "Bien", "Muy bien"),
                            ordered = TRUE),
    across(c(conf_partidos, conf_congreso, conf_gobierno, conf_elecciones), # misma escala para las 4.
           ~ factor(.x, levels = 4:1,
                    labels = c("Nada", "Poca", "Bastante", "Mucha"),
                    ordered = TRUE)),
    econ_pais = factor(econ_pais, levels = 1:5,
                       labels = c("Muy mala", "Mala", "Ni buena ni mala", "Buena", "Muy buena"),
                       ordered = TRUE),
    rumbo_pais = factor(rumbo_pais, levels = 3:1,
                        labels = c("En decadencia", "Estancado", "Progresando"),
                        ordered = TRUE)
  )


# 7. variables nuevas a partir de otras --------------------------------------
# A veces conviene agrupar una variable numérica en categorías.

cep95_clase <- cep95_clase %>%
  mutate(
    # posición política en tres grupos (agrupación habitual de la encuesta CEP).
    posicion_pol = case_when(
      escala_izq_der %in% 1:4  ~ "Izquierda",
      escala_izq_der %in% 5:6  ~ "Centro",
      escala_izq_der %in% 7:10 ~ "Derecha",
      is.na(escala_izq_der)    ~ "No se ubica"),       # quienes no saben o no contestan.
    posicion_pol = factor(posicion_pol,
                          levels = c("Izquierda", "Centro", "Derecha", "No se ubica")),
    # edad en tramos.
    tramo_edad = cut(edad,
                     breaks = c(17, 29, 44, 59, Inf),  # límites de cada tramo.
                     labels = c("18-29", "30-44", "45-59", "60 y más"),
                     ordered_result = TRUE)
  )

glimpse(cep95_clase) # revisamos: <fct> nominal, <ord> ordinal, <dbl>/<int> numérica.


# 8. guardar el objeto -------------------------------------------------------

saveRDS(cep95_clase, "cep95_clase.rds") # guarda el objeto en la carpeta del proyecto.

# Para usarlo en otra clase: cep95_clase <- readRDS("cep95_clase.rds")


# 9. medidas de tendencia central --------------------------------------------
# Qué medida usar depende del nivel de medición:
#   nominal   -> moda
#   ordinal   -> moda y mediana
#   intervalar/razón -> moda, mediana y media

# 9.1 Variables numéricas: media y mediana
cep95_clase %>%
  summarise(media_edad    = mean(edad, na.rm = TRUE),    # na.rm = TRUE ignora los NA.
            mediana_edad  = median(edad, na.rm = TRUE),
            media_izq_der   = mean(escala_izq_der, na.rm = TRUE),
            mediana_izq_der = median(escala_izq_der, na.rm = TRUE))

# Pregunta: ¿qué pasa si calculamos mean(cep95_clase$escala_izq_der) sin na.rm = TRUE?
# Respuesta: R devuelve NA, porque no puede promediar valores que no conoce.

# Pregunta: ¿cuál es la edad promedio y la mediana de edad? ¿qué significa la mediana?
# Respuesta: media 50,1 años y mediana 51 años. La mitad de los entrevistados
# tiene 51 años o menos y la otra mitad 51 años o más.

# Comparar la media de un grupo con otro: group_by() + summarise()
cep95_clase %>%
  group_by(posicion_pol) %>%
  summarise(media_termo_derecha   = mean(termo_derecha, na.rm = TRUE),
            media_termo_izquierda = mean(termo_izquierda, na.rm = TRUE))

# Pregunta: ¿cómo evalúan las personas de izquierda a las personas de derecha, y viceversa?
# Respuesta: quienes se ubican en la izquierda evalúan a las personas de derecha con 2,6
# en promedio (escala 0 a 10) y quienes se ubican en la derecha evalúan a las personas
# de izquierda con 2,5. Cada grupo tiene una opinión negativa del otro (bajo 5, el punto
# neutro) y positiva de su propio sector (6,5 y 7,0).

# 9.2 Variables nominales: la moda es la categoría más frecuente
cep95_clase %>%
  count(problema_1, sort = TRUE) # sort = TRUE ordena de mayor a menor: la primera fila es la moda.

cep95_clase %>%
  count(voto_1v, sort = TRUE)

# Pregunta: ¿cuál es la moda del voto simulado en primera vuelta?
# Respuesta: Jeannette Jara (301 casos), seguida de José Antonio Kast (266).

# 9.3 Variables ordinales: moda y mediana
cep95_clase %>%
  count(interes_pol, sort = TRUE) # moda.

# La mediana necesita un orden numérico: as.numeric() convierte cada nivel en su posición
# (1 = Nada, 2 = No muy, 3 = Algo, 4 = Bastante, 5 = Muy interesado).
median(as.numeric(cep95_clase$interes_pol), na.rm = TRUE)
levels(cep95_clase$interes_pol)[3] # traducimos la posición 3 a su etiqueta.

# Pregunta: ¿cuál es la moda y la mediana del interés en la política?
# Respuesta: la moda es "Nada" (397 casos), pero la mediana es "Algo" (posición 3):
# la persona del medio, ordenando de menos a más interés, está "Algo interesada".

# Pregunta: ¿por qué no calculamos la media de sexo o de voto_1v?
# Respuesta: son nominales. Sus números solo identifican categorías y no tienen
# orden ni distancia, así que un promedio no tendría sentido.


# 10. gráficos básicos con ggplot2 -------------------------------------------
# Estructura: ggplot(datos, aes(x = variable)) + geom_tipo() + labs(textos)

# 10.1 Gráfico de barras: variable nominal
cep95_clase %>%
  filter(!is.na(voto_1v)) %>%                           # sacamos los NA del gráfico.
  ggplot(aes(x = forcats::fct_infreq(voto_1v))) +       # ordena las barras de mayor a menor.
  geom_bar(fill = "steelblue") +
  labs(title = "Voto simulado en primera vuelta presidencial",
       subtitle = "Encuesta CEP N°95 (2025)",
       x = "Candidato/a u opción",
       y = "Número de personas") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) # gira las etiquetas para que se lean.

# 10.2 Gráfico de barras: variable ordinal (se respeta el orden de los niveles)
cep95_clase %>%
  filter(!is.na(conf_partidos)) %>%
  ggplot(aes(x = conf_partidos)) +
  geom_bar(fill = "darkred") +
  labs(title = "Confianza en los partidos políticos",
       subtitle = "Encuesta CEP N°95 (2025)",
       x = "Nivel de confianza",
       y = "Número de personas") +
  theme_minimal()

# 10.3 Histograma: variable numérica
ggplot(cep95_clase, aes(x = edad)) +
  geom_histogram(binwidth = 5, fill = "grey40", color = "white") + # barras de 5 años.
  geom_vline(xintercept = mean(cep95_clase$edad), color = "red", linetype = "dashed") + # línea en la media.
  labs(title = "Distribución de la edad de los entrevistados",
       subtitle = "La línea roja marca la edad promedio",
       x = "Edad (años)",
       y = "Número de personas") +
  theme_minimal()

# 10.4 Gráfico de barras de una escala 1 a 10
cep95_clase %>%
  filter(!is.na(escala_izq_der)) %>%
  ggplot(aes(x = factor(escala_izq_der))) +             # factor() para una barra por valor.
  geom_bar(fill = "purple4") +
  labs(title = "Autoubicación en la escala izquierda-derecha",
       subtitle = "1 = izquierda, 10 = derecha. Excluye a quienes no se ubican",
       x = "Posición en la escala",
       y = "Número de personas") +
  theme_minimal()

# Pregunta: ¿qué valores de la escala concentran más personas?
# Respuesta: el 5 (358 personas), seguido del 10 (134) y el 1 (94).

# 10.5 Boxplot: una variable numérica comparada entre grupos
cep95_clase %>%
  filter(!is.na(aprob_pdte), !is.na(escala_izq_der)) %>%
  ggplot(aes(x = aprob_pdte, y = escala_izq_der)) +
  geom_boxplot(fill = "lightblue") +                     # la línea gruesa es la mediana.
  labs(title = "Posición izquierda-derecha según aprobación del Presidente",
       x = "Aprobación del Presidente",
       y = "Escala izquierda (1) - derecha (10)") +
  theme_minimal()

# Pregunta: ¿qué diferencia se observa en la mediana entre quienes aprueban y desaprueban?
# Respuesta: quienes aprueban tienen mediana 4 (más a la izquierda) y quienes
# desaprueban tienen mediana 6 (más a la derecha).

# 10.6 Barras apiladas en porcentaje: dos variables categóricas
cep95_clase %>%
  filter(!is.na(apoyo_democ)) %>%
  ggplot(aes(x = tramo_edad, fill = apoyo_democ)) +
  geom_bar(position = "fill") +                          # "fill" lleva cada barra a 100%.
  scale_y_continuous(labels = scales::percent) +         # eje y en porcentaje.
  labs(title = "Preferencia por la democracia según tramo de edad",
       x = "Tramo de edad",
       y = "Porcentaje",
       fill = "Opinión") +
  theme_minimal() +
  theme(legend.position = "bottom", legend.direction = "vertical")
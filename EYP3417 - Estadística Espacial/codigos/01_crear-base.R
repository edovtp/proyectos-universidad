library(sf)
library(readxl)
library(dplyr)


# Mapa de Santiago
presidenciales_santiago <- chilemapas::mapa_comunas %>% 
  dplyr::filter(codigo_provincia == 131 | codigo_comuna == 13201) %>%
  dplyr::left_join(chilemapas::codigos_territoriales, by = "codigo_comuna") %>% 
  dplyr::select(nombre_comuna, geometry) %>% 
  dplyr::mutate(nombre_comuna = toupper(nombre_comuna)) %>% 
  dplyr::mutate(nombre_comuna = case_when(
    nombre_comuna == "PENALOLEN" ~ "PEÑALOLEN",
    nombre_comuna == "NUNOA" ~ "ÑUÑOA",
    TRUE ~ nombre_comuna
  )) %>% 
  sf::st_as_sf() %>% 
  sf::st_transform(crs = "WGS84")

# Carga de datos del SERVEL
primera_2017 <- readxl::read_xlsx("./datos/2017_presidencial-primera-vuelta.xlsx") %>% 
  dplyr::select(Comuna, `Inscritos Total`, Votación) %>% 
  dplyr::rename(nombre_comuna = Comuna,
                inscritos_2017_1 = `Inscritos Total`,
                votos_2017_1 = Votación) %>% 
  dplyr::mutate(tasa_participación_2017_1 = votos_2017_1/inscritos_2017_1)

segunda_2017 <- readxl::read_xlsx("./datos/2017_presidencial-segunda-vuelta.xlsx") %>% 
  dplyr::select(Comuna, `Inscritos Total`, Votación) %>% 
  dplyr::rename(nombre_comuna = Comuna,
                inscritos_2017_2 = `Inscritos Total`,
                votos_2017_2 = Votación) %>% 
  dplyr::mutate(tasa_participación_2017_2 = votos_2017_2/inscritos_2017_2)

# Datos completos + mapa de Santiago
presidenciales_santiago <- presidenciales_santiago %>%
  dplyr::left_join(primera_2017) %>% 
  dplyr::left_join(segunda_2017) %>% 
  dplyr::relocate(geometry, .after = last_col())

# Agregar datos comunales
Pudahuel <- c(682588, 112412, 117881, 28298, 77232753, 18453070, 67, 34648, 22541866,
              21, 14.5, 7.77, 8.2, 18.8)
CerroNavia <-c(621411, 65438, 67184, 20814, 35921515, 13652672, 50, 17343, 13491329,
               9, 12.3, 12.07, 13.5, 21.5)
Huechuraba <- c(734468, 48122, 50549, 9559, 37666341, 10634485, 28, 14834, 10707023, 8,
                15.5, 5.64, 8.6, 19.1)
Conchali <- c(665328, 61877, 65078, 12830, 37564739, 16085850, 61, 21061, 13447127, 12,
              12.6, 10.17, 8.6, 17.3)
LaPintana <- c(656093, 87044, 90291, 27540, 28453440, 12144579, 72, 36945, 19518168, 14,
               14.5, 13.86, 4.8, 24.8)
ElBosque <- c(756117, 79372, 83133, 19337, 25636734, 15312351, 96, 38367, 19313217, 13,
              12.1, 14.54, 5.9, 18.1)
EstacionCentral <- c(778255, 73458, 73583, 15734, 30268488, 15445117, 60, 24389, 13060640,
                     16, 13.1, 6.16, 14.4, 17.7)
PedroAguirreCerda <- c(696279, 49513, 51661, 10647, 14546893, 8813776, 51, 15885,
                       12159519, 10, 10.3, 11.02, 9.8, 18.9)
Recoleta <- c(589072, 77709, 80142, 16592, 30868459, 17250394, 70, 32717, 12615918, 11,
              13.8, 13.86, 13.7, 20.2)
Independencia <- c(624394, 49186, 51095, 7173, 15532220, 9206731, 38, 19542, 6205204, 13,
                   17.9, 8.5, 6.8, 20)
LoEspejo <- c(778900, 49146,49658,11188,16641259,8443396,38,12195,11870564,10,11.3,
              6.69,9.8,25.4)
LaCisterna <- c(1093429, 43147,46972,8122,15427915,6162345,65,27382,6246245,8,12.4,
                6.6,21.9,18.0)
LaFlorida <- c(1013375, 175693,	191223,37510	,109421823,28356359,200,79871,41940063,
               36,12.2, 3.11,4.3,17)
Peñalolen <- c(809779, 116882	,124717	,30534	,81445211,15685197,72,37717,20243711,
               19,15.1,4.75, 9.9,19.5)
LasCondes <- c(2678127, 135917,158921	,9670	,298786475,19132901,64,40889,15787623,
               30,13.9,0.56,1.4,5.4)
LaReina <- c(2312882, 43599,49188,5885,32560940,9588274,44,22055,6403489,14,9.1,0.99,
             6.0,13.0)
LoBarnechea <- c(1930652, 50500,55333,5275		,89217999,7279591,32,21871,6608581,
                 12,12.4,2.84,8.2, 18.8)
Vitacura <- c(3177830, 38402,	46982	,2413	,91378435,5982378,19,19977,3165527,16,
              14,0.13,0.6,3.2)
QtaNormal <- c(833626, 53669	,56357	,10967,25555211,14993072,72,26131,7757192,12,
               13.7,5.94,9.1, 18.8)
LoPrado <- c(733922, 46799,	49450	,13274	,34948614,12179592,31,12100,14579619,9,11.5,
             5.78,14.0,19.2)
Cerrillos <- c(865008, 39631	,41201	,8958,21580544,7055966,36,13112,6394246,8,13.6,
               6.48, 6.1,16.4)
Maipu <- c(1007694, 250792	,270835	,51728	,115390044,38476867,213,101617,
           16164742,30,12.9,5.24,3.0,12.4)
Macul <- c(1141524, 55161,	61373, 11551, 39016757,9307475,42,16238	,13853036,11,12.6,
           5.32, 7.9,14.7)
Ñuñoa <- c(2295026, 95409, 112828, 14099, 58170753, 21575094,82,37840,11949822,24,
           13.7,2.41,6.9,7.5)
PteAlto <- c(726208, 275147,292959,62337,90368289,47469754,207,108978,36851142,39,
             13.9,8.02, 1.9,16.1)
Quilicura <- c(1115318, 103456,106954,23147,49840083,18142432,61,42680,17981407,16,
               14.7,7.82,2.9,16.1)
Renca <- c(770930, 72681,74470,19683,46531213,12160573,61,25776,10891475,8,15.2,8.54,
           8.4,18.3)
SanJoaquin <- c(953265, 45831,48661	,9725,32866065,8362687,41,11317,10354925,13,
                11.6,5.24,13.4,19.2)
SanMiguel <- c(1215206, 50738,57216,8258,27193812,6357099,60,24998,6394246,20,13.1,
               3.46,6.0,13.0)
SanRamon <- c(717083, 40873, 42027,10972,14461810,9483165,38,15051,10320239,10,13,
              4.6,8.6,22.2)
LaGranja <- c(626947, 57025,59546,14394,20878986,10683991,55,20594,19467725,10,12.4,7.22,
              8.4,20.5)
Providencia <- c(2307348, 65710,76369,7033,127373568,20590202,51,32071,10265355,74,
                 14.1,0.74, 3.0,5.4)
Santiago <- c(1400581, 206678,197817,32817,158398296,62308022,137,85877,13060640,65,
              15.2,5.93, 21.3,18.8)

datos_comunales <- data.frame(Pudahuel, CerroNavia, Huechuraba, Conchali, LaPintana,
                              ElBosque, EstacionCentral, PedroAguirreCerda,
                              Recoleta, Independencia, LoEspejo, LaCisterna, LaFlorida,
                              Peñalolen, LasCondes, LaReina, LoBarnechea, Vitacura,
                              QtaNormal, LoPrado, Cerrillos, Maipu, Macul, Ñuñoa, 
                              PteAlto, Quilicura, Renca, SanJoaquin, SanMiguel, SanRamon,
                              LaGranja, Providencia, Santiago)
rownames(datos_comunales) <- c("ingreso_medio", "hombres", "mujeres",
                               "pueblos_originarios", "ingreso_municipal",
                               "gasto_educacion", "n_colegios", "n_matriculados",
                               "gasto_salud", "n_est_salud", "tasa_natalidad",
                               "porcentaje_pobreza",
                               "porcentaje_personas_sin_servicios_basicos", 
                               "porcentaje_hacinamiento")

datos_comunales <- as_tibble(t(datos_comunales))
datos_comunales$nombre_comuna <- 
  c("PUDAHUEL", "CERRO NAVIA", "HUECHURABA", "CONCHALI", "LA PINTANA", "EL BOSQUE",
    "ESTACION CENTRAL", "PEDRO AGUIRRE CERDA", "RECOLETA", "INDEPENDENCIA",
    "LO ESPEJO", "LA CISTERNA", "LA FLORIDA", "PEÑALOLEN", "LAS CONDES", "LA REINA",
    "LO BARNECHEA", "VITACURA", "QUINTA NORMAL", "LO PRADO", "CERRILLOS", "MAIPU",
    "MACUL", "ÑUÑOA", "PUENTE ALTO", "QUILICURA", "RENCA", "SAN JOAQUIN", "SAN MIGUEL",
    "SAN RAMON", "LA GRANJA", "PROVIDENCIA", "SANTIAGO")

datos_comunales <- datos_comunales %>% 
  relocate(nombre_comuna) %>% 
  mutate(ingreso_medio = ingreso_medio/1000,
         ingreso_municipal = ingreso_municipal/1000000,
         gasto_educacion = gasto_educacion/1000000,
         gasto_salud = gasto_salud/1000000)

presidenciales_santiago <- presidenciales_santiago %>% 
  left_join(datos_comunales) %>% 
  mutate(tasa_gasto_salud = gasto_salud/ingreso_municipal,
         tasa_gasto_educacion = gasto_educacion/ingreso_municipal)

# Guardar RDS
saveRDS(presidenciales_santiago, file = "./datos/presidenciales_santiago.rds")



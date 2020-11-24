library(readr)
OnlineNewsPopularity <- read_csv("Datos/popularidad_noticias.csv")
View(OnlineNewsPopularity)

## Exploracion de los datos
dim(OnlineNewsPopularity)
str(OnlineNewsPopularity)
names(OnlineNewsPopularity)

OnlineNewsPopularity <- OnlineNewsPopularity[,-1]
summary(OnlineNewsPopularity)

# Gráfico entre timedelta y shares
library(tidyverse)
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping = aes(x = timedelta, y = shares)) +
  scale_y_log10()

# Primero vemos características numéricas de la variable respuesta
summary(OnlineNewsPopularity$shares)

ggplot(data = OnlineNewsPopularity) +
  geom_boxplot(mapping = aes(y = shares, x = "")) +
  scale_y_log10()


# Variable con mayor correlación a shares
datos_correlacion = OnlineNewsPopularity[1:59]
cor_matrix =  cor(log(OnlineNewsPopularity$shares), datos_correlacion)
max(cor_matrix)
colnames(cor_matrix)[which.max(cor_matrix)]
for (i in 1:length(cor_matrix)){
  print(colnames(cor_matrix)[i])
  print(cor_matrix[i])
}
valor_primera_correlacion = max(cor_matrix)
nombre_primera_correlacion = colnames(cor_matrix)[which.max(cor_matrix)]
valor_segunda_correlacion = 0.08377149
nombre_segunda_correlacion = "LDA_03"
valor_tercera_correlacion = 0.06430586
nombre_tercera_correlacion = "kw_max_max"


# Gráfico regresión


ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping = aes(x = kw_avg_avg, y = shares), color  ="turquoise4")

modelo = lm(shares~kw_avg_avg, data = OnlineNewsPopularity)

ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping =aes(x = kw_avg_avg, y = shares), color  ="turquoise4")+
  geom_abline(slope = modelo$coefficients[2], intercept = modelo$coefficients[1], color = "#D55E00")


# Gráficos con colores

# graficos separados por clase
ggplot(data = OnlineNewsPopularity) + 
  geom_point(mapping = aes(x = kw_avg_avg, y = shares, color = tipo_canal)) + 
  facet_wrap(~ tipo_canal, nrow = 3) + 
  scale_y_log10()

ggplot(data = OnlineNewsPopularity) + 
  geom_point(mapping = aes(x = kw_avg_avg, y = shares, color = dia_publicado)) + 
  facet_wrap(~ dia_publicado, nrow = 2) + 
  scale_y_log10() + 
  scale_x_log10()

# graficos con regresion
ggplot(data = OnlineNewsPopularity) + 
  geom_point(mapping = aes(x = kw_avg_avg, y = shares, color = tipo_canal)) + 
  geom_smooth(mapping = aes(x = kw_avg_avg, y = shares), 
              method = "lm", formula = y ~ x, se = FALSE) + 
  scale_y_log10()

ggplot(data = OnlineNewsPopularity) + 
  geom_point(mapping = aes(x = kw_avg_avg, y = shares, color = dia_publicado)) + 
  geom_smooth(mapping = aes(x = kw_avg_avg, y = shares), 
              method = "lm", formula = y ~ x, se = FALSE) + 
  scale_y_log10()

# graficos con boxplot
ggplot(data = OnlineNewsPopularity[OnlineNewsPopularity$shares<2500,]) + 
  geom_boxplot(outlier.shape = NA, mapping = aes(x = tipo_noticia, y = shares, fill = tipo_noticia)) + 
  xlab("") + 
  ylab("Shares") + 
  labs(fill = "Tipo noticia")

OnlineNewsPopularity$dia_de_la_semana = factor(OnlineNewsPopularity$dia_de_la_semana, 
                                            levels = c("Lunes", "Martes", "Miércoles", "Jueves", 
                                                        "Viernes", "Sábado", "Domingo"))
ggplot(data = OnlineNewsPopularity[OnlineNewsPopularity$shares<10000 & 
                                     OnlineNewsPopularity$shares>200,]) + 
  geom_boxplot(outlier.shape = NA , mapping = aes(x = dia_de_la_semana, y = shares, fill = dia_de_la_semana)) + 
  xlab("Día Publicado") + 
  ylab("Shares") + 
  labs(fill = "Día de la semana") +
  scale_y_log10()

# grafico de barras
ggplot(data = OnlineNewsPopularity) + 
  geom_histogram(mapping = aes(x = shares), fill = "skyblue", bins = 20) + 
  scale_y_log10() + 
  scale_x_log10()

# Con los siguientes 2 gráficos concluimos que hay más noticias del tema mundo.
# Pero a pesar de esto, las más compartidas son las de otro tema.
OnlineNewsPopularity$tipo_noticia = factor(OnlineNewsPopularity$tipo_noticia, levels = 
                                             c("Estilo de vida", "Redes sociales", "Otro", 
                                               "Negocios", "Entretenimiento", "Tecnología", "Mundo"))
ggplot(data = OnlineNewsPopularity) + 
  geom_bar(mapping = aes(x = tipo_noticia), fill="#56B4E9") +
  xlab("Tipo del Canal") +
  ylab("Cantidad")

OnlineNewsPopularity$tipo_noticia = factor(OnlineNewsPopularity$tipo_noticia, levels = 
                                             c("Estilo de vida", "Redes sociales", "Negocios", 
                                               "Mundo", "Entretenimiento", "Tecnología", "Otro"))
ggplot(data = OnlineNewsPopularity) + 
  geom_bar(mapping = aes(x = tipo_noticia, y = shares), fill = "#CC79A7", stat = "identity") + 
  xlab("Tipo del Canal") + 
  ylab("Comparticiones")






# Podemos ver el histograma de cantidad de shares
library(tidyverse)
ggplot(data = OnlineNewsPopularity) +
  geom_histogram(mapping = aes(x=shares), bins = 30)

ggplot(data = OnlineNewsPopularity) +
  geom_histogram(mapping = aes(x = shares), bins = 20) +
  scale_y_log10() +
  scale_x_log10()

table(OnlineNewsPopularity$shares > 10000)
sum(OnlineNewsPopularity$shares > 10000)/length(OnlineNewsPopularity$shares)

# Probamos con algunos gráficos de puntos
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping = aes(x = shares, y = n_tokens_content)) +
  scale_x_log10()

ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = shares, y = num_hrefs)) +
  scale_x_log10()

ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping = aes(x = shares, y = global_rate_positive_words)) +
  scale_x_log10()

# Scatterplot con la variable con mayor correlación
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = shares, y = kw_avg_avg)) +
  geom_smooth(mapping = aes(x = shares, y = kw_avg_avg), method = "lm",
              formula = y ~ x, se = FALSE)

# Tipo de post
table(OnlineNewsPopularity$data_channel_is_world)
table(OnlineNewsPopularity$data_channel_is_entertainment)
table(OnlineNewsPopularity$data_channel_is_lifestyle)
table(OnlineNewsPopularity$data_channel_is_tech)
table(OnlineNewsPopularity$data_channel_is_bus)
table(OnlineNewsPopularity$data_channel_is_socmed)

classes <- c("data_channel_is_world", "data_channel_is_entertainment",
             "data_channel_is_lifestyle", "data_channel_is_tech",
             "data_channel_is_bus", "data_channel_is_socmed")

summary(OnlineNewsPopularity[OnlineNewsPopularity$data_channel_is_world == 1,]$shares)
summary(OnlineNewsPopularity[OnlineNewsPopularity$data_channel_is_entertainment == 1,]$shares)
summary(OnlineNewsPopularity[OnlineNewsPopularity$data_channel_is_lifestyle == 1,]$shares)
summary(OnlineNewsPopularity[OnlineNewsPopularity$data_channel_is_tech == 1,]$shares)
summary(OnlineNewsPopularity[OnlineNewsPopularity$data_channel_is_bus == 1,]$shares)
summary(OnlineNewsPopularity[OnlineNewsPopularity$data_channel_is_socmed == 1,]$shares)
#----------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = timedelta, y = shares)) +
  geom_smooth(mapping = aes(x = timedelta, y = shares), method = "lm",
              formula = y ~ x, se = FALSE) + 
  scale_y_log10()#no se observa nada 
#----------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = n_tokens_title, y = shares)) +
  geom_smooth(mapping = aes(x = n_tokens_title, y = shares), method = "lm",
              formula = y ~ x, se = FALSE) + 
  scale_y_log10()
#----------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = n_tokens_content, y = shares)) +
  geom_smooth(mapping = aes(x = n_tokens_content, y = shares), method = "lm",
              formula = y ~ x, se = FALSE) + 
  scale_y_log10() + 
  scale_x_log10()#no se ve nada 
#----------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = n_unique_tokens, y = shares)) +
  geom_smooth(mapping = aes(x = n_unique_tokens, y = shares), method = "lm",
              formula = y ~ x, se = FALSE)#remplazar valores , pero no funciono 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = n_non_stop_words, y = shares)) +
  geom_smooth(mapping = aes(x = n_non_stop_words, y = shares), method = "lm",
              formula = y ~ x, se = FALSE)#no se puede interpretar nada 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = n_non_stop_unique_tokens, y = shares)) +
  geom_smooth(mapping = aes(x = n_non_stop_unique_tokens, y = shares), method = "lm",
              formula = y ~ x, se = FALSE)#no se puede interprertar nada 
#------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = num_hrefs, y = shares)) +
  geom_smooth(mapping = aes(x = num_hrefs, y = shares), method = "lm",
              formula = y ~ x, se = FALSE)#parecido a la recta de regresión
#----------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = num_self_hrefs, y = shares)) +
  geom_smooth(mapping = aes(x = num_self_hrefs, y = shares), method = "lm",
              formula = y ~ x, se = FALSE) + 
  scale_y_log10()#parecido a la recta de regresión
#---------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = num_imgs, y = shares)) +
  geom_smooth(mapping = aes(x = num_imgs, y = shares), method = "lm",
              formula = y ~ x, se = FALSE) + 
  scale_y_log10()#parecido a la recta de regresión
#--------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = num_videos, y = shares)) +
  geom_smooth(mapping = aes(x = num_videos, y = shares), method = "lm",
              formula = y ~ x, se = FALSE) + 
  scale_y_log10()
#-------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = average_token_length, y = shares)) +
  geom_smooth(mapping = aes(x = average_token_length, y = shares), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_histogram(aes(x = num_keywords), bins = 10, fill = "steelblue")

#--------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = data_channel_is_lifestyle, y = shares)) +
  geom_smooth(mapping = aes(x = data_channel_is_lifestyle, y = shares), method = "lm",
              formula = y ~ x, se = FALSE)#no se ve nada 
#-------------------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = data_channel_is_entertainment, y = shares)) +
  geom_smooth(mapping = aes(x = data_channel_is_entertainment, y = shares), method = "lm",
              formula = y ~ x, se = FALSE)
#----------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = data_channel_is_bus, y = shares)) +
  geom_smooth(mapping = aes(x = data_channel_is_bus, y = shares), method = "lm",
              formula = y ~ x, se = FALSE)#variable de 0 y 1 
#----------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = data_channel_is_socmed, y = shares)) +
  geom_smooth(mapping = aes(x = data_channel_is_socmed, y = shares), method = "lm",
              formula = y ~ x, se = FALSE)#variable de 0 y 1 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = data_channel_is_tech, y = shares)) +
  geom_smooth(mapping = aes(x = data_channel_is_tech, y = shares), method = "lm",
              formula = y ~ x, se = FALSE)#variable de 0 y 1 
#--------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = data_channel_is_world, y = shares)) +
  geom_smooth(mapping = aes(x = data_channel_is_world, y = shares), method = "lm",
              formula = y ~ x, se = FALSE)#varibale de 0 y 1 
#--------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = kw_min_min, y = shares)) +
  geom_smooth(mapping = aes(x = kw_min_min, y = shares), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = kw_max_min, y = shares)) +
  geom_smooth(mapping = aes(x = kw_max_min, y = shares), method = "lm",
              formula = y ~ x, se = FALSE) + #podria ser ** 
  scale_y_log10() + 
  scale_x_log10()
#--------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = kw_avg_min, y = shares)) +
  geom_smooth(mapping = aes(x = kw_avg_min, y = shares), method = "lm",
              formula = y ~ x, se = FALSE)
#-------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(x = kw_min_max, y = shares)) +
  geom_smooth(mapping = aes(x = kw_min_max, y = shares), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, y = kw_max_max)) +
  geom_smooth(mapping = aes(y = shares, y = kw_max_max), method = "lm",
              formula = y ~ x, se = FALSE)
#------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = kw_avg_max)) +
  geom_smooth(mapping = aes(y = shares, x = kw_avg_max), method = "lm",
              formula = y ~ x, se = FALSE) + 
  scale_y_log10() #podria ser **
#------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = kw_min_avg)) +
  geom_smooth(mapping = aes(y = shares, x = kw_min_avg), method = "lm",
              formula = y ~ x, se = FALSE)
#------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = kw_max_avg)) +
  geom_smooth(mapping = aes(y = shares, x = kw_max_avg), method = "lm",
              formula = y ~ x, se = FALSE)#si quitamos los out layers quisas de vea algo 
#------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = kw_avg_avg)) +
  geom_smooth(mapping = aes(y = shares, x = kw_avg_avg), method = "lm",
              formula = y ~ x, se = FALSE)
#------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = self_reference_min_shares)) +
  geom_smooth(mapping = aes(y = shares, x = self_reference_min_shares), method = "lm",
              formula = y ~ x, se = FALSE) #si quitamos los out layers quisas de vea algo 
#------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = self_reference_max_shares)) +
  geom_smooth(mapping = aes(y = shares, x = self_reference_max_shares), method = "lm",
              formula = y ~ x, se = FALSE)
#------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = self_reference_avg_sharess)) +
  geom_smooth(mapping = aes(y = shares, x = self_reference_avg_sharess), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = weekday_is_monday)) +
  geom_smooth(mapping = aes(y = shares, x = weekday_is_monday), method = "lm",
              formula = y ~ x, se = FALSE)#variable de 1 y 0 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = weekday_is_tuesday)) +
  geom_smooth(mapping = aes(y = shares, x = weekday_is_tuesday), method = "lm",
              formula = y ~ x, se = FALSE)#varible de 1 y 0 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = weekday_is_wednesday)) +
  geom_smooth(mapping = aes(y = shares, x = weekday_is_wednesday), method = "lm",
              formula = y ~ x, se = FALSE)#variable de 1 y 0 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = weekday_is_thursday)) +
  geom_smooth(mapping = aes(y = shares, x = weekday_is_thursday), method = "lm",
              formula = y ~ x, se = FALSE)#variable de 1 y 0 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = weekday_is_friday)) +
  geom_smooth(mapping = aes(y = shares, x = weekday_is_friday), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = weekday_is_saturday)) +
  geom_smooth(mapping = aes(y = shares, x = weekday_is_saturday), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = weekday_is_sunday)) +
  geom_smooth(mapping = aes(y = shares, x = weekday_is_sunday), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = is_weekend)) +
  geom_smooth(mapping = aes(y = shares, x = is_weekend), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = LDA_00)) +
  geom_smooth(mapping = aes(y = shares, x = LDA_00), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = LDA_01)) +
  geom_smooth(mapping = aes(y = shares, x = LDA_01), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = LDA_02)) +
  geom_smooth(mapping = aes(y = shares, x = LDA_02), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = LDA_03)) +
  geom_smooth(mapping = aes(y = shares, x = LDA_03), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = LDA_04)) +
  geom_smooth(mapping = aes(y = shares, x = LDA_04), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = global_subjectivity)) +
  geom_smooth(mapping = aes(y = shares, x = global_subjectivity ), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = global_sentiment_polarity)) +
  geom_smooth(mapping = aes(y = shares, x = global_sentiment_polarity ), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = global_rate_negative_words)) +
  geom_smooth(mapping = aes(y = shares, x = global_rate_negative_words ), method = "lm",
              formula = y ~ x, se = FALSE) + 
  scale_y_log10()
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = global_rate_positive_words)) +
  geom_smooth(mapping = aes(y = shares, x = global_rate_positive_words ), method = "lm",
              formula = y ~ x, se = FALSE) + 
  scale_y_log10()
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = rate_positive_words)) +
  geom_smooth(mapping = aes(y = shares, x = rate_positive_words ), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = rate_negative_words)) +
  geom_smooth(mapping = aes(y = shares, x = rate_negative_words ), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = avg_positive_polarity)) +
  geom_smooth(mapping = aes(y = shares, x = avg_positive_polarity ), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = min_positive_polarity)) +
  geom_smooth(mapping = aes(y = shares, x = min_positive_polarity), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = max_positive_polarity)) +
  geom_smooth(mapping = aes(y = shares, x = max_positive_polarity), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = avg_negative_polarity)) +
  geom_smooth(mapping = aes(y = shares, x = avg_negative_polarity), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = min_negative_polarity)) +
  geom_smooth(mapping = aes(y = shares, x = min_negative_polarity), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = max_negative_polarity)) +
  geom_smooth(mapping = aes(y = shares, x = max_negative_polarity), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = title_subjectivity)) +
  geom_smooth(mapping = aes(y = shares, x = title_subjectivity), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = title_sentiment_polarity)) +
  geom_smooth(mapping = aes(y = shares, x = title_sentiment_polarity), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = abs_title_subjectivity)) +
  geom_smooth(mapping = aes(y = shares, x = abs_title_subjectivity), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = abs_title_sentiment_polarity)) +
  geom_smooth(mapping = aes(y = shares, x = abs_title_sentiment_polarity), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = shares)) +
  geom_smooth(mapping = aes(y = shares, x = shares), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
OnlineNewsPopularity$kw_avg_min[OnlineNewsPopularity$kw_avg_min>20000]= mean(OnlineNewsPopularity$kw_avg_min)
sum(OnlineNewsPopularity$kw_avg_min>20000)



}


library(readr)
OnlineNewsPopularity <- read_csv("Datos/OnlineNewsPopularity.csv")
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
cor_matrix <- cor(OnlineNewsPopularity$shares, OnlineNewsPopularity[,-60])
cor_matrix
max(cor_matrix)
min(cor_matrix)
max_cor_name <- names(OnlineNewsPopularity)[which.max(cor_matrix)]

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
  geom_point(mapping= aes(y = shares, x = timedelta)) +
  geom_smooth(mapping = aes(y = shares, x = timedelta), method = "lm",
              formula = y ~ x, se = FALSE)#no se observa nada 
#----------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = n_tokens_title)) +
  geom_smooth(mapping = aes(y = shares, x= n_tokens_title), method = "lm",
              formula = y ~ x, se = FALSE)#no se rrelacion correctammente quizas mejor un box  
#----------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = n_tokens_content)) +
  geom_smooth(mapping = aes(y = shares, x = n_tokens_content), method = "lm",
              formula = y ~ x, se = FALSE)#quizas quitando out layer se pueda ver mejor  pero si se ve relacion
#----------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = n_unique_tokens)) +
  geom_smooth(mapping = aes(y = shares, x = n_unique_tokens), method = "lm",
              formula = y ~ x, se = FALSE)#quitando un outlayer quizas se aprecie mejor 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = n_non_stop_words)) +
  geom_smooth(mapping = aes(y = shares, x =n_non_stop_words), method = "lm",
              formula = y ~ x, se = FALSE)#quitando un outlayer quizas se interprete mejor  
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = n_non_stop_unique_tokens)) +
  geom_smooth(mapping = aes(y = shares, x =n_non_stop_unique_tokens), method = "lm",
              formula = y ~ x, se = FALSE)#no se interpreta nada quizas quitando el out layer  
#------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = num_hrefs)) +
  geom_smooth(mapping = aes(y = shares, x =num_hrefs), method = "lm",
              formula = y ~ x, se = FALSE)#se puede ver algo pero no es completamnete lineal 
#----------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = num_self_hrefs)) +
  geom_smooth(mapping = aes(y = shares, x =num_self_hrefs), method = "lm",
              formula = y ~ x, se = FALSE)# se puede ver que la inicio estas acumulado pero se aprecia algo lineal 
#---------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = num_imgs)) +
  geom_smooth(mapping = aes(y = shares, x =num_imgs), method = "lm",
              formula = y ~ x, se = FALSE)# se puede apreciar algo lineal 
#--------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y= shares, x = num_videos)) +
  geom_smooth(mapping = aes(y = shares, x =num_videos), method = "lm",
              formula = y ~ x, se = FALSE)# es como un grafico de puntos 
#-------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = average_token_length)) +
  geom_smooth(mapping = aes(y = shares, x =average_token_length), method = "lm",
              formula = y ~ x, se = FALSE)#tiene pinta de box plot nada linea l
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = num_keywords)) +
  geom_smooth(mapping = aes(y = shares, x =num_keywords), method = "lm",
              formula = y ~ x, se = FALSE)# mejor para un grafico de barras o histograma 
#--------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = data_channel_is_lifestyle)) +
  geom_smooth(mapping = aes(y = shares, x =data_channel_is_lifestyle), method = "lm",
              formula = y ~ x, se = FALSE)# no se ve nada varia entre 0 y 1 
#-------------------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = data_channel_is_entertainment)) +
  geom_smooth(mapping = aes(y = shares, x =data_channel_is_entertainment), method = "lm",
              formula = y ~ x, se = FALSE)# no se ve nada varia entre 0 y 1 
#----------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = data_channel_is_bus)) +
  geom_smooth(mapping = aes(y = shares, x =data_channel_is_bus), method = "lm",
              formula = y ~ x, se = FALSE)#variable de 0 y 1 
#----------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = data_channel_is_socmed)) +
  geom_smooth(mapping = aes(y = shares, x = data_channel_is_socmed), method = "lm",
              formula = y ~ x, se = FALSE)#variable de 0 y 1 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = data_channel_is_tech)) +
  geom_smooth(mapping = aes(y = shares, x = data_channel_is_tech), method = "lm",
              formula = y ~ x, se = FALSE)#variable de 0 y 1 
#--------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = data_channel_is_world)) +
  geom_smooth(mapping = aes(y = shares, x = data_channel_is_world), method = "lm",
              formula = y ~ x, se = FALSE)#varibale de 0 y 1 
#--------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = kw_min_min)) +
  geom_smooth(mapping = aes(y = shares, x = kw_min_min), method = "lm",
              formula = y ~ x, se = FALSE)# no se aprecia nada 
#---------------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = kw_max_min)) +
  geom_smooth(mapping = aes(y = shares, x = kw_max_min), method = "lm",
              formula = y ~ x, se = FALSE)#podria ser **
#--------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = kw_avg_min)) +
  geom_smooth(mapping = aes(y = shares, x =kw_avg_min), method = "lm",
              formula = y ~ x, se = FALSE)# se puede ver algo lineal 
#-------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = kw_min_max)) +
  geom_smooth(mapping = aes(y = shares, x =kw_min_max), method = "lm",
              formula = y ~ x, se = FALSE)#no se puede distinguir nada 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = kw_max_max)) +
  geom_smooth(mapping = aes(y = shares, x =kw_max_max), method = "lm",
              formula = y ~ x, se = FALSE)#no se puede apreciar nada 
#------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = kw_avg_max)) +
  geom_smooth(mapping = aes(y = shares, x =kw_avg_max), method = "lm",
              formula = y ~ x, se = FALSE)#quizas mejor para boxplot 
##------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = kw_min_avg)) +
  geom_smooth(mapping = aes(y = shares, x =kw_min_avg), method = "lm",
              formula = y ~ x, se = FALSE)#no se puede distintigir mucho 
#------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = kw_max_avg)) +
  geom_smooth(mapping = aes(y = shares, x =kw_max_avg), method = "lm",
              formula = y ~ x, se = FALSE)#si quitamos los out layers quisas de vea algo 
#------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = kw_avg_avg)) +
  geom_smooth(mapping = aes(y = shares, x =kw_avg_avg), method = "lm",
              formula = y ~ x, se = FALSE)#puede ser pero no se :C 
#------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = self_reference_min_shares)) +
  geom_smooth(mapping = aes(y = shares, x =self_reference_min_shares), method = "lm",
              formula = y ~ x, se = FALSE) #si quitamos los out layers quisas de vea algo 
#------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = self_reference_max_shares)) +
  geom_smooth(mapping = aes(y = shares, x =self_reference_max_shares), method = "lm",
              formula = y ~ x, se = FALSE)# se concentran mucho al inicio
#------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = self_reference_avg_sharess)) +
  geom_smooth(mapping = aes(y = shares, x =self_reference_avg_sharess), method = "lm",
              formula = y ~ x, se = FALSE)#muy concentrado
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = weekday_is_monday)) +
  geom_smooth(mapping = aes(y = shares, x =weekday_is_monday), method = "lm",
              formula = y ~ x, se = FALSE)#variable de 1 y 0 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = weekday_is_tuesday)) +
  geom_smooth(mapping = aes(y = shares, x =weekday_is_tuesday), method = "lm",
              formula = y ~ x, se = FALSE)#varible de 1 y 0 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = weekday_is_wednesday)) +
  geom_smooth(mapping = aes(y = shares, x =weekday_is_wednesday), method = "lm",
              formula = y ~ x, se = FALSE)#variable de 1 y 0 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y= shares, x = weekday_is_thursday)) +
  geom_smooth(mapping = aes(y = shares, x =weekday_is_thursday), method = "lm",
              formula = y ~ x, se = FALSE)#variable de 1 y 0 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = weekday_is_friday)) +
  geom_smooth(mapping = aes(y = shares, x =weekday_is_friday), method = "lm",
              formula = y ~ x, se = FALSE)# no se ve nada varia entre 0 y 1 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = weekday_is_saturday)) +
  geom_smooth(mapping = aes(y = shares, x =weekday_is_saturday), method = "lm",
              formula = y ~ x, se = FALSE)# no se ve nada varia entre 0 y 1 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x= weekday_is_sunday)) +
  geom_smooth(mapping = aes(y = shares, x =weekday_is_sunday), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------# no se ve nada varia entre 0 y 1 ------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = is_weekend)) +
  geom_smooth(mapping = aes(y = shares, x =is_weekend), method = "lm",
              formula = y ~ x, se = FALSE)# no se ve nada varia entre 0 y 1 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = LDA_00)) +
  geom_smooth(mapping = aes(y = shares, x =LDA_00), method = "lm",
              formula = y ~ x, se = FALSE)#no se aprecia nada 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = LDA_01)) +
  geom_smooth(mapping = aes(y = shares, x =LDA_01), method = "lm",
              formula = y ~ x, se = FALSE)#no se puede apreciar nada 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = LDA_02)) +
  geom_smooth(mapping = aes(y = shares, x =LDA_02), method = "lm",
              formula = y ~ x, se = FALSE)#no se aprecia nada 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = LDA_03)) +
  geom_smooth(mapping = aes(y = shares, x =LDA_03), method = "lm",
              formula = y ~ x, se = FALSE)#no se aprecia nada
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = LDA_04)) +
  geom_smooth(mapping = aes(y = shares, x =LDA_04), method = "lm",
              formula = y ~ x, se = FALSE)#no se aprecia nada
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = global_subjectivity)) +
  geom_smooth(mapping = aes(y = shares, x =global_subjectivity ), method = "lm",
              formula = y ~ x, se = FALSE)#quizas un box plot 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = global_sentiment_polarity)) +
  geom_smooth(mapping = aes(y = shares, x =global_sentiment_polarity ), method = "lm",
              formula = y ~ x, se = FALSE)#box plot 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = global_rate_negative_words)) +
  geom_smooth(mapping = aes(y = shares, x =global_rate_negative_words ), method = "lm",
              formula = y ~ x, se = FALSE)#no se aprecia nada 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = rate_positive_words)) +
  geom_smooth(mapping = aes(y = shares, x =rate_positive_words ), method = "lm",
              formula = y ~ x, se = FALSE)# no se ve nada 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = rate_negative_words)) +
  geom_smooth(mapping = aes(y = shares, x =rate_negative_words ), method = "lm",
              formula = y ~ x, se = FALSE)# no se ve nada 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = avg_positive_polarity)) +
  geom_smooth(mapping = aes(y = shares, x =avg_positive_polarity ), method = "lm",
              formula = y ~ x, se = FALSE)#box splot 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = min_positive_polarity)) +
  geom_smooth(mapping = aes(y = shares, x =min_positive_polarity), method = "lm",
              formula = y ~ x, se = FALSE)#histograma puede ser 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = max_positive_polarity)) +
  geom_smooth(mapping = aes(y = shares, x =max_positive_polarity), method = "lm",
              formula = y ~ x, se = FALSE)#histograma
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = avg_negative_polarity)) +
  geom_smooth(mapping = aes(y = shares, x =avg_negative_polarity), method = "lm",
              formula = y ~ x, se = FALSE)#histograma no se ve nada lineal

#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = min_negative_polarity)) +
  geom_smooth(mapping = aes(y = shares, x =min_negative_polarity), method = "lm",
              formula = y ~ x, se = FALSE)#histogram
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = max_negative_polarity)) +
  geom_smooth(mapping = aes(y = shares, x =max_negative_polarity), method = "lm",
              formula = y ~ x, se = FALSE)#histograma 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = title_subjectivity)) +
  geom_smooth(mapping = aes(y = shares, x =title_subjectivity), method = "lm",
              formula = y ~ x, se = FALSE)#no se ve nada lineal quizas histograma 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = title_sentiment_polarity)) +
  geom_smooth(mapping = aes(y = shares, x =title_sentiment_polarity), method = "lm",
              formula = y ~ x, se = FALSE)#para histograma n ose ve nada lineal
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = abs_title_subjectivity)) +
  geom_smooth(mapping = aes(y = shares, x =abs_title_subjectivity), method = "lm",
              formula = y ~ x, se = FALSE)# no se ve nada lineal 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = abs_title_sentiment_polarity)) +
  geom_smooth(mapping = aes(y = shares, x =abs_title_sentiment_polarity), method = "lm",
              formula = y ~ x, se = FALSE)#no se ve nada lineal quizas boxplot 
#---------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping= aes(y = shares, x = shares)) +
  geom_smooth(mapping = aes(y = shares, x =shares), method = "lm",
              formula = y ~ x, se = FALSE)
#---------------------------------------------------------------------------------------------------------------------------------------
OnlineNewsPopularity$ n_unique_tokens[OnlineNewsPopularity$ n_unique_tokens>20000]= mean(OnlineNewsPopularity$ n_unique_tokens)
sum(OnlineNewsPopularity$ n_unique_tokens>20000)


  


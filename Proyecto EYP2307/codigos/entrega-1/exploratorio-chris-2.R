# HOLA MUNDO
# HOLA MUNDO 2.0

library(readr)
OnlineNewsPopularity
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
install.packages("dplyr")
library(GGally)
library(ggplot2)
library(dplyr)
ggpairs(OnlineNewsPopularity)

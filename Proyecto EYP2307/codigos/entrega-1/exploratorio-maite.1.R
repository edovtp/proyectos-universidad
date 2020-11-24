library(readr)
library(GGally)
library(ggcorrplot)
OnlineNewsPopularity <- read_csv("Datos/OnlineNewsPopularity.csv")
View(OnlineNewsPopularity)
OnlineNewsPopularity$url = NULL

modelo = lm(shares~kw_avg_avg, data = OnlineNewsPopularity)

# Grafico de valores reales vs simulados ----------------------------------

grafico1 = data.frame(OnlineNewsPopularity$shares, modelo$fitted.values)
attach(grafico1)
colnames(grafico1) = c("real", "fitted")

ggplot(data = grafico1)+
  geom_point(mapping = aes(x = real, y = fitted)) +
  geom_abline(shape = 1, intercept = 0)



# kw_avg_avg vs shares con linea de regresión -----------------------------

ggplot(data = OnlineNewsPopularity) +
  geom_point(mapping =aes(x = kw_avg_avg, y = shares), color  ="turquoise4")+
  geom_abline(slope = modelo$coefficients[2], intercept = modelo$coefficients[1], color = "deepskyblue4")



# Grafico de correlaciones ------------------------------------------------

ggcorrplot(cor(OnlineNewsPopularity[1:59]))


# sumario entre shares y kw_avg_avg ---------------------------------------

ggpairs(data = OnlineNewsPopularity, columns = c("kw_avg_avg", "shares"))

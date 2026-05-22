library(fpp3)
library(forecast)
library(lubridate)
library(tsibble)
library(ggplot2)
library(TSA)
library(tseries)

#PRIMERA BASE DE DATOS
inpc.data <- read.csv("INPC.csv")
inpc.ts <-

View(inpc.data)
#Serie de tiempo

inpc.ts <- ts(inpc.data$INPC, start = c(2022, 1), end = c(2026,3), freq = 12)
plot(inpc.ts, xlab = "Tiempo en Años (Registro Mensual)", ylab = "Índice de Nacional de Precios al Consumidor", ylim = c(110, 150), bty = "l")

inpc.lm <- tslm(inpc.ts ~ trend + I(trend^2))
plot(inpc.ts, xlab = "Tiempo en Años (Registro Mensual)", ylab = "Índice de Nacional de Precios al Consumidor", ylim = c(110, 150), bty = "l")
lines(inpc.lm$fitted, lwd = 2)

#no es WSS porque no presenta media constante pero quien sabe si si varianza constante

# Diferenciación de primer orden
inpc.diff <- diff(inpc.ts)

# Graficar la serie diferenciada
plot(inpc.diff, main = "Serie diferenciada del INPC", xlab = "Tiempo en Años (Registro mensual)", ylab = "Índice Nacional de Precios al Consumidor", bty = "l")
abline(h=1, col="red")
abline(h=0, col="red")
head(diff(inpc.ts))
#la mayoria de los datos se oscilan de manera constante dentro de una amplitud

#se pone la serie original NO la diferencia
lambda1 <- BoxCox.lambda(inpc.ts, method = c("loglik"), lower =-1, upper = 5)
lambda1

#para estabilizar la varianza
inpc.boxcox<-BoxCox(inpc.ts, lambda = lambda1)
par(mfrow=c(1,2))
plot(inpc.boxcox)
plot(inpc.ts)

par(mfrow=c(1,2))
plot(diff(inpc.boxcox))
plot(diff(inpc.ts))

#la buena
plot(diff(inpc.boxcox))

#para autocorrelacion
par(mfrow=c(1,2))
acf(diff(inpc.boxcox), main="Autocorrelación")
pacf(diff(inpc.boxcox), main="Autocorrelación Parcial")
eacf(diff(inpc.boxcox)) #El EACF sugiere que el modelo de la serie diferenciada es un ruido blanco o un MA(1)

#CASO 2 MEDIANTE LOG 
#loginpc.ts <- log(inpc.ts)
#plot(loginpc.ts, xlab = "Tiempo en Años (Registro Mensual)", ylab = "Índice de Nacional de Precios al Consumidor",  bty = "l")
#Aplicamos diferencia y veamos si tiene la varianza estable
#difflog.inpcts <- diff(loginpc.ts)
#plot(difflog.inpcts, xlab = "Tiempo en Años (Registro Mensual)", ylab = "Índice de Nacional de Precios al Consumidor",  bty = "l")
#lambda1 <- BoxCox.lambda(loginpc.ts, method = c("loglik"), lower =-1, upper = 5)
#lambda1

#para estabilizar la varianza
inpc.boxcox<-BoxCox(inpc.ts, lambda = lambda1)


#=========== Para ARIMA(0,1,0) y ARIMA(0,1,1)
modeloarima0<- Arima(inpc.ts, order=c(0,1,0), include.constant = TRUE, lambda = 3.85)
modeloarima1 <- Arima(inpc.ts, order=c(0,1,1), include.constant = TRUE, lambda = 3.85)

summary(modeloarima0)
summary(modeloarima1)
#Validación de modelo

residuos010<-modeloarima0$residuals
residuos011 <- modeloarima1$residuals
par(mfrow=c(2,2))
acf(as.vector(residuos010), main = "modelo arima(0,1,0) autocorrelacion")
pacf(as.vector(residuos010), main = "modelo arima(0,1,0) autocorrelacion parcial")
acf(as.vector(residuos011), main = "modelo arima(0,1,1) autocorrelacion")
pacf(as.vector(residuos011), main = "modelo arima(0,1,1) autocorrelacion parcial")
#vemos que no contradice que sea un WSS ya que los lag de los residuos estan dentro de las bandas del "ACF y PACF"

prueba1<- Box.test(residuos010, lag = 20,  type = "Ljung-Box")
prueba1 #no hay evidencia en contra de que los residuales sean ruido blanco

prueba2<- Box.test(residuos011, lag = 20,  type = "Ljung-Box")
prueba2 #no hay evidencia en contra de que los residuales sean ruido blanco

qqnorm((residuos010-mean(residuos010))/sqrt(var(residuos010)))
ks.test((residuos010-mean(residuos010))/sqrt(var(residuos010)), "pnorm", 0, 1)

#Probemos con los residuos con arima (0,1,1)
qqnorm((residuos011-mean(residuos011))/sqrt(var(residuos011)))
ks.test((residuos011-mean(residuos011))/sqrt(var(residuos011)), "pnorm", 0, 1)

#no hay evidencia en contra de que los datos sigan una distribuación normal

#Pronósticos para arima 010
pronostico <- forecast(modeloarima0, h = 4)
ajustados <- fitted(modeloarima0)
plot(pronostico)
#Pronostico para arima 011
pronostico <- forecast(modeloarima0)


#Pronósticos para arima 011
pronostico1 <- forecast(modeloarima1, h = 4)
ajustados1 <- fitted(modeloarima1)
plot(pronostico1)
pronostico1 <- forecast(modeloarima1)



#Pronósticos para arima 011
pronostico1 <- forecast(modeloarima1, h = 4)
ajustados1 <- fitted(modeloarima1)
plot(pronostico1)
pronostico1 <- forecast(modeloarima1)



#Para graficar observados y pronosticos

autoplot(pronostico1) +
  autolayer(inpc.ts, series = "Observados") +
  ggtitle("Pronóstico con ARIMA") +
  xlab("Tiempo") +
  ylab("INPC") +
  guides(colour = guide_legend(title = "Serie"))
lines(ajustados, col = "green", lwd = 2)




ts_total <- ts(c(inpc.ts, pronostico1$mean),
               start = start(inpc.ts),
               frequency = frequency(inpc.ts))
#modelo arima(0,1,1)
plot(inpc.ts,
     xlim = c(start(inpc.ts)[1], end(ts_total)[1] + 1),
     ylim = range(ts_total),
     col = "black", lwd = 2,
     ylab = "Serie", xlab = "Tiempo",
     main = "Observados vs Pronóstico arima (011)")
lines(pronostico1$mean, col = "blue", lwd = 2)
lines(ajustados, col = "red", lwd = 2)


lines(pronostico1$lower[,2], col = "red", lty = 2)
lines(pronostico1$upper[,2], col = "red", lty = 2)
legend("topleft",
       legend = c("Observados", "Pronóstico", "Estimados"),
       col = c("black", "blue", "red"),
       lty = c(1,1,1),
       lwd = 2)



summary(modeloarima1)
names(pronostico1)
summary(pronostico1)
pronostico1


# En este caso mean es la media del modelo.
auto.arima(inpc.ts) #paraverificar que nuestro analisis y el autoarima lo avala



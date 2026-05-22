# Modelado y Pronóstico del Índice Nacional de Precios al Consumidor (INPC) mediante Modelos ARIMA

Este repositorio contiene un análisis estadístico y econométrico profundo para modelar y proyectar el **Índice Nacional de Precios al Consumidor (INPC)** de México. El estudio abarca datos de registro mensual desde **enero de 2022 hasta marzo de 2026**, utilizando la metodología Box-Jenkins para la estabilización y selección de modelos de series de tiempo.

## 👥 Autores
* **Mauricio Becerril** - Universidad Autónoma de Yucatán (UADY)

---

## 📈 Resumen del Proceso de Modelación

### 1. Identificación y Estacionariedad
La serie original $\{Y_t\}$ presentó una marcada tendencia creciente debido a factores inflacionarios, confirmando la falta de una media constante (No Estacionaria / No WSS). 

* **Estabilización de Varianza:** Se aplicó una transformación Box-Cox con un parámetro óptimo de $\lambda = 3.85$.
* **Estabilización de Media:** Se aplicó una diferenciación de primer orden ($d = 1$) sobre la serie transformada para eliminar la tendencia diagonal.

La serie resultante estacionaria $Z_t$ se define formalmente como:

$$Z_{t}=Y_{t}^{(3.85)}-Y_{t-1}^{(3.85)}$$

### 2. Identificación de Modelos Candidatos
A través del análisis de la Función de Autocorrelación Extendida (EACF), las funciones ACF y PACF tradicionales indicaron un comportamiento cercano al ruido blanco para la serie diferenciada. El patrón triangular de la EACF sugirió dos modelos contendientes con componente de *drift*:
* $ARIMA(0,1,0) \text{ con drift}$
* $ARIMA(0,1,1) \text{ con drift}$

---

## 📊 Selección del Modelo Óptimo

Tras la estimación de parámetros, se evaluaron los criterios de información y las medidas de error de ambos modelos sobre el conjunto de entrenamiento:

| Métrica / Criterio | ARIMA(0,1,0) con drift | ARIMA(0,1,1) con drift |
| :--- | :---: | :---: |
| **RMSE** | 0.3483741 | **0.3260726** |
| **MAE** | 0.2551628 | **0.2376047** |
| **AIC** | 1437.67 | **1434.09** |
| **BIC** | 1441.49 | **1439.83** |

**Conclusión:** El modelo **$ARIMA(0,1,1)$** fue seleccionado como el modelo óptimo debido a que minimiza de manera generalizada los criterios de información y disminuye el error cuadrático medio de predicción.

La ecuación final estimada para el comportamiento del INPC es:

$$Y_{t}^{(3.85)} - Y_{t-1}^{(3.85)} = 621,215.04 + \epsilon_{t} + 0.4261\epsilon_{t-1}$$

---

## 🛠️ Validación de Supuestos (Diagnóstico de Residuos)

El modelo $ARIMA(0,1,1)$ fue sometido a estrictas pruebas de diagnóstico estadístico para validar los supuestos fundamentales:

* **Ausencia de Autocorrelación (Ruido Blanco):** Evaluada mediante la prueba de **Ljung-Box** con 20 rezagos. Se obtuvo un $p\text{-valor} = 0.6506 > 0.05$, fallando en rechazar la hipótesis nula de independencia en los residuos.
* **Normalidad:** Evaluada de manera gráfica mediante un gráfico *Q-Q Plot* y formalizada analíticamente con la prueba de **Kolmogorov-Smirnov**, obteniendo un $p\text{-valor} = 0.5282 > 0.05$, lo cual confirma la distribución normal de los residuales.

---

## 🔮 Predicciones para 2026

Utilizando la esperanza condicional e incorporando la inercia inflacionaria mediante el componente de medias móviles ($q=1$), se proyectaron los valores del INPC para las siguientes tres publicaciones oficiales con intervalos de confianza al 95%:

| Periodo | Pronóstico Puntual | Límite Inferior (95%) | Límite Superior (95%) |
| :--- | :---: | :---: | :---: |
| **Mayo 2026** | **146.2696** | 145.7821 | 147.5768 |
| **Junio 2026** | **147.1015** | 146.3438 | 148.2393 |
| **Julio 2026** | **147.5125** | 146.1445 | 148.8462 |

*Nota: Conforme el horizonte de predicción se extiende, las bandas de confianza se ensanchan reflejando el incremento teórico en la varianza del error y la incertidumbre del mercado. La tendencia general sugiere un incremento moderado de la inflación del 1.4% de marzo a julio de 2026.*

---

## 📂 Contenido del Repositorio
* `/data`: Base de datos histórica del INPC en formato `.csv` o `.xlsx`.
* `/src`: Script de R (`.R` o `.Rmd`) con el código fuente para replicar las transformaciones (Box-Cox, diferenciación), los gráficos ACF/PACF/EACF, pruebas de hipótesis y la generación de gráficos finales con `ggplot2`.
* `/docs`: Reporte académico original en formato PDF.

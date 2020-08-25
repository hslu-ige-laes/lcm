# 
# library(TTR)
# library(xts)
# library(forecast)
# library(ggplot2)
# 
# # df <- AirPassengers
# 
# df <- read_csv("data/csv/Orig/deltaP.csv")
# df <- na.omit(df)
# 
# df$timestamp <- as.POSIXct(df$timestamp, tz = "Europe/Zurich")
# 
# df <- ts(df$deltap)
# 
# df.arima <- forecast::auto.arima( )
# df.forecast <- forecast(df.arima, level = c(99), h = 700)
# fortify.forecast <- function(forecast.data) {
#   require(dplyr)
#   forecasted <- as.data.frame(forecast.data)
#   forecasted$Time <- as.Date(time(forecast.data$mean))
#   
#   fitted <- data.frame(Time = as.Date(time(forecast.data$fitted)),
#                        Original = forecast.data$x,
#                        Fitted = forecast.data$fitted)
#   
#   rownames(fitted) <- NULL
#   rownames(forecasted) <- NULL
#   
#   dplyr::rbind_list(fitted, forecasted)
# }
# 
# p <- ggplot(data = df.forecast) +
#   geom_line(mapping = aes_string(x = 'Time', y = 'Original'), colour = "#365c8d", alpha = 0.5) +
#   geom_line(mapping = aes_string(x = 'Time', y = '`Point Forecast`'), colour="#440154", alpha = 1) +
#   geom_ribbon(mapping = aes_string(x = 'Time', ymin = '`Lo 99`', ymax = '`Hi 99`'), fill = "#fde725", alpha = 0.3) +
#   geom_hline(aes(yintercept = 70),
#              color="darkorange",
#              linetype="dashed") +
#   ggtitle("pressure difference air handling unit") +
#   theme_minimal() +
#   theme(
#     strip.text = element_text(size = 13, colour = "darkgrey"),
#     legend.position="right",
#     axis.line.x = element_line(size = 2, colour = "darkgrey", linetype = 1),
#     # axis.ticks.x=element_blank(),
#     axis.title.x=element_blank(),
#     panel.spacing.y = unit(2, "lines"),
#     panel.grid.major.x = element_blank(),
#     panel.grid.minor.x = element_blank(),
#     plot.title = element_text(hjust = 0.5),
#     plot.subtitle = element_text(hjust = 0.5)
#   )
# 
# yaxis <- list(
#   title = expression(paste(delta, "p", " in (Pa)")),
#   automargin = TRUE,
#   titlefont = list(size = 14, color = "darkgrey")
# )
# 
# ggplotly(p + ylab(" ") + xlab(" ")) %>%
#   plotly::config(modeBarButtons = list(list("toImage")),
#                  displaylogo = FALSE,
#                  toImageButtonOptions = list(
#                    format = "svg"
#                  )
#   ) %>% 
#   layout(margin = list(t = 120), yaxis = yaxis)
# 
# 

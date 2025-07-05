#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(shinydashboard)
library(plotly)
library(ggplot2)
library(readr)
library(dplyr)
library(lubridate)


server <- function(input, output) {
  data <- reactive({
    df <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-05-13/vesuvius.csv")
    
    #cleaning up the time data
    df$time <- as.POSIXct(df$time, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
    df$month <- month(df$time)
    df$hour <- hour(df$time)
    df$day_of_year <- yday(df$time)
    
    return(df)
  })
  
  output$`total-events` <- renderValueBox({
    valueBox(
      value = nrow(data()),
      subtitle = "Total Events",
      color = "red"
    )
  })
  
  output$`avg-magnitude` <- renderValueBox({
    avg_mag <- round(mean(data()$duration_magnitude_md, na.rm = TRUE), 2)
    valueBox(
      value = avg_mag,
      subtitle = "Average Magnitude",
      color = "orange"
    )
  })
  
  output$`max-magnitude` <- renderValueBox({
    max_mag <- round(max(data()$duration_magnitude_md, na.rm = TRUE), 2)
    valueBox(
      value = max_mag,
      subtitle = "Maximum Magnitude",
      color = "red"
    )
  })
  
  output$`depth-range` <- renderValueBox({
    min_depth <- round(min(data()$depth_km, na.rm = TRUE), 1)
    max_depth <- round(max(data()$depth_km, na.rm = TRUE), 1)
    valueBox(
      value = paste(min_depth, "-", max_depth, "km"),
      subtitle = "Depth Range",
      color = "blue"
    )
  })
  
  output$`time-span` <- renderValueBox({
    years <- paste(min(data()$year), "-", max(data()$year))
    valueBox(
      value = years,
      subtitle = "Time span",
      color = "green"
    )
  })
  
  output$`event-types` <- renderValueBox({
    types <- length(unique(data()$type))
    valueBox(
      value = types,
      subtitle = "Event Types",
      color = "purple"
    )
  })
  
  output$timeline <- renderPlotly({
    df <- data()
    
    p <- ggplot(df, aes(x = time, y = duration_magnitude_md, color = type)) +
      geom_point(alpha = 0.7, size = 1.5) +
      labs(title = "Seismic Activity Over Time",
           x = "Date",
           y = "Duration Magnitude (Md)",
           color = "Event type") +
      theme_minimal() +
      theme(legend.position = "bottom") +
      scale_color_viridis_d()
    
    ggplotly(p, tooltip = c("x", "y", "colour"))
  })
  
  output$`loc-map` <- renderPlotly({
    df <- data()
    
    p <- ggplot(df, aes(x = longitude, y = latitude,
                        color = duration_magnitude_md, size = depth_km)) +
      geom_point(alpha = 0.7) +
      labs(title = "Seismic Event Locations",
           x = "Longitude",
           y = "Latitude",
           color = "Magnitude (Md)",
           size = "Depth (km)") +
      theme_minimal() +
      scale_color_gradient2(low = "blue", mid = "yellow", high = "red", midpoint = mean(df$duration_magnitude_md, na.rm = TRUE))
    
    ggplotly(p, tooltip = c("x", "y", "colour", "size"))
  })

  output$annual_trends <- renderPlotly({
    df <- data() %>%
      group_by(year) %>%
      summarise(count = n(), .groups = 'drop')
    
    p <- ggplot(df, aes(x = year, y = count)) +
      geom_line(color = "#d73027", size = 1.2) +
      geom_point(color = "#d73027", size = 2) +
      labs(title = "Annual Seismic Activity Trends",
           x = "Year",
           y = "Number of Events") +
      theme_minimal() +
      theme(panel.grid.minor = element_blank())
    
    ggplotly(p, tooltip = c("x", "y"))
  })
  
  output$`monthly-graph` <- renderPlotly({
    df <- data() %>%
      group_by(month) %>%
      summarise(count = n(), .groups = 'drop') %>%
      mutate(month_name = month.abb[month])
    
    p <- ggplot(df, aes(x = reorder(month_name, month), y = count)) +
      geom_col(fill = "#fd8d3c", alpha = 0.8) +
      labs(title = "Monthly Distribution",
           x = "Month",
           y = "Number of Events") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p, tooltip = c("x", "y"))
  })
  
  output$`hourly-graph` <- renderPlotly({
    df <- data() %>%
      group_by(hour) %>%
      summarise(count = n(), .groups = 'drop')
    
    p <- ggplot(df, aes(x = hour, y = count)) +
      geom_col(fill = "#fd8d3c", alpha = 0.8) +
      labs(title = "Hourly Distribution",
           x = "Hour of Day",
           y = "Number of Events") +
      theme_minimal() +
      scale_x_continuous(breaks = seq(0, 23, 2))
    
    ggplotly(p, tooltip = c("x", "y"))
  }
    )

    output$`magnitude-trend` <- renderPlotly({
    df <- data() %>%
      group_by(year) %>%
      summarise(
            avg_magnitude = mean(duration_magnitude_md, na.rm = TRUE),
            max_magnitude = max(duration_magnitude_md, na.rm = TRUE),
            min_magnitude = min(duration_magnitude_md, na.rm = TRUE),
            .groups = 'drop'
        )
    
    p <- ggplot(df, aes(x = year)) +
      geom_line(aes(y = avg_magnitude, color = "Average"), size = 1.2) +
      geom_line(aes(y = max_magnitude, color = "Maximum"), size = 1.2) +
      geom_line(aes(y = min_magnitude, color = "Minimum"), size = 1.2) +
      labs(title = "Magnitude Trends Over Time",
           x = "Year",
           y = "Duration Magnitude (Md)",
           color = "Statistic") +
      theme_minimal() + scale_color_manual(values = c("Average" = "#d73027","Maximum" = "#fc8d59",  "Minimum" = "#91bfdb"))
    
    ggplotly(p, tooltip = c("x", "y", "colour"))
  }
    )
}
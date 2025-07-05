#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
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
library(lubridate)

# Define UI for application that draws a histogram
ui <- dashboardPage(
          dashboardHeader(title = "Mt. Vesuvius Seismic Activity"),
          
          dashboardSidebar(
            sidebarMenu(
              menuItem("Overview", tabName = "overview", icon = icon ("chart-line")),
              menuItem("Temporal Trends", tabName = "temporal-trends", icon = icon("calendar-alt"))
            )
            ),
          
          dashboardBody(
            tags$head(
              tags$style(HTML("
                                .main-header .navbar{
                                background-color: #d73027 !important;
                                }
                                
                                .main-header .logo{
                                background-color: #d73027 !important;
                                }
                                
                                .content-wrapper, .right-side{
                                background-color: #f9f9f9 !important;
                                }"))
            ),
            
            tabItems(
              tabItem(tabName = "overview",
                      fluidRow(
                        valueBoxOutput("total-events"), 
                        valueBoxOutput("avg-magnitude"),
                        valueBoxOutput("max-magnitude")
                      ),
                      fluidRow(
                        valueBoxOutput("depth-range"),
                        valueBoxOutput("time-span"),
                        valueBoxOutput("event-types")
                      ),
                      fluidRow(
                        box(
                          title = "Event Map", status = "danger", solidHeader = TRUE,
                          width = 12, height = 500,
                          plotlyOutput("loc-map")
                        )
                      )
                      ),
              
            tabItem(tabName = "temporal-trends",
                    fluidRow(
                      box(
                        title = "Number of Events, Annually", status = "warning", solidHeader = TRUE,
                        width = 12, height = 455,
                        plotlyOutput("annual_trends")
                      )
                      ),
                    fluidRow(
                      box(
                        title = "Monthly Dist.", status = "warning", solidHeader = TRUE,
                        width = 6, height = 455,
                        plotlyOutput("monthly-graph")
                      ),
                      box(
                        title = "Hourly Dist.", status = "warning", solidHeader = TRUE,
                        width = 6, height = 455,
                        plotlyOutput("hourly-graph")
                      )
                    ),
                    fluidRow(
                      box(
                        title = "Magnitude Trends with Time", status = "warning", solidHeader = TRUE,
                        width = 12, height = 455,
                        plotlyOutput("magnitude-trend")
                      )
                    )
                    
                    )
            
          )
)
)
        
    


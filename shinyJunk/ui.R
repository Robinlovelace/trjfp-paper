library(shiny)

# Define UI for slider demo application
shinyUI(fluidPage(

  #  Application title
  titlePanel("Sliders"),

  # Sidebar with sliders that demonstrate various available
  # options
  sidebarLayout(
    sidebarPanel(

      sliderInput(min = min(donations$date, na.rm = T), max = max(donations$date, na.rm = T),
                  value = c( median(donations$date, na.rm = T), max(donations$date, na.rm = T)), inputId = "date", label = "Date")

    ),

    # Show a table summarizing the values entered
    mainPanel(
      plotOutput("values")
    )
  )
))
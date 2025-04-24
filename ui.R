library(plotly)
library(shiny)
library(shinyjs)

shinyUI(fluidPage(
  
  useShinyjs(),
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "stylesheet.css"),
    tags$script(HTML(
      "$(document).on('click', '.sprite', function() {
      Shiny.setInputValue('sprite', $(this).data('value'));
      });"
    ))
  ),
  
  fluidRow(
    column(3,
           id='pkm',
           htmlOutput("pkmName"),
           plotlyOutput('pkmStat'),
           htmlOutput("pkmType")),
    column(6,
           plotlyOutput('mapPlot'),
           htmlOutput('uncatchableMessage')),
    column(3,
           id='rightPanel',
           htmlOutput("clickDataOut")
           )
  ),
  
  fluidRow(
    column(12, 
           uiOutput("imageGrid"),
           tags$span(class='pokeball top-left'),
           tags$span(class='pokeball-upper top-left'),
           tags$span(class='pokeball top-right'),
           tags$span(class='pokeball-upper top-right'),
           tags$span(class='pokeball bottom-left'),
           tags$span(class='pokeball-upper bottom-left'),
           tags$span(class='pokeball bottom-right'),
           tags$span(class='pokeball-upper bottom-right')
    )
  )
  
))

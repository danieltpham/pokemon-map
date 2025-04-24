library(magrittr)
library(plotly)
library(purrr)
library(shiny)
library(shinyjs)

# dir.create('~/.fonts')
# file.copy("www/font.ttf", "~/.fonts")
# system('fc-cache -f ~/.fonts')

encounter <- function(x){
  return(
    list(type = "line",
         line = list(width=15, color='black'),
         opacity = 0.8,
         x0 = x[1], x1 = x[3],
         y0 = x[2], y1 = x[4]))
}

pkmData <- read.csv('www/pokemon_data.csv')
cityData <- read.csv('www/data.csv')

shinyServer(function(input, output) {
    
    # Catchable Location
    loc <- reactiveVal()
    
    # Uncatchable Location
    uncatch_loc <- reactiveVal()

    output$mapPlot <- renderPlotly({
        p <- plot_ly(data = cityData,
                     x = ~x,
                     y = ~y,
                     source = "Source",
                     customdata = ~map2(location, description, ~list(.x, .y))) %>%
          
          add_trace(type='scatter',
                    hovertemplate=paste(cityData$location,'<extra></extra>'),
                    mode='markers',
                    
                    # Style city coordinates
                    marker = list(symbol=c('square'),
                                    size=15,
                                    opacity=0)) %>%
          
          config(displayModeBar = F) %>%
          
          layout(
                # TODO: PKM Location on Routes as lines
                shapes = loc(),
            
                # Style hover labels
                hoverlabel = list(bgcolor='lightgrey',
                                  font=list(family="PKMN RBYGSC")),
                
                xaxis = list(  title = "",
                               zeroline = FALSE,
                               showline = FALSE,
                               showticklabels = FALSE,
                               showgrid = FALSE,
                               fixedrange = TRUE,
                               range=c(-260,260)),
                
                yaxis = list(  title = "",
                               zeroline = FALSE,
                               showline = FALSE,
                               showticklabels = FALSE,
                               showgrid = FALSE,
                               fixedrange = TRUE,
                               scaleanchor="x",
                               scaleratio=1,
                               range=c(-260,260)),
                
                images = list(
                    list(source =  "map.png",
                         xref = "x",
                         yref = "y",
                         x = -130,
                         y = 220,
                         sizex = 260,
                         sizey = 440,
                         sizing = "stretch",
                         opacity = 1,
                         layer = "below"
                    )))
    })
    
    hoverData <- reactive({
      currentEventData <- unlist(event_data(event = "plotly_hover", source = "Source", priority = "event"))
    })
    
    clickData <- reactiveVal()
    
    observe({
      clickData(unlist(event_data(event = "plotly_click", source = "Source", priority = "event")))
    })
    
    onclick(id="uncatchableMessage",{uncatch_loc('')})
    
    observeEvent(input$sprite, {
      data_point <- pkmData[input$sprite,3:7]
      name <- pkmData[input$sprite,2]
      type1 <- pkmData[input$sprite,8]
      type2 <- pkmData[input$sprite,9]
      
      # Update catchable location on map
      loc_lst <- lapply(eval(parse(text=as.character(pkmData[input$sprite,10]))),
                        function(location) {encounter(location)})
      loc(loc_lst)
      
      #If is uncatchable, then display message on map
      uncatch_loc(pkmData[input$sprite,11])
      
      # LEFT PANEL / POKEMON INFO
      
      output$pkmName <- renderText({
        paste0('<h4>',name,'</h4>')
      })
      
      output$pkmType <- renderText({
        
        if (type2!='') {
          paste0('<p>TYPE<b>1</b>/',type1,'</p>','<p>TYPE<b>2</b>/',type2,'</p>')
        }
        else {
          paste0('<p>TYPE<b>1</b>/',type1,'</p>')
        }
      })
      
      output$pkmStat <- renderPlotly({
        fig <- plot_ly(
          height = 250,
          y = names(data_point),
          x = unlist(data_point),
          type = "bar",
          orientation = 'h',
          text = unlist(data_point),
          textposition = 'auto',
          marker = list(color='lightgrey')
        ) %>%
          config(displayModeBar = F) %>%
          layout(
            hovermode = FALSE,
            font = list(family = "CustomFont"),
            yaxis = list(categoryorder = "array",
                         categoryarray = rev(names(data_point)),
                         title = "",
                         zeroline = FALSE,
                         showline = FALSE,
                         showgrid = FALSE,
                         fixedrange = TRUE),
            xaxis = list(  title = "",
                           zeroline = FALSE,
                           showline = FALSE,
                           showticklabels = FALSE,
                           showgrid = FALSE,
                           fixedrange = TRUE,
                           range=c(0,160))
          )
      })
    })
    
    # LEFT PANEL / Welcome Message
    output$pkmName <- renderText({
      paste0('<h4>About the project</h4>')
    })
    
    output$pkmType <- renderText({
      paste0('<br>Project. K-DEX is built with R Shiny, ShinyJS and Plotly. <br><br>Built as proof of concept that Plotly can be used for custom map data.<br><br>Built 2020 by <a href="https://www.danielpham.com.au" target="_blank">D. Pham</a>. Inspired by <a href="https://www.datasciencecentral.com/profiles/blogs/is-r-shiny-versatile-enough-to-build-a-video-game" target="_blank">P. Silva</a> and <a href="https://amyhenning.codes/blog/recreating-pokemon-red-blue-pokedex/" target="_blank">A. Henning</a>.')
    })
    
    observeEvent(uncatch_loc(), {
      if (uncatch_loc()!='') {
        output$uncatchableMessage <- renderText({
          paste0('<div class="message"><p>',uncatch_loc(),'</p></div>')
        })
      }
      else {
        output$uncatchableMessage <- renderText({})
      }
    })
    
    onclick(id = "mapClick", expr = {clickData(hoverData())})
    
    # RIGHT PANEL / LOCATION INFO
    output$clickDataOut <- renderText({
      if (is.null(clickData())) {
        paste0('<div style="padding:1.5em"><h4>Project. K-DEX!</h4></div>',
               '<div id="boxes" class=""><div id="box-group-left"><div class="box"></div><div class="box"></div><div class="box"></div><div class="box"></div></div><div id="box-group-right"><div class="box"></div><div class="box"></div><div class="box"></div><div class="box"></div></div></div><hr>',
               '<div style="padding:1.5em">Click on each pokemon to see stats and location. <br><br>Click on each City to find information.<br><br>For more information about the creator, <a href="https://danielpham.com.au" target="_blank">click here!</a></div>')
      }
      else {
      paste0('<div style="padding:1.5em"><h4>',clickData()[5],'</h4></div>',
             '<div id="boxes" class=""><div id="box-group-left"><div class="box"></div><div class="box"></div><div class="box"></div><div class="box"></div></div><div id="box-group-right"><div class="box"></div><div class="box"></div><div class="box"></div><div class="box"></div></div></div><hr>',
             '<div style="padding:1.5em">',clickData()[6],'</div>')
      }
    })
    
    # BOTTOM PANEL / Grid of pokemon
    output$imageGrid <- renderUI({
      fluidRow(
        lapply(c(1:151), function(img) {
          column(1, 
                 tags$img(src=paste0("sprite/", img,'.png'), class='sprite', 'data-value'=img, tabindex=0)
          )
        })
        )
    })
    
    output$test <- renderText({
      input$sprite
    })

})

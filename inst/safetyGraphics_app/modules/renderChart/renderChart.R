#' Render eDISH chart - server code
#'
#' This module creates the Chart tab for the Shiny app, which contains the interactive eDISH graphic.
#'
#' Workflow:
#' (1) A change in `data`, `settings`, or `valid` invalidates the eDISH chart output
#' (2) Upon a change in `valid`, the export chart functionality is conditionally made available or unavailable to user
#' (3) If "export chart" button is pressed, data and settings are passed to the parameterized report, knitted using
#'     Rmarkdown, and downloaded to user computer.
#'
#' @param input Input objects from module namespace
#' @param output Output objects from module namespace
#' @param session An environment that can be used to access information and functionality relating to the session
#' @param data A data frame  [REACTIVE]
#' @param settings list of settings arguments for chart [REACTIVE]
#' @param chart name of chart to be rendered [STRING]
#' @param type type of chart (e.g. "htmlwidget")
#' @param valid A logical indicating whether data/settings combination is valid for chart [REACTIVE]

renderChart <- function(input, output, session, data, settings, valid, chart, type, width){

  ns <- session$ns

  # function for chart
  #chart_fun <- match.fun(chart)
  # function for shiny output
  #output_fun <- match.fun(paste0("output_", chart))
  # function for shiny render
  #render_fun <- match.fun(paste0("render_", chart))
  # id for chart
  chart_id <- paste0("chart_", chart)


  if (type=="module"){

    chartCode <- system.file("custom", type, paste0(chart, ".R"), package = "safetyGraphics")
    source(chartCode)
    chart_ui <- match.fun(paste0(chart, "_UI"))
    chart_server <- match.fun(chart)
    
    output$chart <- renderUI({
      chart_ui(ns(chart_id))
    })
    
    callModule(chart_server, chart_id)
    
  } else {
    ## code to dynamically generate the output location
    output$chart <- renderUI({
      if (type=="htmlwidget"){
        output_chartRenderer(ns(chart_id))
      } else if (type=="static") {
        plotOutput(ns(chart_id), width = paste0(width, "px"))
      }else if (type=="plotly") {
        plotlyOutput(ns(chart_id), width = paste0(width, "px"))
      } else if (type=="module"){
        hepexplorer_mod_UI(ns(chart_id))
      }
    })
    
    ## code to render widget and fill in the output location
    if (type=="htmlwidget"){
      render_fun <- match.fun("render_chartRenderer")
    } else if (type=="static"){
      render_fun <- match.fun("renderPlot")
    } else if (type=="plotly"){
      render_fun <- match.fun("renderPlotly")
    } 
    
    output[[chart_id]] <- render_fun({
      req(data())
      req(settings())
      #trimmed_data<-trim_data()
      chartRenderer(data = data(), settings = settings(), chart = chart, debug_js=TRUE)
    })
  }
 

}

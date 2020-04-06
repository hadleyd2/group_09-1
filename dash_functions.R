## Grouped Density Plot Function ####
make_violin <- function(xaxis="all") {
  
  #get label matching grouping factor
  x_label <- groupKey$label[groupKey$value==xaxis]
  
  if (xaxis == "min_stay") df$min_stay <- paste0(df$min_stay, " Night")
  
  #create ggplot when no grouping is selected
  if (x_label == "No Grouping") {
    p <- df %>% 
      ggplot(aes(x=price)) + 
      geom_density() +
      theme_bw(14) +
      theme(plot.title = element_text(size = 14)) +
      ggtitle(label="Price Density for All Listings") +
      scale_x_continuous(paste0("Listing Price (", "\u20AC", ") per Night")) +
      ylab("Density")
  } else {
    p <- ggplot(df, aes(x=!!sym(xaxis), y=price, color=!!sym(xaxis))) +
      geom_violin(stat = "ydensity") +
      scale_y_log10() +  # change to log10 scale since density of price is skewed
      ylab(paste("Price (", "\u20AC", ")", sep='')) +
      xlab(x_label) +
      ggtitle("Distribution of Listing Price") +
      theme_bw(14) +
      theme(plot.title = element_text(size = 14), 
            axis.text.x = element_blank())
  }
  
  ggplotly(p)
}

## Scatterplot with Trendline
make_scatter <- function(xaxis='reviews', 
                         pricerange=c(0,0), 
                         stayfilter=c(1, 5), 
                         distancefilter=c(1, 5),
                         x.trans='none',
                         y.trans='none') {
  
  ## Find label for X-axis variable
  x_label <- xaxisKey$label[xaxisKey$value==xaxis]
  
  ## Make filter via pricerange argument
  if (sum(pricerange) == 0) pricerange <- c(min(df$price), max(df$price))
  
  ## Load data, filter, and select variables
  df.tmp <- df %>%
    filter(price >= pricerange[1],
           price <= pricerange[2],
           as.numeric(min_stay) >= stayfilter[1],
           as.numeric(min_stay) <= stayfilter[2],
           distance >= quantile(df$distance)[distancefilter[1]],
           distance <= quantile(df$distance)[distancefilter[2]]) %>% 
    select(!!sym(xaxis), price) %>%
    mutate(xaxis = switch(x.trans,
                          none = !!sym(xaxis),
                          log = log(!!sym(xaxis)),
                          root = sqrt(!!sym(xaxis)),
                          reciprocal = 1/(!!sym(xaxis)))) %>% 
    mutate(price = switch(y.trans,
                         none = price,
                         log = log(price),
                         root = sqrt(price),
                         reciprocal = 1/(price))) 
  
  if (x_label == 'Minimum Stay') {
    if (stayfilter[1] == stayfilter[2]) {
    p <- df.tmp %>% 
      ggplot(aes(x=!!sym(xaxis), y=price)) +
      geom_jitter(alpha=0.3, width=0.25) + 
      geom_abline(intercept=mean(df.tmp$price), slope=0) +
      xlab(x_label) +
      scale_y_continuous(paste0("Price (", "\u20AC", ")")) +
      ggtitle(paste0("Scatterplot of ", x_label, " vs Price with Trendline")) +
      theme_bw(14)
    } else {
      p <- df.tmp %>% 
        mutate(xaxis = as.numeric(as.character(!!sym(xaxis)))) %>% 
        ggplot(aes(x=!!sym(xaxis), y=price)) +
        geom_jitter(alpha=0.3,width=0.1) +
        geom_smooth(method='lm') + 
        scale_x_discrete(name=x_label,
                         breaks=c(as.character(stayfilter[1]:stayfilter[2])),
                         labels=c(as.character(stayfilter[1]:stayfilter[2]))) +
        scale_y_continuous(paste0("Price (", "\u20AC", ")")) +
        ggtitle(paste0("Scatterplot of ", x_label, " vs Price with Trendline")) +
        theme_bw(14)
    }
  } else {
    p <- ggplot(df.tmp, aes(x=!!sym(xaxis), y=price)) +
      geom_point(alpha=0.3) + 
      geom_smooth(method='lm') + 
      xlab(x_label) +
      scale_y_continuous(paste0("Price (", "\u20AC", ")")) +
      ggtitle(paste0("Scatterplot of ", x_label, " vs Price with Trendline")) +
      theme_bw(14)
  }
  
  ggplotly(p)
}

## Tabs

render_content <- function(tab) {
  if (tab == 'tab-1') {
    ## Markdown Text and Image
    htmlDiv(list(instructions),
            style=list('justify-content'='center'))
  } else if (tab == 'tab-2') {
    ## Histogram with dropdown for diamond clarity and
    ## radio option for y-axis scale
    htmlDiv(list(htmlDiv(list(group_density),
                         style=list('flex-basis'='30%')), 
                 htmlDiv(list(dens.graph),
                         style=list('flex-basis'='70%'))),
            )
  } else if (tab == 'tab-3') {
    ## Two diamond cut plots controlled by slider
    htmlDiv(list(htmlDiv(
                   list(htmlLabel('Filter Listings by Price'),
                        price_slider),
                   style=list('width'='80%',
                              'padding-left'='10%',
                              'padding-right'='20%',
                              margin=5)), 
                 htmlDiv(
                   list(htmlLabel('Filter Listings by Minimum Night Stay'),
                        stay_slider),
                   style=list('width'='80%',
                              'padding-left'='10%',
                              'padding-right'='20%',
                              margin=5)),
                 htmlDiv(
                   list(htmlLabel('Filter Listings by Distance from City Center (Percentile)'),
                        dist_slider),
                   style=list('width'='80%',
                              'padding-left'='10%',
                              'padding-right'='20%',
                              margin=5)),
                 htmlDiv(list(scatterplot_xaxis,
                              scatterplot_trans),
                         style=list('display'='flex')),
                 scat_graph),
            style=list('width'='80%'))
  }
}
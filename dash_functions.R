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
make_scatter <- function(xaxis='latitude', 
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
    rename(xvar = !!sym(xaxis),
           price = price)
  
  ## Transform price via radio button
  df.tmp$price <- switch(y.trans,
                          none = df.tmp$price,
                          log = log(df.tmp$price),
                          root = sqrt(df.tmp$price),
                          reciprocal = 1/(df.tmp$price))
  
  if (x_label == 'Minimum Stay') {
    if (stayfilter[1] == stayfilter[2]) {
      # Conditions are x-axis variable is minimum stay (min_stay) and
      # only one option is selected for minimum night stay filter
      
      # Apply transformation to minimum stay
      df.tmp$xvar <- as.numeric(as.character(df.tmp$xvar))
      
      df.tmp$xvar <- round(switch(x.trans,
                            none = df.tmp$xvar,
                            log = log(df.tmp$xvar),
                            root = sqrt(df.tmp$xvar),
                            reciprocal = 1/(df.tmp$xvar)),
                           2)

      df.tmp$xvar <- factor(df.tmp$xvar)
      
      p <- df.tmp %>% 
        ggplot(aes(x=xvar, y=price)) +
        geom_jitter(alpha=0.3, width=0.1) + 
        geom_abline(intercept=mean(df.tmp$price), 
                    slope=0,
                    color='blue',
                    size=1.25,
                    alpha=0.5) +
        scale_x_discrete(x_label) +
        scale_y_continuous(paste0("Price (", "\u20AC", ")")) +
        ggtitle(paste0("Scatterplot of ", x_label, " vs Price with Trendline")) +
        theme_bw(14)
    } else {
      # Conditions are x-axis variable is minimum stay (min_stay) and
      # the stay filter has more than one option selected
      
      # Apply transformation to minimum stay
      df.tmp$xvar <- as.numeric(as.character(df.tmp$xvar))
      
      df.tmp$xvar <- round(switch(x.trans,
                            none = df.tmp$xvar,
                            log = log(df.tmp$xvar),
                            root = sqrt(df.tmp$xvar),
                            reciprocal = 1/(df.tmp$xvar)),
                           2)
      
      df.tmp$xvar <- factor(df.tmp$xvar)
      
      cfs <- coef(lm(price ~ xvar, data=df.tmp))
       
      # Adjust x-axis labels according to xvar transformation
      xvar.labels <- switch(x.trans,
                            none = stayfilter[1]:stayfilter[2],
                            log = log(stayfilter[1]:stayfilter[2]),
                            root = sqrt(stayfilter[1]:stayfilter[2]),
                            reciprocal = 1/(stayfilter[1]:stayfilter[2]))
      
      p <- df.tmp %>% 
        ggplot(aes(x=xvar, y=price)) +
        geom_jitter(alpha=0.3,width=0.1) +
        geom_abline(intercept=cfs[1],
                    slope=cfs[2],
                    color='blue',
                    size=1.25,
                    alpha=0.5) +
        scale_x_discrete(name=x_label) +
        scale_y_continuous(paste0("Price (", "\u20AC", ")")) +
        ggtitle(paste0("Scatterplot of ", x_label, " vs Price with Trendline")) +
        theme_bw(14)
    }
  } else {
    
    # Transform x-variable using radio button
    df.tmp$xvar <- switch(x.trans,
                          none = df.tmp$xvar,
                          log = log(df.tmp$xvar),
                          root = sqrt(df.tmp$xvar),
                          reciprocal = 1/(df.tmp$xvar))
    
    cfs <- coef(lm(price ~ xvar, data=df.tmp))
    
    p <- df.tmp %>% 
      ggplot(aes(x=xvar, y=price)) +
      geom_point(alpha=0.3) + 
      geom_abline(intercept=cfs[1],
                  slope=cfs[2],
                  color='blue',
                  size=1.25,
                  alpha=0.5) + 
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
                         style=list('width'='40%')), 
                 htmlDiv(list(dens.graph),
                         style=list('flex-basis'='70%'))),
            )
  } else if (tab == 'tab-3') {
    htmlDiv(list(
      ## Slider Filters
      htmlDiv(list(
        htmlDiv(list(htmlLabel('Filter Listings by Price'),
                     price_slider),
                style=list(margin=5)),
        htmlDiv(list(htmlLabel('Filter Listings by Minimum Night Stay'),
                     stay_slider),
                style=list(margin=5)),
        htmlDiv(list(htmlLabel('Filter Listings by Distance from City Center (Percentile)'),
                     dist_slider),
                style=list(margin=5))),
        style=list(margin=20)
        ),
      ## Right-hand side of Data Analysis tab
      htmlDiv(list(
        ## Create divs for variable selection and transformations
        htmlDiv(list(
          ## Variable Selection
          htmlDiv(list(
            htmlLabel('Select Independent Variable'),
            xaxis.Dropdown),
            style=list('flex-basis'='50%',
                       margin=10)),
          ## Transformations
          htmlDiv(list(
            htmlDiv(list(htmlLabel(id='trans-label'),
                         x.button),
                    style=list(margin=5)),
            htmlDiv(list(htmlLabel('Apply Transform to Price'),
                         y.button),
                    style=list(margin=5))),
            style=list('flex-basis'='50%',
                       margin=8)
            )
          ),
          style=list('display'='flex')), ## End of transformation div
          scat_graph),
        style=list(margin=5,
                   'flex-basis'='65%'))
      ),
      style=list('display'='flex')
      )
  }
}

## Grouped Density Plot Function ####
make_violin <- function(xaxis="all") {
  
  #get label matching grouping factor
  x_label <- groupKey$label[groupKey$value==xaxis]
  
  #create ggplot when no grouping is selected
  if (x_label == "No Grouping") {
    p <- df %>% 
      ggplot(aes(x=price)) + 
      geom_density() +
      theme_bw(14) +
      theme(plot.title = element_text(size = 14)) +
      ggtitle(label="Price Density for All Listings") +
      scale_x_continuous("Listing Price per Night", 
                         labels=scales::dollar_format(suffix="\u20AC", prefix='')) +
      ylab("Density")
  } else {
    p <- ggplot(df, aes(x=!!sym(xaxis), y=price)) +
      geom_violin(stat = "ydensity") +
      scale_y_log10() +  # change to log10 scale since density of price is skewed
      ylab(paste("Price (", "\u20AC", ")", sep='')) +
      xlab(x_label) +
      ggtitle("Distribution of Listing Price") +
      theme_bw(14) +
      theme(plot.title = element_text(size = 14), 
            axis.text.x = element_text(angle = 60, hjust = 1))
  }
  
  ggplotly(p)
}
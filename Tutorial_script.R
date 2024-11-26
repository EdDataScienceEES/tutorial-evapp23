#tutorial Data Science 2024
#Eva Pelaez


#libraries
library(tidyverse)
library(dplyr)
library(ggplot2)
library(readr)
#install.packages("plotly")
library(plotly)
#install.packages("rnaturalearth")
#install.packages("rnaturalearthdata")
library(rnaturalearth)

#Load Living Planet Index Data
load("data/LPI_data.Rdata")
#from csv data <- read.csv("LPIdata_CC.csv")


# Reshaping data to long format and converting columns to numeric
data2 <- data %>%
  gather("year", "abundance", 25:69) %>%
  mutate(
    year = parse_number(year),
    abundance = as.numeric(abundance)
  )


#cleaning up the data
elephant_clean <- data2 %>%
  filter(str_detect(Common.Name, "African elephant")) %>%
  select(Country.list, year, abundance) %>%
  filter(!Country.list %in% c("Botswana, Tanzania, United Republic Of, South Africa, Uganda, Zimbabwe")) %>%
  na.omit() %>% 
  mutate(Country.list = case_when(
    Country.list == "Tanzania, United Republic Of" ~ "Tanzania",
    Country.list == "Congo, The Democratic Republic Of The" ~ "Dem. Rep. Congo",
    Country.list == "Central African Republic" ~ "Central African Rep.",
    Country.list == "Swaziland" ~ "eSwatini",
    TRUE ~ `Country.list`
  ))

# Load country data from rnaturalearth
countries <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")

# Subset to African countries
africa_countries <- countries %>%
  filter(region_un == "Africa") %>%
  select(name, region_un, subregion) %>%
  rename(Country = name, Region = subregion)

elephant_clean <- elephant_clean %>%
  left_join(africa_countries, by = c("Country.list" = "Country"))
  
elephant_clean <- elephant_clean %>% 
  filter(!Region %in% c("Western Africa")) %>% 
  mutate(Region = case_when(
    Region == "Eastern Africa" ~ "Eastern_Africa",
    Region == "Middle Africa" ~ "Middle_Africa",
    Region == "Southern Africa" ~ "Southern_Africa",
    TRUE ~ `Region`
  ))


#basic scatter plot
(ggplot_scatter <- ggplot(elephant_clean, aes(x= year, y= abundance, colour = Region)) +
    geom_point(size = 3) +
    geom_line() +
    theme_classic() +
    labs(
      title = "Elephant abundance from 1970 to 2013",
      x = "Year",
      y = "Abundance"
    ))
ggsave("ggplot_scatter.png", ggplot_scatter,width=14,height=8,dpi=450)


#scatter plot using plotly 
#simple no distinction
plot1 <- plot_ly(data = elephant_clean, x= ~year, y= ~abundance, type = "scatter", mode = "markers")
plot1

#distinction between regions
plot2 <- plot_ly(data = elephant_clean, x= ~year, y= ~abundance, color = ~Region, type= "scatter", mode = "markers")
plot2

#distinction between regions and lines
plot3 <- plot_ly(data = elephant_clean, x= ~year, y= ~abundance, color = ~Region, type= "scatter", mode = "lines+markers",
                 colors = "Dark2")
plot3

htmlwidgets::saveWidget(plot1, "int_scatter1.html")
htmlwidgets::saveWidget(plot2, "int_scatter2.html")
htmlwidgets::saveWidget(plot3, "int_scatter3.html")


# Calculate mean abundance for each region in the specified year ranges
mean_abundance <- elephant_clean %>%
  mutate(YearRange = case_when(
    year >= 1970 & year <= 1989 ~ "1970-1989",
    year >= 1990 & year <= 2010 ~ "1990-2010",
    TRUE ~ NA_character_           
  )) %>%
  filter(!is.na(YearRange)) %>%     
  group_by(Region, YearRange) %>%  
  summarize(MeanAbundance = mean(abundance, na.rm = TRUE), .groups = 'drop')

mean_abundance$YearRange <- factor(mean_abundance$YearRange, levels = c("1970-1989", "1990-2010"))

#baisc ggplot bar chart
(basic2 <- ggplot(mean_abundance, aes(fill=Region, x= YearRange, y= MeanAbundance)) +
  geom_bar(stat = "identity", position = "dodge") +  # Use stat="identity" to plot MeanAbundance as is
  labs(title = "Mean Abundance by Region and Year Range",
       x = "Year Range",
       y = "Mean Abundance",
       fill = "Region") +
  theme_bw())
ggsave("ggplot_bar.png", basic2,width=14,height=8,dpi=450)


#plotly bar chart
bar_plotly <- plot_ly(data = mean_abundance,x= ~YearRange, y= ~MeanAbundance, type="bar",color = ~Region)
htmlwidgets::saveWidget(bar_plotly, "simpleway_bar_plotly.html")

#transforming data from long to wide format
mean_abund_wide <- spread(mean_abundance,Region, MeanAbundance)

#bar chart grouped bars
fig3 <- plot_ly(data = mean_abund_wide, x = ~YearRange, y = ~Eastern_Africa, type = 'bar', name = 'Eastern Africa') %>% 
  add_trace(y = ~Middle_Africa, name = 'Middle Africa') %>% 
  add_trace(y = ~Southern_Africa, name = 'Southern Africa') %>% 
  layout(yaxis = list(title = 'Count'), barmode = 'group')
fig3
htmlwidgets::saveWidget(fig3, "adding_variables_bar.html")

#figure with stacked bars
fig_stacked <- fig3 %>% layout(yaxis = list(title = 'Count'), barmode = 'stack')
fig_stacked
htmlwidgets::saveWidget(fig_stacked, "stacked_bar.html")


#fig with direct labels on bars
fig <- plot_ly(data = mean_abund_wide, x = ~YearRange, y = ~Eastern_Africa, type = 'bar', name = 'Eastern Africa', 
               text = ~Eastern_Africa, textposition = "auto") %>% 
  add_trace(y = ~Middle_Africa, name = 'Middle Africa', text = ~Middle_Africa, textposition = "auto") %>% 
  add_trace(y = ~Southern_Africa, name = 'Southern Africa', text = ~Southern_Africa, textposition = "auto") %>% 
  layout(yaxis = list(title = 'Count'), barmode = 'group')
fig
htmlwidgets::saveWidget(fig, "barlabels_.html")


#fig with rotated xaxis labels
fig4 <- plot_ly(data = mean_abund_wide, x = ~YearRange, y = ~Eastern_Africa, type = 'bar', name = 'Eastern Africa') %>% 
  add_trace(y = ~Middle_Africa, name = 'Middle Africa') %>% 
  add_trace(y = ~Southern_Africa, name = 'Southern Africa') %>% 
  layout(xaxis = list(title = "Year Range", tickangle = -45),
                        yaxis = list(title = "Count"),
                        margin = list(b = 100),
                        barmode = 'group')
fig4
htmlwidgets::saveWidget(fig4, "rotatedlabels_bar.html")


#with custom colors, accpets both rgb values and normal named colors
fig5 <- plot_ly(data = mean_abund_wide, x = ~YearRange, y = ~Eastern_Africa, type = 'bar', name = 'Eastern Africa',
                marker = list(color = "rgb(255, 127, 80)")) %>% 
  add_trace(y = ~Middle_Africa, name = 'Middle Africa',
            marker = list(color = 'rgb(135, 206, 235)')) %>% 
  add_trace(y = ~Southern_Africa, name = 'Southern Africa',
            marker = list(color = "rgb(152, 251, 152)")) %>% 
  layout(xaxis = list(title = "Year Range"),
         yaxis = list(title = "Count"),
         margin = list(b = 100),
         barmode = 'group',
         title = "Average Population of elephants")
fig5
htmlwidgets::saveWidget(fig5, "final_custom_bar.html")


#MAPS
#adding the relavant column for hover data
elephant_map_df <- elephant_clean %>% 
  group_by(year, Country.list) %>%
  summarize(total_abundance = sum(abundance, na.rm = TRUE), .groups = "drop")

#choropleth map with year interaction
africa_map <- plot_geo(elephant_map_df, locationmode = "country names", frame = ~year) %>% 
  add_trace(locations = ~Country.list, 
            z =~total_abundance,
            zmin = 0,
            zmax = max(elephant_map_df$total_abundance),
            color = ~total_abundance,
            colorscale = "Plasma") %>% 
  layout(geo = list(scope = "africa"),
         title = "Total elephant abundance in Africa\n from 1970 to 2013")
africa_map
htmlwidgets::saveWidget(africa_map, "interactive_map.html")



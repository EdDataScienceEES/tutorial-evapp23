<center><img src="{{ site.baseurl }}/tutheaderbl.png" alt="Img"></center>

To add images, replace `tutheaderbl1.png` with the file name of any image you upload to your GitHub repository.

### Tutorial Aims

#### <a href="#section1"> 1. Good Data Visualisation</a>

#### <a href="#section2"> 2. Are interactive plots that much better?</a>

#### <a href="#section3"> 3. Introduction to `Plotly` package</a>

#### <a href="#section4"> 4. Scatter plots</a>

#### <a href="#section5"> 5. Bar Charts</a>

#### <a href="#section6"> 6. Choropleths</a>

You can read this text, then delete it and replace it with your text about your tutorial: what are the aims, what code do you need to achieve them?


<a name="section1"></a>

## 1. Good Data Visualisation
We have already learned from our previous data visualisation tutorials what makes a good plot. A quick recap on the main points:
1. Appropriate plot type for results
2. Plot is well organised
3. X and Y axis are easy to read and have the correct units
4. Clear and informative legend

<a name="section2"></a>

## 2. Are interactive plots that much better?

You may be asking yourself, why I am putting myself through more coding when I already know how to make plots using the ggplot2 package? That is because interactive plots are amazing in visualising data in a way that is really engaging.

Interactive plots invite people to actively explore the data being presented to them rather than just looking at a static image. This helps with retention of what the plot is explaining as non-expert audiences can filter and custom the image and build their understanding.

The one downside of interactive plots its that they are not appropriate for academic papers but they are commonly used for online websites and newspapers. So lets get started and learn how to make them!

<a name="section3"></a>

## 3. Introduction to `Plotly` package

This tutorial will consist on learning how to make interactive plots using the `Plotly` package. The `Plotly` package utilities the power of Plotly.js, a popular JavaScript library for interactive plotting, and allow us to use R to create customisable, interactive, web-based visualisations.

Some key features of this package:
- Interactive plots: zoom, pan and hover features, with clickable legends and data point selection.
- Wide range of plot types: can create any of the basic plots (scatter, barcharts, histograms) as well as more advanced and specialised plots(choropleths, 3D scatter plots, financial charts).
- It works well with other common R packages such as `ggplot2`, `dplyr` or `shiny`.
- It outputs plots that are HTML and web compatible: 
- Cross-language compatibility: Though it uses R, the underlying Plotly.js library ensures that visualizations are consistent across Python, JavaScript, and R.

This is a short summary of what this package can do but if you are curoius on the extent on what this package can do, head over to their website.

During this tutorial will be using `Plotly` to create several scatter plots, bar charts and choropleths and at the same time learning the basic functions of this amazing package. 

<a name="section4"></a>

## 3. Scatter plots
As everyone know, before we even start we need to load our libraries!

```r
#_Loading libraries_
library(tidyverse)
library(dplyr)
library(ggplot2)
library(readr)

#_install.packages("plotly")_
library(plotly)

```

We will use data from the Living Planet Index, which you have already downloaded from the Github repository (Click on Clone or Download/Download ZIP and then unzip the files)

```r
# Import data from the Living Planet Index - population trends of vertebrate species from 1970 to 2014
data <- read.csv("LPIdata_CC.csv")
```
For the first plot we will be creating a scatter plot using `ggplot2`as a way to then later compare it to a scatter plot created using `plotly`.
We will be plotting the __Elephant abundance from the year 1970 to 2013 in different African regions__

So first we need to reshape and clean up our data

```r
# Reshaping data to long format and converting columns to numeric
data2 <- data %>%
  gather("year", "abundance", 25:69) %>%
  mutate(
    year = parse_number(year),
    abundance = as.numeric(abundance)
  )
  
#Cleaning up the data
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
```

To be able to plot the elephant abundance across different African regions we are missing a column on regions. That is why we need to download the following package and data frame to be able to match the countries in our Living Planted Index data set to their respective African region.

```r
#install.packages("rnaturalearth")
#install.packages("rnaturalearthdata")
library(rnaturalearth)                  #These two packages will help us download data for countries and regions

# Load country data from rnaturalearth
countries <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")

# Subset to African countries
africa_countries <- countries %>%
  filter(region_un == "Africa") %>%
  select(name, region_un, subregion) %>%
  rename(Country = name, Region = subregion)

#Join our two datasets
elephant_clean <- elephant_clean %>%
  left_join(africa_countries, by = c("Country.list" = "Country"))
  
#Remove the  Western Africa region as there is only 4 data points on it and rename our other regions to make future coding easier 
elephant_clean <- elephant_clean %>% 
  filter(!Region %in% c("Western Africa")) %>% 
  mutate(Region = case_when(
    Region == "Eastern Africa" ~ "Eastern_Africa",
    Region == "Middle Africa" ~ "Middle_Africa",
    Region == "Southern Africa" ~ "Southern_Africa",
    TRUE ~ `Region`
  ))

```
 
##Static scatter plot using `ggplot2`##
We already know how to make scatter plots using `ggplot2`so lets build one really quickly so we can then compare it to the much cooler interactive scatter plot.

```r
(ggplot_scatter <- ggplot(elephant_clean, aes(x= year, y= abundance, colour = Region)) +
    geom_point(size = 3) +
    geom_line() +
    theme_classic() +
    labs(
      title = "Elephant abundance from 1970 to 2013",
      x = "Year",
      y = "Abundance"
    ))
```
<center> <img src="{{ site.baseurl }}/ggplot_scatter.png" alt="Img" style="width: 800px;"/> </center>


```r
ggsave("ggplot_scatter.png", ggplot_scatter,width=14,height=8,dpi=450)
```










At this point it would be a good idea to include an image of what the plot is meant to look like so students can check they've done it right. Replace `IMAGE_NAME.png` with your own image file:

<center> <img src="{{ site.baseurl }}/IMAGE_NAME.png" alt="Img" style="width: 800px;"/> </center>



More text, code and images.

This is the end of the tutorial. Summarise what the student has learned, possibly even with a list of learning outcomes. In this tutorial we learned:

##### - how to generate fake bivariate data
##### - how to create a scatterplot in ggplot2
##### - some of the different plot methods in ggplot2

We can also provide some useful links, include a contact form and a way to send feedback.

For more on `ggplot2`, read the official <a href="https://www.rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf" target="_blank">ggplot2 cheatsheet</a>.

Everything below this is footer material - text and links that appears at the end of all of your tutorials.

<hr>
<hr>

#### Check out our <a href="https://ourcodingclub.github.io/links/" target="_blank">Useful links</a> page where you can find loads of guides and cheatsheets.

#### If you have any questions about completing this tutorial, please contact us on ourcodingclub@gmail.com

#### <a href="INSERT_SURVEY_LINK" target="_blank">We would love to hear your feedback on the tutorial, whether you did it in the classroom or online!</a>

<ul class="social-icons">
	<li>
		<h3>
			<a href="https://twitter.com/our_codingclub" target="_blank">&nbsp;Follow our coding adventures on Twitter! <i class="fa fa-twitter"></i></a>
		</h3>
	</li>
</ul>

### &nbsp;&nbsp;Subscribe to our mailing list:
<div class="container">
	<div class="block">
        <!-- subscribe form start -->
		<div class="form-group">
			<form action="https://getsimpleform.com/messages?form_api_token=de1ba2f2f947822946fb6e835437ec78" method="post">
			<div class="form-group">
				<input type='text' class="form-control" name='Email' placeholder="Email" required/>
			</div>
			<div>
                        	<button class="btn btn-default" type='submit'>Subscribe</button>
                    	</div>
                	</form>
		</div>
	</div>
</div>

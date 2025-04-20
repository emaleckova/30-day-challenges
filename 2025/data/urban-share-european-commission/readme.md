# Share of people living in urban areas - Data package

This data package contains the data that powers the chart ["Share of people living in urban areas"](https://ourworldindata.org/grapher/urban-share-european-commission?v=1&csvType=full&useColumnShortNames=false) on the Our World in Data website.

## CSV Structure

The high level structure of the CSV file is that each row is an observation for an entity (usually a country or region) and a timepoint (usually a year).

The first two columns in the CSV file are "Entity" and "Code". "Entity" is the name of the entity (e.g. "United States"). "Code" is the OWID internal entity code that we use if the entity is a country or region. For normal countries, this is the same as the [iso alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3) code of the entity (e.g. "USA") - for non-standard countries like historical countries these are custom codes.

The third column is either "Year" or "Day". If the data is annual, this is "Year" and contains only the year as an integer. If the column is "Day", the column contains a date string in the form "YYYY-MM-DD".

The remaining columns are the data columns, each of which is a time series. If the CSV data is downloaded using the "full data" option, then each column corresponds to one time series below. If the CSV data is downloaded using the "only selected data visible in the chart" option then the data columns are transformed depending on the chart type and thus the association with the time series might not be as straightforward.

## Metadata.json structure

The .metadata.json file contains metadata about the data package. The "charts" key contains information to recreate the chart, like the title, subtitle etc.. The "columns" key contains information about each of the columns in the csv, like the unit, timespan covered, citation for the data etc..

## About the data

Our World in Data is almost never the original producer of the data - almost all of the data we use has been compiled by others. If you want to re-use data, it is your responsibility to ensure that you adhere to the sources' license and to credit them correctly. Please note that a single time series may have more than one source - e.g. when we stich together data from different time periods by different producers or when we calculate per capita metrics using population data from a second source.

### How we process data at Our World In Data
All data and visualizations on Our World in Data rely on data sourced from one or several original data providers. Preparing this original data involves several processing steps. Depending on the data, this can include standardizing country names and world region definitions, converting units, calculating derived indicators such as per capita measures, as well as adding or adapting metadata such as the name or the description given to an indicator.
[Read about our data pipeline](https://docs.owid.io/projects/etl/)

## Detailed information about each time series


## Share of population living in urban areas
The European Commission combines satellite imagery with national census data to identify [cities](#dod:cities-degurba), [towns](#dod:towns-degurba), and [villages](#dod:villages-degurba) and estimate their respective populations.
Last updated: October 14, 2024  
Next update: October 2025  
Date range: 1975–2020  
Unit: %  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
European Commission, Joint Research Centre (JRC) (2024) – with major processing by Our World in Data

#### Full citation
European Commission, Joint Research Centre (JRC) (2024) – with major processing by Our World in Data. “Share of population living in urban areas” [dataset]. European Commission, Joint Research Centre (JRC), “Global Human Settlement Layer Dataset” [original data].
Source: European Commission, Joint Research Centre (JRC) (2024) – with major processing by Our World In Data

### What you should know about this data
* **The Degree of Urbanisation (DEGURBA)**  is a method for capturing the urban-rural divide, designed for international comparisons. Developed by six organizations and endorsed by the UN, it uses a two-level classification.

The first level divides areas into cities, towns, and villages, distinguishing between urban (cities, towns, suburbs) and rural regions. The second level adds detail, splitting towns and villages further.

This classification is based on 1 km² grid cells, grouped into urban centers, urban clusters, and rural cells. These grids are then used to classify smaller areas, typically using residential population grids from censuses or registers. If detailed data isn't available, a disaggregation grid estimates population distribution.

To predict future urbanization (2025 and 2030), both static (land features) and dynamic (past satellite images) components are used to project growth. DEGURBA defines cities by population, not administrative borders, aligning with UN guidelines, though fixed thresholds may not always capture local differences.

### Source

#### European Commission, Joint Research Centre (JRC) – Global Human Settlement Layer Dataset
Retrieved on: 2024-10-14  
Retrieved from: https://data.jrc.ec.europa.eu/dataset/341c0608-5ca5-4ddb-b068-a412e35a3326  

#### Notes on our processing step for this indicator
The share of total area or population for each urbanization level was calculated by dividing the area or population of each level (cities, towns, villages) by the overall total, providing a percentage representation for each category.


## Projected share of population living in urban areas
The European Commission combines satellite imagery with national census data to identify [cities](#dod:cities-degurba), [towns](#dod:towns-degurba), and [villages](#dod:villages-degurba) and estimate their respective populations.
Last updated: October 14, 2024  
Next update: October 2025  
Date range: 2020–2030  
Unit: %  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
European Commission, Joint Research Centre (JRC) (2024) – with major processing by Our World in Data

#### Full citation
European Commission, Joint Research Centre (JRC) (2024) – with major processing by Our World in Data. “Projected share of population living in urban areas” [dataset]. European Commission, Joint Research Centre (JRC), “Global Human Settlement Layer Dataset” [original data].
Source: European Commission, Joint Research Centre (JRC) (2024) – with major processing by Our World In Data

### What you should know about this data
* **The Degree of Urbanisation (DEGURBA)**  is a method for capturing the urban-rural divide, designed for international comparisons. Developed by six organizations and endorsed by the UN, it uses a two-level classification.

The first level divides areas into cities, towns, and villages, distinguishing between urban (cities, towns, suburbs) and rural regions. The second level adds detail, splitting towns and villages further.

This classification is based on 1 km² grid cells, grouped into urban centers, urban clusters, and rural cells. These grids are then used to classify smaller areas, typically using residential population grids from censuses or registers. If detailed data isn't available, a disaggregation grid estimates population distribution.

To predict future urbanization (2025 and 2030), both static (land features) and dynamic (past satellite images) components are used to project growth. DEGURBA defines cities by population, not administrative borders, aligning with UN guidelines, though fixed thresholds may not always capture local differences.

### Source

#### European Commission, Joint Research Centre (JRC) – Global Human Settlement Layer Dataset
Retrieved on: 2024-10-14  
Retrieved from: https://data.jrc.ec.europa.eu/dataset/341c0608-5ca5-4ddb-b068-a412e35a3326  

#### Notes on our processing step for this indicator
The share of total area or population for each urbanization level was calculated by dividing the area or population of each level (cities, towns, villages) by the overall total, providing a percentage representation for each category.


    
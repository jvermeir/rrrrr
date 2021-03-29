# Title     : enzyme activity calculations
# Objective : script to calculate the (specific) activity of enzymes
# Created by: femke
# Created on: 07/02/2021

# (1) Load csv files: UV spectra and GCMS data                                  X
# read excel files into R                                                 > if needed
#library(readxl)
#ageandheight <- read_excel("ageandheight.xls", sheet = "Hoja2") #Upload the data
# (2) Take the time column and calculate the relative time in min               X
# (3) Take the NO column and calculate the relative NO production               X
# (4) Make a graph: time vs NO production                                       X
# (5) Calculate the slope of the graphs                                         X
# (6) Calculate the protein concentration present in the samples                X
# (7) Calculate the NO production per ug protein                                X
# (8) Calculate the total NO production                                         X
# (9) Calculate the relative NO production                                      X
# (10) Tidy the tables: remove all unnecessary columns and rename the columns   X
# (11) Export to excel                                                          > working on it > only graph needs to be exported
# place everything in functions and locate the input at bottom function         X
# end function: result <- function(input_filename, date_of_gcms, output_filename)

# set working directory

# remove all previously made vectors, dfs etc before starting new script
remove("gcms_data_plot")
remove("df_data")
remove("data")
remove("data_gather")

#install.packages("dplyr")
library(dplyr)
#install.packages("ggplot2")
library(ggplot2)
#install.packages("reshape2")
library(reshape2)
#install.packages("ggpmisc")
library(ggpmisc)
#install.packages("broom")
library(broom)
#install.packages("xlsx")
library(xlsx)
#install.packages("tidyr")
library(tidyr)
#install.packages("openxlsx")
#library(openxlsx)

# (1) load the files
preprocess_datafiles <- function(input_file) {
  df_data <- read.csv(input_file, sep=";")
  colnames(df_data) <- c("sample", "time", "NO", "nm260", "nm280", "dilution", "volume_gcms", "volume_total")
  df_data$sample <- gsub("_.*", "", df_data$sample)
  return(df_data)
}

# (6) calculate the protein concentration per sample and add total amount of protein in gcms samples and total volume from column
add_protein_concentrations <- function(df_data) {
  df_data$concentration <- with(df_data, (df_data$nm280 * 1.55 - df_data$nm260 * 0.76) * df_data$dilution)
  df_data$ug_protein_gcms <- df_data$concentration * df_data$volume_gcms
  df_data$ug_protein_total <- df_data$concentration * df_data$volume_total
  return(df_data)
}

# (2a) add column with time in minutes
add_time_in_min <- function(df_data, date_gcms_measurements) {
  df_data$time_in_min <- df_data$time
  df_data$time_in_min <- gsub(date_gcms_measurements, "", df_data$time_in_min)
  df_data$time_in_min <- gsub("PM", "", df_data$time_in_min)
  df_data$time_in_min <- unname(sapply(sub("\\s+min", "", sub(":", "* 60 +", df_data$time_in_min)),
                                       function(x) eval(parse(text=x))))
  return(df_data)
}

# (2b) (3) calculate the relative NO production and the relative time in minutes
add_relative_measurements <- function(df_data, parameter1, parameter2, newcolumn, column1, column2) {
  df_data <- df_data
  minimum_data <- df_data %>%
    group_by(sample) %>%
    slice(which.min({{parameter1}}))
  print(minimum_data)
  df_data <- merge(df_data, minimum_data[, c("sample", parameter2)], by="sample")
  df_data[[newcolumn]] <- df_data[[column1]] - df_data[[column2]]
  return(df_data)
}

# (4) (5) add the slope to the df
add_slopes <- function(df_data) {
  df_data_plot <- ggplot(df_data, aes(x=relative_time, y=relative_NO_production, color=sample, shape=sample)) +
    geom_point() +
    geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
    stat_poly_eq(formula = y ~ x,
                 aes(label = paste(..eq.label.., ..rr.label.., sep = "~")),
                 parse = TRUE) +
    theme_classic()
  png("df_data_plot.png")
  print(df_data_plot)
  dev.off()
  data <- sapply(split(df_data, df_data$sample), function(data)
    coef(lm(relative_NO_production ~ relative_time, data))) %>%
    as.data.frame(data)
  data_gather <- data %>%
    gather(key = sample, value = slope) %>%
    filter(row_number() %% 2 == 0)
  #print(data_gather)
  df_data <- df_data %>%
    left_join(select(data_gather, slope, sample), by = "sample")
  #print(gcms_data)
  return(df_data)
}

# (7) (8) (9) add the total and relative NO production
add_relative_and_total_NO_production <- function(df_data) {
  #df_data$specificity <- df_data$
  df_data$NO_min_ugprotein <-  df_data$slope / df_data$ug_protein_gcms
  df_data$relative_NO_min_ugprotein <- df_data$NO_min_ugprotein / df_data$NO_min_ugprotein[[1]]
  df_data$total_activity <- df_data$NO_min_ugprotein * df_data$ug_protein_total
  df_data$relative_activity <- df_data$total_activity / df_data$total_activity[[1]]
  return(df_data)
}

#(10) (11) tidy data and export everything to excel
#drop all unnecessary columns + rename and reorder the columns + make three tabels
export_to_excel <- function(df_data, output_file){
  df_data <- df_data %>%
    select (-c("NO.y", "time_in_min.y"))
  print(df_data)
  colnames(df_data) <- c("sample", "time", "NO production", "nm260", "nm280", "dilution", "volume gcms (ul)",
                         "volume total (ul)", "concentration (ug/ul)", "ug protein gcms", "ug protein total",
                         "time (min)", "relative NO production", "relative time (min)", "NO/min (slope)", "NO/min/ug protein",
                         "relative NO/min/ug protein", "total activity", "relative total acitvity"
  )
  wb <-createWorkbook(type="xlsx")
  sample_info <- df_data[c("sample", "nm260", "nm280", "dilution", "concentration (ug/ul)")]
  sheet <- createSheet(wb, sheetName = "sample info")
  addDataFrame(sample_info, sheet, startRow=1, startColumn=1)

  gcms_info <- df_data[c("sample", "time", "time (min)", "relative time (min)", "NO production",
                         "relative NO production")]
  sheet <- createSheet(wb, sheetName = "gcms info")
  addDataFrame(gcms_info, sheet, startRow=1, startColumn=1)

  analysis_info <- df_data[c("sample", "concentration (ug/ul)", "volume gcms (ul)", "ug protein gcms", "NO/min (slope)",
                             "NO/min/ug protein", "relative NO/min/ug protein", "volume total (ul)",
                             "ug protein total", "total activity", "relative total acitvity")]
  analysis_info <- analysis_info %>% distinct()
  sheet <- createSheet(wb, sheetName = "analysis info")
  addDataFrame(analysis_info, sheet, startRow=1, startColumn=1)
  print(analysis_info)

  sheet <-createSheet(wb, sheetName = "plot")
  addPicture("df_data_plot.png", sheet, scale = 1, startRow = 4,
             startColumn = 1)
  saveWorkbook(wb, output_file)
  file.remove("df_data_plot.png")
  return(output_file)
}

# (12) call all functions to create a plot and excelfile
enzyme_activity_calculations <- function(input_file, date_gcms_measurements, output_file){
  load_datafiles <- preprocess_datafiles(input_file)
  data_with_protein_concentration <- add_protein_concentrations(load_datafiles)
  data_with_time_in_min <- add_time_in_min(data_with_protein_concentration, date_gcms_measurements)
  data_with_relative_production <- add_relative_measurements(data_with_time_in_min, NO, "NO","relative_NO_production", "NO.x", "NO.y")
  data_with_relative_production_time <- add_relative_measurements(data_with_relative_production, time_in_min, "time_in_min", "relative_time","time_in_min.x", "time_in_min.y")
  data_with_production_per_min <- add_slopes(data_with_relative_production_time)
  data_with_relative_and_total_production <- add_relative_and_total_NO_production(data_with_production_per_min)
  export_data_to_excel <- export_to_excel(data_with_relative_and_total_production, output_file)
  return(export_data_to_excel)
}
enzyme_activity_calculations("test_gcms_data","05-02-21 ", "20210321_testerdietest2.xlsx")

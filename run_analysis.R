## Assignment 02
# 
# The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. 
#The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers 
#on a series of yes/no questions related to the project. You will be required to submit: 
#1) a tidy data set as described below, 
#2) a link to a Github repository with your script for performing the analysis, 
#and 3) a code book that describes the variables, the data, and any transformations or work 
#that you performed to clean up the data called CodeBook.md. You should also include a README.md 
#in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.
# 
# One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:
#   
#   http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
# 
# Here are the data for the project:
#   
#   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# 

# You should create one R script called run_analysis.R that does the following.

library(tidyverse)
library(dplyr)
library(ggplot2)
library(data.table)
library(lubridate)
library(reshape2)
library(readtext)
#install.packages('readtext')

setwd('/Users/yanli/Desktop/Johns Hopkins/Cleaning Data Assignment 04')
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
f <- "Dataset.zip"
download.file(url, destfile = 'dataset.zip')

list.files('UCI HAR Dataset',recursive=TRUE)        


# Merges the training and the test sets to create one data set. -------------------------------------------------------------------
path <- '/Users/yanli/Desktop/Johns Hopkins/Cleaning Data Assignment 04/UCI HAR Dataset'
subject_train <- fread(file.path( path,"train", "subject_train.txt"))
subject_test <- fread(file.path(path,"test", "subject_test.txt"))

x_train <- fread(file.path( path,"train", "X_train.txt"))
x_test <- fread(file.path(path,'test','X_test.txt'))
y_train <- fread(file.path( path,"train", "y_train.txt"))
y_test <- fread(file.path( path,"test", "y_test.txt"))

sub <- rbind(subject_train,subject_test)
setnames(sub, "V1", "subject")
x <- rbind(x_train,x_test)
y <- rbind(y_train,y_test)
setnames(y, "V1", "activityNum")
df_table <- cbind(sub,x)
df_table <- cbind(df_table,y)
setkey(df_table, subject, activityNum)

# Extracts only the measurements on the mean and standard deviation for each measurement.

features <- fread(file.path(path, "features.txt"))
head(features)
names(features) <- c("featureNum", "featureName")
head(features)
features <- features[grepl("mean\\(\\)|std\\(\\)", featureName)]
head(features)
class(features)
features$featureCode <- features[, paste0("V", featureNum)]
select <- c(key(df_table), features$featureCode)
df_table <- df_table[, select, with = FALSE]
head(df_table)
# Uses descriptive activity names to name the activities in the data set
df_activitylabels <- fread(file.path(path, "activity_labels.txt"))
setnames(df_activitylabels, names(df_activitylabels), c("activityNum", "activityName"))

# Appropriately labels the data set with descriptive variable names.
df_table2 <- merge(df_table, df_activitylabels, by = "activityNum", all.x = TRUE)
setkey(df_table2, subject, activityNum, activityName)
df_table3 <- data.table(melt(df_table2, key(df_table2), variable.name = "featureCode"))
df_table4 <- merge(df_table3, features[, list(featureNum, featureCode, featureName)], by = "featureCode", 
            all.x = TRUE)
# From the data set in step 4, creates a second, independent tidy data set with the average of
# each variable for each activity and each subject.

df_table4$activity <- factor(df_table4$activityName)
df_table4$feature <- factor(df_table4$featureName)

write.table(df_table4,'cleaned_data.txt',row.name=FALSE)

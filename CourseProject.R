##Getting and Cleaning Data Course Project

## Download the file:
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")


## Unzip downloaded data to directory
unzip(zipfile="./data/Dataset.zip",exdir="./data")

## Load the train tables:
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

## Load the test tables:
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

## Read the features vector into R:
features <- read.table('./data/UCI HAR Dataset/features.txt')

## Read the activity labels vector into R:
activityLabels = read.table('./data/UCI HAR Dataset/activity_labels.txt')

## Rename columns for train data:
colnames(x_train) <- features[,2]
colnames(y_train) <-"activityId"
colnames(subject_train) <- "subjectId"

## Rename columns for test data:
colnames(x_test) <- features[,2] 
colnames(y_test) <- "activityId"
colnames(subject_test) <- "subjectId"

colnames(activityLabels) <- c('activityId','activityType')

## Merge the training and test tables:
merged_train_Data <- cbind(y_train, subject_train, x_train)
merged_test_Data <- cbind(y_test, subject_test, x_test)
FinalMerge <- rbind(merged_train_Data, merged_test_Data)

## Extract only the mean and standard deviation for each measurement:

   ### Create logical vector for subset:
    columnNames <- colnames(FinalMerge)
    mean_and_std <- (grepl("activityId" , columnNames)
                    | grepl("subjectId" , columnNames)
                    | grepl("mean.." , columnNames)
                    | grepl("std.." , columnNames))

SubsetMeanSD <- FinalMerge[ , mean_and_std == TRUE]

## Label data set with descriptive variable names:

    ### Remove parentheses:
    names(SubsetMeanSD) <- gsub('\\(|\\)',"",names(SubsetMeanSD), perl = TRUE)
    ### Make variables more descriptive:
    names(SubsetMeanSD) <- gsub('^t',"Time",names(SubsetMeanSD))
    names(SubsetMeanSD) <- gsub('^f',"Frequency",names(SubsetMeanSD))
    names(SubsetMeanSD) <- gsub('Gyro',"Gyroscope",names(SubsetMeanSD))
    names(SubsetMeanSD) <- gsub('Mag',"Magnitude",names(SubsetMeanSD))
    names(SubsetMeanSD) <- gsub('Acc',"Accelerometer",names(SubsetMeanSD))
    names(SubsetMeanSD) <- gsub('BodyBody',"Body",names(SubsetMeanSD))

## Create an independent tidy data set with the average 
## of each variable for each activity and each subject.
library (plyr)
IndieSet <- aggregate(.~subjectId + activityId, SubsetMeanSD, mean)
IndieSet <- IndieSet[order(IndieSet$subjectId, IndieSet$activityId),]
write.table(IndieSet, file = "tidydata.txt", row.name = FALSE)

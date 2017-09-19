## Coursera Getting and Cleaning Data Project. September 18th, 2017. A.Derbak

# Load needed packages for tidying
require(tidyr)
require(stringr)
require(dplyr)
require(data.table)


# Get data and set working directory
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile = "wearable.zip")
setwd("~\\R\\UCI HAR Dataset")

# Get Features and activity labels

features <- fread("features.txt")
activity_labels <- fread("activity_labels.txt")

# Read in the Test sets - Do not need Inertial Folder!!
test_data <- read_table("test\\X_test.txt", col_names = FALSE)
test_label <- fread("test\\y_test.txt")
test_subject <- fread("test\\subject_test.txt")

# Name the columns
names(test_label) <- "activity"
names(test_subject) <- "subjectID"
test_data <- setnames(test_data, features$V2)


# Combine all Test data
test_all_data <- cbind(test_subject,test_label, test_data)



# Read in the Training sets
train_data <- read_table("train\\X_train.txt", col_names = FALSE)
train_label <- fread("train\\y_train.txt")
train_subject <- fread("train\\subject_train.txt")

# Name the columns
names(train_label) <- "activity"
names(train_subject) <- "subjectID"
train_data <- setnames(train_data, features$V2)

# Combine all Training data
train_all_data <- cbind(train_subject, train_label, train_data)



# Combine Training and Test data sets
total_data <- rbind(test_all_data,train_all_data)


# Extract only the measurements on the mean and standard deviation
# for each measurement.

# determine which columns contain "mean()" or "std()"
meanstdcols <- grepl("mean\\(\\)", names(total_data)) |
  grepl("std\\(\\)", names(total_data))

# ensure that we also keep the subjectID and activity columns
meanstdcols[1:2] <- TRUE

# remove unnecessary columns
total_data_selected <- total_data[,meanstdcols, with=FALSE]


#Get mean and StDev columns
col_id <- grep("mean|std", total_data_selected)
total_data_selected <- select(total_data_selected, col_id[1])


# Use descriptive activity names to name the activities in the data set.
# Appropriately label the data set with descriptive activity names.

# convert the activity column from integer to factor
total_data_selected$activity <- factor(total_data_selected$activity, labels=c("Walking",
                                                        "Walking Upstairs", "Walking Downstairs", "Sitting", "Standing", "Laying"))


# Creates an independent tidy data set with the AVG 
# of each variable for each activity and each subject.

# create the tidy data set
melted_data <- melt(total_data_selected, id=c("subjectID","activity"))
tidy_data <- dcast(melted_data, subjectID+activity ~ variable, mean)

# write the tidy data set to a file
write.txt(tidy_data, "tidy.txt", row.names=FALSE)

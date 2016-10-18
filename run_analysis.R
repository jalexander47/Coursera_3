## Create file directory and download data

if ( ! file.exists ( " ./coursera3 ")) { dir.create ( "./coursera3" )}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if ( ! file.exists ( " ./coursera3/data.zip" )) {download.file ( fileUrl, destfile = "./coursera3/data.zip" )}

## unzip and make a list of files from data

unzip ( zipfile = "./coursera3/data.zip", exdir = "./coursera3" )


if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

## Load: activity labels
labels <- read.table("./coursera3/UCI HAR Dataset/activity_labels.txt")[,2]

## Load: data column names
features <- read.table("./coursera3/UCI HAR Dataset/features.txt")[,2]

## Extract mean and standard deviation
extract_features <- grepl("mean|std", features)

## Load x and y test data
X_test <- read.table("./coursera3/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./coursera3/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./coursera3/UCI HAR Dataset/test/subject_test.txt")

names(X_test) = features

## Extract only the measurements on the mean and standard deviation for each measurement.
X_test = X_test[,extract_features]

## Load activity labels
y_test[,2] = labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

## Bind data together
data_test <- cbind(as.data.table(subject_test), y_test, X_test)

## Load and process train_x & train_y data.
train_x <- read.table("./coursera3/UCI HAR Dataset/train/X_train.txt")
train_y <- read.table("./coursera3/UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./coursera3/UCI HAR Dataset/train/subject_train.txt")

names(train_x) = features

## Extract mean and standard deviation for each.
train_x = train_x[,extract_features]

## Load activity data
train_y[,2] = labels[train_y[,1]]
names(train_y) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

## Combine data
data_tr <- cbind(as.data.table(subject_train), train_y, train_x)

## Combine train and test
data = rbind(data_test, data_tr)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

## Apply mean function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)


write.table(tidy_data, file = "./tidy_data.txt",  row.name=FALSE)
library(ggplot2)
library(dplyr)
library(tidyr)
library(janitor)

responses <- read.csv('responses.csv')

#do we have the correct numbers?
nrow(responses)
nrow(subset(responses, ID==1))
nrow(subset(responses, ID==0))

#did the ost work?
nrow(subset(responses, OST_worked==0))

#create column that says if the response is correct
responses$updown_correct <- NA
responses[responses$pert_magnitude > 0 & responses$updown_response == 1,]$updown_correct <- TRUE
responses[responses$pert_magnitude < 0 & responses$updown_response == 0,]$updown_correct <- TRUE
responses[responses$pert_magnitude > 0 & responses$updown_response == 0,]$updown_correct <- FALSE
responses[responses$pert_magnitude < 0 & responses$updown_response == 1,]$updown_correct <- FALSE

#are they correct?
nrow(subset(responses, updown_correct == TRUE))
nrow(subset(responses, updown_correct == FALSE))
# -> more correct than not

#correct responses by perturbation magnitude
updown_agg <- aggregate(updown_correct ~ pert_magnitude, data=responses, FUN="sum")
updown_agg$pert_magnitude <- factor(updown_agg$pert_magnitude)
levels(updown_agg$pert_magnitude)


ggplot(data=updown_agg, aes(x=pert_magnitude, y=updown_correct)) +
  geom_col(stat="identity") +
  ggtitle('Correct responses by magnitude of perturbation (max 40)') +
  xlab('magnitude of perturbation') +
  ylab('correct answers') +
  theme_classic()

#count confidence responses
by_confidence <- responses %>% group_by(how_noticeable_response)
by_confidence <- by_confidence %>% summarise(n = n())

ggplot(data=by_confidence, aes(x=how_noticeable_response, y=n)) +
  geom_col(stat="identity") +
  ggtitle('How likely are participants to answer 0,1,2 or 3') +
  xlab('confidence rating') +
  ylab('number of answers') +
  theme_classic()

#correct responses by confidence rating

tabyl(responses, how_noticeable_response, updown_correct)

tabyl(responses, how_noticeable_response, updown_correct) %>%
  adorn_percentages("row") %>%
  adorn_pct_formatting(digits = 1)

confidence_agg <- tabyl(responses, how_noticeable_response, updown_correct) %>% adorn_percentages("row")
confidence_agg <- rename(confidence_agg,  correct_responses = 'TRUE')
confidence_agg <- rename(confidence_agg,  incorrect_responses = 'FALSE')
confidence_agg <- rename(confidence_agg,  no_perturbation = NA_)

confidence_agg <- pivot_longer(confidence_agg, cols = c(correct_responses, incorrect_responses, no_perturbation), names_to='category')

ggplot(confidence_agg, aes(x=how_noticeable_response, y = value)) + 
  geom_bar(stat="identity", aes(fill=category)) +
  ggtitle('Percentage correct by confidence rating') +
  xlab('confidence rating') +
  ylab('percentage correct') +
  theme_classic()


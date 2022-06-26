library("stringr")

questionnaire_table = read.table("data/Questionnaire.csv", header=TRUE, sep=",")

age = questionnaire_table[,2]
gender = questionnaire_table[,3]
language = lapply(questionnaire_table[,4], tolower)
language = str_replace(language, "deutsch", "german")

personality = c()
extraversion_score = c()
questionnaire_table[,14]

for (i in 1:nrow(questionnaire_table)) {
 score = 0
 if(toString(questionnaire_table[i,5]) == "Active") {
  score = score+1
 }
 if(toString(questionnaire_table[i,6]) == "Sociable") {
  score = score+1
 }
 if(toString(questionnaire_table[i,7]) == "Having many friends") {
  score = score+1
 }
 if(toString(questionnaire_table[i,8]) == "Like parties") {
  score = score+1
 }
 if(toString(questionnaire_table[i,9]) == "Energised by others") {
  score = score+1
 }
 if(toString(questionnaire_table[i,10])== "Happier working in groups") {
  score = score+1
 }
 if(toString(questionnaire_table[i,11]) == "Socially involved") {
  score = score+1
 }
 if(toString(questionnaire_table[i,12]) == "Talkative") {
  score = score+1
 }
 if(toString(questionnaire_table[i,13]) == "An extravert") {
  score = score+1
 }
 if(toString(questionnaire_table[i,14]) == "Speak before thinking") {
  score = score+1
 }
 if (score<=5) {
  personality = c(personality, "introvert")
 } else if (score>5){
  personality = c(personality, "extravert")
 } else {
  personality = c(personality, " ")
 }
 extraversion_score = c(extraversion_score, score)
}

personality_df = data.frame(questionnaire_table$Zeitstempel, age, gender, language, personality, extraversion_score)
colnames(personality_df)[1] = "timestamp"
personality_df = personality_df[order(personality_df$timestamp),]

f0_table = read.table("wav_audios/f0.csv", header=TRUE, sep=",")
f0_table = f0_table[order(f0_table$timestamp),]

avg_f0 = c()

for(i in seq(1, nrow(f0_table)-1, by=2)) {
 f0 = (f0_table[i,2] + f0_table[i+1,2])/2
 avg_f0 = c(avg_f0, f0)
}

merged_df = personality_df
merged_df['avg_f0'] = avg_f0

write.csv(merged_df,"data/all_data.csv", row.names = FALSE)

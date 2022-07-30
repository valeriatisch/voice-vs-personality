library(stringr)

personality_df = NULL

questionnaire_table = read.table("data/Questionnaire.csv", header=TRUE, sep=",")

gender = questionnaire_table[,12]
language = lapply(questionnaire_table[,13], tolower)
language = str_replace(language, "deutsch", "german")
age = questionnaire_table[,14]

personality = c()
extraversion_score = c()

for (i in 1:nrow(questionnaire_table)) {
 score = 0
 if(toString(questionnaire_table[i,2]) == "Active") {
  score = score+1
 }
 if(toString(questionnaire_table[i,3]) == "Sociable") {
  score = score+1
 }
 if(toString(questionnaire_table[i,4]) == "Having many friends") {
  score = score+1
 }
 if(toString(questionnaire_table[i,5]) == "Like parties") {
  score = score+1
 }
 if(toString(questionnaire_table[i,6]) == "Energised by others") {
  score = score+1
 }
 if(toString(questionnaire_table[i,7])== "Happier working in groups") {
  score = score+1
 }
 if(toString(questionnaire_table[i,8]) == "Socially involved") {
  score = score+1
 }
 if(toString(questionnaire_table[i,9]) == "Talkative") {
  score = score+1
 }
 if(toString(questionnaire_table[i,10]) == "An extravert") {
  score = score+1
 }
 if(toString(questionnaire_table[i,11]) == "Speak before thinking") {
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
personality_df$timestamp = format(strptime(personality_df$timestamp, "%d-%m-%Y %H:%M:%S", tz="UTC"), "%y/%m/%d %I:%M:%S %p OEZ")
personality_df = personality_df[order(personality_df$timestamp),]

f0_table = read.table("wav_audios/f0.csv", header=TRUE, sep=",")
f0_table = f0_table[order(f0_table$timestamp),]
f0_table$index <- 1:nrow(f0_table)

# SFF
audio1_f0 = c()
for(i in seq(1, nrow(f0_table)-1, by=2)) {
 audio = f0_table[i,6]
 audio1_f0 = c(audio1_f0, audio)
}

audio2_f0 = c()
for(i in seq(2, nrow(f0_table), by=2)) {
 audio = f0_table[i,6]
 audio2_f0 = c(audio2_f0, audio)
}

# SD OF F0
avg_sd_f0 = c()
for(i in seq(1, nrow(f0_table)-1, by=2)) {
 sd_f0 = (f0_table[i,7] + f0_table[i+1,7])/2
 avg_sd_f0 = c(avg_sd_f0, sd_f0)
}

audio1_loudness = c()
for(i in seq(1, nrow(f0_table)-1, by=2)) {
 audio = f0_table[i,9]
 audio1_loudness = c(audio1_loudness, audio)
}

audio2_loudness = c()
for(i in seq(2, nrow(f0_table), by=2)) {
 audio = f0_table[i,9]
 audio2_loudness = c(audio2_loudness, audio)
}

audio1_duration = c()
for(i in seq(1, nrow(f0_table)-1, by=2)) {
 audio = f0_table[i,2]
 audio1_duration = c(audio1_duration, audio)
}

audio2_duration = c()
for(i in seq(2, nrow(f0_table), by=2)) {
 audio = f0_table[i,2]
 audio2_duration = c(audio2_duration, audio)
}

reading_duration1 = c()
for(i in seq(1, nrow(f0_table)-1, by=2)) {
 audio = f0_table[i,3]
 reading_duration1 = c(reading_duration1, audio)
}

reading_duration2 = c()
for(i in seq(2, nrow(f0_table), by=2)) {
 audio = f0_table[i,3]
 reading_duration2 = c(reading_duration2, audio)
}

voiced1_duration = c()
for(i in seq(1, nrow(f0_table)-1, by=2)) {
 audio = f0_table[i,4]
 voiced1_duration = c(voiced1_duration, audio)
}

voiced2_duration = c()
for(i in seq(2, nrow(f0_table), by=2)) {
 audio = f0_table[i,4]
 voiced2_duration = c(voiced2_duration, audio)
}

unvoiced1_duration = c()
for(i in seq(1, nrow(f0_table)-1, by=2)) {
 audio = f0_table[i,5]
 unvoiced1_duration = c(unvoiced1_duration, audio)
}

unvoiced2_duration = c()
for(i in seq(2, nrow(f0_table), by=2)) {
 audio = f0_table[i,5]
 unvoiced2_duration = c(unvoiced2_duration, audio)
}

personality_df$audio1_f0 = audio1_f0
personality_df$audio2_f0 = audio2_f0
personality_df$avg_f0 = (personality_df$audio1_f0 + personality_df$audio2_f0)/2

sd_f0s = c()
for(i in seq(1, nrow(personality_df))) {
 s = sd(c(personality_df[i,7], personality_df[i,8]))
 sd_f0s = c(sd_f0s, s)
}

personality_df$sd_f0s = sd_f0s
personality_df$avg_sd_f0 = avg_sd_f0
personality_df$audio1_loudness = audio1_loudness
personality_df$audio2_loudness = audio2_loudness

sd_loudness = c()
for(i in seq(1, nrow(personality_df))) {
 s = sd(c(personality_df[i,12], personality_df[i,13]))
 sd_loudness = c(sd_loudness, s)
}

personality_df$sd_loudness = sd_loudness
personality_df$audio1_duration = audio1_duration
personality_df$voiced1_duration = voiced1_duration
personality_df$unvoiced1_duration = unvoiced1_duration
personality_df$audio2_duration = audio2_duration
personality_df$voiced2_duration = voiced2_duration
personality_df$unvoiced2_duration = unvoiced2_duration

personality_df$avg_voiced_duration = (personality_df$voiced1_duration + personality_df$voiced2_duration)/2
personality_df$avg_loudness = (personality_df$audio1_loudness + personality_df$audio2_loudness)/2

personality_df$reading_duration1 = reading_duration1
personality_df$reading_duration2 = reading_duration2

personality_df$avg_read_duration = (personality_df$reading_duration1 + personality_df$reading_duration2)/2

sd_read = c()
for(i in seq(1, nrow(personality_df))) {
 s = sd(c(personality_df[i,23], personality_df[i,24]))
 sd_read = c(sd_read, s)
}

personality_df$pauses_duration1 = personality_df$reading_duration1 - personality_df$voiced1_duration
personality_df$pauses_duration2 = personality_df$reading_duration2 - personality_df$voiced2_duration
personality_df$avg_pauses_duration = (personality_df$pauses_duration1 + personality_df$pauses_duration2)/2

write.csv(personality_df,"data/voice_data.csv", row.names = FALSE)


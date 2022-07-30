# Voice versus Personality
When we hear someone’s voice for the first time, chances are there is already an idea taking shape in our heads about what type of person they are. Research shows there might be some links between the sound of someone’s voice and their personality. We investigated whether extraverted people have a lower voice pitch, a louder voice and whether they read faster than introverted people do.

We collected audio recordings of our participants reading out loud a fairytale and asked them to fill in a questionnaire to estimate their personality type.

If you are interested in our process and results, you can take a look at our [presentation](https://valeriatisch.github.io/voice-vs-personality/presentation.html#1) or read our [report](https://valeriatisch.github.io/voice-vs-personality/report.pdf).

This was a course project in _“Statistics in Connected Healthcare”_ at the Hasso-Plattner Institute in 2022.

## [Code](https://github.com/valeriatisch/voice-vs-personality/tree/main/code)
The audio analysis is done with the script [audioAnalyzer.py](https://github.com/valeriatisch/voice-vs-personality/blob/main/code/audioAnalyzer.py). Please install all [requirements](https://github.com/valeriatisch/voice-vs-personality/blob/main/code/requirements.txt) before executing.

For a given audio recording in WAV format lying in the _wav_audios/_ directory, the script will:
1. generate an amplitude plot and save it under _wav_audios/plots/_,
2. extract the voiced speech and save it as a new wav file under _wav_audios/extracted/_,
3. retrieve the speaking fundamental frequency SFF of the speech audio, its duration and the standard deviation of the fundamental frequency f0,
4. generate a spectrogram figure of the fundamental frequency of the speech and save it under _wav_audios/plots/_,
5. measure the loudness of the complete audio as well as of its voiced speech part in db LUFS,
6. measure the reading duration without the leading and trailing silence in the audio,
7. write all found data to _wav_audios/f0.csv_ as a line.

All data is summarised with the script [data-analysis.R](https://github.com/valeriatisch/voice-vs-personality/blob/main/code/data-analysis.R). It analyses the answers to the questionnaire regarding the personality type, calculates the extraversion score of someone and classifies them as an introvert or extravert.

## [Examples](https://github.com/valeriatisch/voice-vs-personality/tree/main/examples)
You can find exemplary recordings used in the presentation in [examples/](https://github.com/valeriatisch/voice-vs-personality/tree/main/examples). 

## [Data](https://github.com/valeriatisch/voice-vs-personality/tree/main/data)
We will not publish the actual recordings due to privacy reasons but all obtained data.

[Here](https://github.com/valeriatisch/voice-vs-personality/blob/main/data/Questionnaire.csv) you can find the answers to the questionnaire.

[Here](https://github.com/valeriatisch/voice-vs-personality/blob/main/data/voice_data.csv) you can find the features we retrieved from the audio recordings like the SFF, loudness, duration etc.

import os
import librosa.display

import librosa as lr
import numpy as np
import soundfile as sf
import pyloudnorm as pyln
import matplotlib.pyplot as plt

from datetime import datetime as dt
from scipy.io.wavfile import read


class AudioAnalyzer:

    # generates an amplitude plot of the given wav file and saves it under wav_audios/plots
    def generate_plot(self, wav_file):
        split_fn = wav_file.split("_")
        if split_fn[0] == "extracted":
            sr, data = read(f"wav_audios/extracted/{wav_file}")
        else:
            sr, data = read(f"wav_audios/{wav_file}")

        duration = len(data) / sr

        try:
            time = np.arange(0, duration, 1 / sr)
            plt.plot(time, data)
            plt.xlabel("Time [s]")
            plt.ylabel("Amplitude")
            plt.title("Speech record")
            if split_fn[0] == "extracted":
                plt.title("Extracted speech record")
            plt.savefig(f"wav_audios/plots/{wav_file[:-4]}.png")
            plt.show()
        except Exception as e:
            print(e)

    # unions two lists
    def lst_union(self, lst1, lst2):
        for i in lst2:
            lst1.append(i)
        return lst1

    # extracts speech from wav file and saves it as a new wav file under wav_audios/extracted/
    # returns duration of the whole audio
    def extract_speech(self, wav_file):
        y, sr = lr.load(f"wav_audios/{wav_file}")
        whole_duration = lr.get_duration(y=y, sr=sr)
        clips = lr.effects.split(y, top_db=10)

        wav_data = []
        for c in clips:
            data = y[c[0]: c[1]]
            wav_data.extend(data)

        sf.write(f"wav_audios/extracted/extracted_{wav_file}", wav_data, sr)

        return whole_duration

    # retrieves the fundamental frequency f0 of the audio
    # returns duration of the voiced part of an audio, the average f0 and the standard deviation of f0
    def compute_f0(self, wav_file):
        y, sr = lr.load(f"wav_audios/extracted/extracted_{wav_file}")
        speech_duration = lr.get_duration(y=y, sr=sr)
        f0 = lr.yin(y, fmin=lr.note_to_hz('C2'), fmax=lr.note_to_hz('C7'), sr=sr)
        f = []
        for i in f0:
            if 40 < i < 400:
                f.append(i)
        standard_deviation = np.std(f)
        avg_f0 = sum(f) / len(f)

        return speech_duration, avg_f0, standard_deviation

    # removes silence at the beginning and end of audio and returns its duration
    def get_duration(self, wav_file):
        y, sr = lr.load(f"wav_audios/{wav_file}")
        yt, index = lr.effects.trim(y, top_db=10)
        return lr.get_duration(yt)

    # generates a spectogram figure of the fundamental frequency of the voiced audio part
    # and saves it under wav_audios/plots/
    def f0_spectrogram(self, wav_file):
        y, sr = lr.load(f"wav_audios/extracted/extracted_{wav_file}")
        f0, voiced_flag, voiced_probs = lr.pyin(y, fmin=lr.note_to_hz('C2'), fmax=lr.note_to_hz('C7'))
        times = lr.times_like(f0)
        d = lr.amplitude_to_db(np.abs(lr.stft(y)), ref=np.max)
        fig, ax = plt.subplots()
        img = lr.display.specshow(d, x_axis='time', y_axis='log', ax=ax)
        ax.set(title='pYIN fundamental frequency estimation')
        fig.colorbar(img, ax=ax, format="%+2.f dB")
        ax.plot(times, f0, label='f0', color='cyan', linewidth=3)
        ax.legend(loc='upper right')
        fig.savefig(f"wav_audios/plots/extracted_{wav_file[:-4]}_spectrogram.png")
        fig.show()

    # returns loudness of the whole audio and of its voiced part
    def get_loudness(self, wav_file):
        data, rate = sf.read(f"wav_audios/{wav_file}")
        meter = pyln.Meter(rate)
        whole_loudness = meter.integrated_loudness(data)
        data, rate = sf.read(f"wav_audios/extracted/extracted_{wav_file}")
        meter = pyln.Meter(rate)
        voiced_loudness = meter.integrated_loudness(data)
        return whole_loudness, voiced_loudness

    # writes all retrieved data into f0.csv as a line
    def write_to_csv(self, wav_file, whole_duration, reading_duration, speech_duration, avg_f0, sd_f0, whole_loudness, voiced_loudness):
        timestamp = dt.strptime(wav_file[:-4], "%Y-%m-%d %H.%M.%S")
        timestamp = dt.strftime(timestamp, "%y/%m/%d %I:%M:%S %p OEZ")

        with open('wav_audios/f0.csv', 'a') as fd:
            fd.write(f"{timestamp},{whole_duration},{reading_duration},{speech_duration},{whole_duration - speech_duration},"
                     f"{avg_f0},{sd_f0},{whole_loudness},{voiced_loudness}\n")
            fd.close()

    def do_everything(self, wav_file):
        self.generate_plot(wav_file)
        whole_duration = self.extract_speech(wav_file)
        self.generate_plot(f"extracted_{wav_file}")
        speech_duration, avg_f0, standard_deviation = self.compute_f0(wav_file)
        whole_loudness, voiced_loudness = self.get_loudness(wav_file)
        reading_duration = self.get_duration(wav_file)
        self.write_to_csv(wav_file, whole_duration, reading_duration, speech_duration, avg_f0, standard_deviation,
                          whole_loudness, voiced_loudness)


audioAnal = AudioAnalyzer()

# run all methods for each file lying in the wav_audios/ directory
count = 0
for filename in os.listdir("wav_audios"):
    if filename[-3:] == 'wav':
        print(count)
        audioAnal.do_everything(filename)
        count += 1

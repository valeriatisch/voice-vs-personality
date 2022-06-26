import os
import librosa.display

import librosa as lr
import numpy as np
import soundfile as sf
import matplotlib.pyplot as plt

from datetime import datetime as dt
from scipy.io.wavfile import read


class AudioAnalyzer:

    def generate_plot(self, wav_file):
        split_fn = wav_file.split("_")
        if split_fn[0] == "extracted":
            sr, data = read(f"wav_audios/extracted/{wav_file}")
        else:
            sr, data = read(f"wav_audios/{wav_file}")

        duration = len(data)/sr

        try:
            time = np.arange(0, duration, 1/sr)
            plt.plot(time, data)
            plt.xlabel("Time [s]")
            plt.ylabel("Amplitude")
            plt.title("Speech record")
            if split_fn[0] == "extracted":
                plt.title("Extracted speech record")
            plt.savefig(f"wav_audios/plots/{wav_file}.png")
        except Exception as e:
            print(e)

    def lst_union(self, lst1, lst2):
        for i in lst2:
            lst1.append(i)
        return lst1

    def extract_speech(self, wav_file):
        y, sr = lr.load(f"wav_audios/{wav_file}")
        clips = lr.effects.split(y, top_db=10)

        wav_data = []
        for c in clips:
            data = y[c[0]: c[1]]
            wav_data.extend(data)
        sf.write(f"wav_audios/extracted/extracted_{wav_file}", wav_data, sr)

    def compute_f0(self, wav_file):
        y, sr = lr.load(f"wav_audios/extracted/extracted_{wav_file}")
        f0 = lr.yin(y, fmin=lr.note_to_hz('C2'), fmax=lr.note_to_hz('C7'), sr=sr)
        f = []
        for i in f0:
            if 40 < i < 400:
                f.append(i)
        avg_f0 = sum(f) / len(f)
        timestamp = dt.strptime(wav_file[:-4], "%Y-%m-%d %H.%M.%S")
        timestamp = dt.strftime(timestamp, "%y/%m/%d %I:%M:%S %p OEZ")
        with open('wav_audios/f0.csv', 'a') as fd:
            fd.write(f"{timestamp}, {avg_f0}\n")
            fd.close()

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
        fig.savefig(f"wav_audios/plots/extracted_{wav_file}_spectrogram.png")

    def do_everything(self, wav_file):
        self.generate_plot(wav_file)
        self.extract_speech(wav_file)
        self.compute_f0(wav_file)
        self.generate_plot(f"extracted_{wav_file}")


audioAnal = AudioAnalyzer()

for filename in os.listdir("wav_audios"):
    if filename[:1] == '2':
        audioAnal.do_everything(filename)

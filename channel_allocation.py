from scanner import Scanner
from spectrum_file import SpectrumFileReader
import numpy as np
import sys
import os
import _pickle as cPickle
import pandas as pd


class ChannelAllocation:
    max_per_freq = {}

    # min freq, max freq (inclusive), ch spacing
    # we will render +/- 10 MHz
    bands = [
        (2412, 2472, 5),  # 2.4 GHz
        (5180, 5240, 20),  # U-NII-1
        (5260, 5320, 20),  # U-NII-2
        (5500, 5580, 20),  # U-NII-2e-a
        (5600, 5700, 20),  # U-NII-2e-b
        (5745, 5825, 20),  # U-NII-3
    ]
    band_idx = 0
    scanners = []
    power_min = -110.0
    power_max = -20.0
    lastframe = 0

    fps = [0] * 10
    fpsi = 0

    freq_min = None
    freq_max = None
    last_x = None

    def set_band(self, band_idx):
        band = self.bands[band_idx]
        self.freq_min = band[0] - 10.0
        self.freq_max = band[1] + 10.0
        self.last_x = self.freq_max
        self.band_idx = band_idx
        for scanner in self.scanners:
            scanner.set_freqs(*band)

    def __init__(self, ifaces):
        self.scanners = []
        idx = 0
        for iface in ifaces:
            scanner = Scanner(iface, idx=idx)
            scanner.mode_chanscan()
            fn = '%s/spectral_scan0' % scanner.get_debugfs_dir()
            reader = SpectrumFileReader(fn)
            scanner.file_reader = reader
            self.scanners.append(scanner)
            idx += 1
        self.dev_idx = 0
        if not os.path.exists("./spectral_data"):
            os.mkdir("./spectral_data")

        # self.ctl_file = '%s/spectral_scan_ctl' % self.debugfs_dir
        self.set_band(self.band_idx)
        self.dump_to_file = False
        self.dump_file = None
        self.bg_sample_count = 0
        self.bg_sample_count_limit = 500

    def cleanup(self):
        for scanner in self.scanners:
            scanner.stop()
            scanner.file_reader.stop()

    def write_data(self, fname, content):
        content.to_csv(fname, index=False, header=False)

    def get_data(self):

        for scanner in self.scanners:
            if scanner.file_reader.sample_queue.empty():
                continue

            current_cf = self.bands[0][0]
            count = scanner.sample_count
            while not scanner.file_reader.sample_queue.empty():
                ts, xydata = scanner.file_reader.sample_queue.get()
                if self.dump_to_file:
                    cPickle.dump((scanner.idx, ts, xydata), self.dump_file)

                for (tsf, freq_cf, noise, rssi, pwr) in SpectrumFileReader.decode(xydata):
                    print('centre frequency: {}'.format(scanner.freq_to_chan(int(freq_cf))))
                    sc_pwr = []
                    if count < scanner.sample_count and current_cf == freq_cf:
                        for freq_sc, sigval in sorted(pwr.items()):
                            sc_pwr.append(sigval)
                        s = pd.Series(sc_pwr, index=df.columns)
                        df = df.append(s, ignore_index=True)
                    else:
                        count = scanner.sample_count
                        for freq_sc, sigval in sorted(pwr.items()):
                            sc_pwr.append(sigval)
                        df = pd.DataFrame(sc_pwr).T
                    count -= 1
                    current_cf = freq_cf
                self.write_data("./spectral_data/" + str(current_cf) + ".csv", df)

    def get_entropy(self, data):
        # https://www.hdm-stuttgart.de/~maucher/Python/MMCodecs/html/basicFunctions.html
        entropy = []
        for row_data in data.itertuples():
            items = len(row_data)
            sym_set = list(set(row_data))
            prop = [np.size(row_data[row_data == i]) / (1.0 * items) for i in sym_set]
            entr = np.sum([p * np.log2(1.0 / p) for p in prop])
            entropy.append(entr)
        return entropy

    def main(self):
        # for scanner in self.scanners:
        #     scanner.start()   # launches scanner (scanner.scan) in the threadself.cleanup()
        #     self.get_data()
        # self.cleanup()
        captures = sorted([f for f in os.listdir('./spectral_data')])
        for ch in captures:
            dtframe = pd.read_csv("spectral_data/"+str(ch), header=None)
            entr = self.get_entropy(dtframe)
            print("channel {0}: {1:5.2f}".format(ch, np.mean(entr)))
        self.cleanup()


if __name__ == '__main__':
    if len(sys.argv) == 1:
        print("\nUsage: \n  $ sudo python channel_alloc.py wlanX [wlanY] [wlanZ] [wlanA]\n")
        exit(0)
    ChannelAllocation(sys.argv[1:]).main()


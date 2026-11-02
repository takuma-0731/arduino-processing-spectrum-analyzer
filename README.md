# Arduino × Processing スペクトラムアナライザ

音楽の周波数成分をリアルタイムに表示するスペクトラムアナライザです。FFTの計算をArduino、描画をProcessingに分担させています（2年後期の演習）。

## 仕組み
- Processing（Minim）で音声を再生し、波形データをArduinoに送る
- ArduinoがarduinoFFTでFFTを行い、16バンドの音圧を返す
- Processingが受け取った値を、LEDセグメント風のバーとdB値で描画する。色は音圧に応じてHSB色空間で緑→黄→赤に変化する

## 工夫した点
- FFTのサンプル数を128にするとArduinoのシリアル受信バッファ（64バイト）を超えて止まったため、64に減らした
- Processing側から一定のフレームごとにデータを送る方式にして、互いの応答待ちで止まる状態を防いだ

## ファイル
| ファイル | 内容 |
|---|---|
| `arduino/fft_analyzer.ino` | 受信した波形のFFT解析と結果の返送 |
| `processing/spectrum_view.pde` | 音声の再生、送受信、描画 |
| `serial_test/` | シリアル通信の動作確認用 |
| `tools/plot.py` | グラフ作成用 |

## 使用技術
- Arduino（C/C++）、Processing（Java）、Python
- arduinoFFT、Minim、processing.serial、NumPy、Matplotlib

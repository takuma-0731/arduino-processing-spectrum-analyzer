import processing.serial.*;
import ddf.minim.*;

Serial port;

Minim minim;
AudioPlayer player;
int audioBufferSize = 2048;

int sampleRate = 7350;
int samplesPerPacket = 128;

final int IN_BYTES = samplesPerPacket * 2;
byte[] tx = new byte[IN_BYTES];

float phase = 0.0;

int numBands = 16;
float[] bandValues = new float[numBands];

int graphX = 60;
int graphY = 60;
int graphWidth = 1100;
int graphHeight = 400;

float minDB = -60;
float maxDB = 40;

void setup() {
  pixelDensity(2);
  size(1200, 500);

  minim = new Minim(this);

  // ★音源を選ぶダイアログ
  selectInput("音楽ファイル（wav/mp3）を選んでください", "fileSelected");

  // --- シリアルは今まで通り ---
  println("=== 利用可能なシリアルポート ===");
  for (int i = 0; i < Serial.list().length; i++) println("[" + i + "] " + Serial.list()[i]);
  if (Serial.list().length == 0) exit();

  String portName = Serial.list()[2];
  port = new Serial(this, portName, 115200);
  port.clear();
  port.buffer(numBands * 2);

  for (int i = 0; i < numBands; i++) bandValues[i] = minDB;
}

// ★ファイル選択後に呼ばれる
void fileSelected(File selection) {
  if (selection == null) {
    println("ファイル選択がキャンセルされました");
    return;
  }
  println("選択: " + selection.getAbsolutePath());

  if (player != null) player.close();

  player = minim.loadFile(selection.getAbsolutePath(), audioBufferSize);
  if (player == null) {
    println("Minimがファイルを開けませんでした");
    return;
  }
  player.play();
}

void draw() {
  background(30);
  fill(255);
  textSize(20);
  textAlign(LEFT);
  text("FFT Spectrum Analyzer", 20, 30);

  // playerが未準備なら送信しない（NPE防止）
  if (player != null && player.isPlaying()) {
    sendSamplesToArduino();
  }

  drawSpectrum();
  drawFrequencyLabels();
  drawVerticalAxisLabels();
}

void sendSamplesToArduino() {
  if (port == null || player == null) return;

  float srcRate = player.sampleRate();
  float step = srcRate / (float)sampleRate;

  for (int i = 0; i < samplesPerPacket; i++) {
    int idx = (int)phase;
    idx = constrain(idx, 0, player.bufferSize() - 1);

    float s = player.mix.get(idx);
    s = constrain(s, -1.0, 1.0);

    int v = (int)round(s * 32767.0);
    if (v < -32768) v = -32768;
    if (v >  32767) v =  32767;

    tx[i*2 + 0] = (byte)(v & 0xFF);
    tx[i*2 + 1] = (byte)((v >> 8) & 0xFF);

    phase += step;
    if (phase >= player.bufferSize()) phase -= player.bufferSize();
  }

  port.write(tx);
}

void serialEvent(Serial p) {
  byte[] inBuf = p.readBytes();
  if (inBuf == null) return;
  if (inBuf.length < numBands * 2) return;

  for (int i = 0; i < numBands; i++) {
    int idx = i * 2;
    int lowB  = inBuf[idx] & 0xFF;
    int highB = inBuf[idx + 1] & 0xFF;
    int intP = (highB << 8) | lowB;

    float rms = intP / 60000.0; // Arduino側のスケールに合わせる
    if (rms < 1e-6) rms = 1e-6;

    bandValues[i] = 20 * log(rms) / log(10);
  }
}

// ↓↓↓ 以下3つはあなたの元の関数をそのまま貼ればOK
void drawSpectrum() { /* 元のまま */ }
void drawFrequencyLabels() { /* 元のまま */ }
void drawVerticalAxisLabels() { /* 元のまま */ }

void keyPressed() {
  if (key == 's') exit();
  if (key == ' ') {
    if (player != null) {
      if (player.isPlaying()) player.pause();
      else player.play();
    }
  }
}

void stop() {
  if (player != null) player.close();
  if (minim != null) minim.stop();
  if (port != null) port.stop();
  super.stop();
}

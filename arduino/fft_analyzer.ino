#include "arduinoFFT.h"

const uint16_t samples = 64; 
const float samplingFreq = 7350;
float vReal[samples];
float vImag[samples];

ArduinoFFT<float> FFT = ArduinoFFT<float>(vReal, vImag, samples, samplingFreq, true);

void setup() {
  Serial.begin(115200);
}

void loop() {
  if (Serial.available() >= samples + 1) {
    if (Serial.read() == 255) { 
      for (int i = 0; i < samples; i++) {
        vReal[i] = (float)Serial.read() - 128.0;
        vImag[i] = 0.0;
      }

      FFT.windowing(FFTWindow::Hann, FFTDirection::Forward, true);
      FFT.compute(FFTDirection::Forward);
      FFT.complexToMagnitude();

      int step = (samples / 2) / 16;
      for (int i = 0; i < 16; i++) {
        float sum = 0;
        for (int j = 0; j < step; j++) {
          sum += vReal[i * step + j];
        }
        float val = sum / step;
        uint16_t sendVal = (uint16_t)constrain(val * 100.0, 0, 60000); 
        Serial.write(sendVal & 0xFF);
        Serial.write((sendVal >> 8) & 0xFF);
      }
      Serial.write(254); 
      Serial.flush();    
    }
  }
}
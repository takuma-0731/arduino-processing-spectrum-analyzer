void setup() {
  Serial.begin(115200);
  delay(1000); // シリアル通信の安定化を待つ
  Serial.println("Arduino Ready");
}

void loop() {
  recvData();
}

void sendData(int16_t data) {
  // 16bit符号付き整数を2バイトに分割して送信
  byte highByte = (byte)((data >> 8) & 0xFF);
  byte lowByte = (byte)(data & 0xFF);
  
  Serial.write(highByte);
  Serial.write(lowByte);
}

void recvData() {
  // バッファに2バイト以上あるか確認
  if (Serial.available() >= 2) {
    // 2バイト受信
    byte highByte = Serial.read();
    byte lowByte = Serial.read();
    
    // 16bit符号付き整数に復元
    int16_t receivedData = (highByte << 8) | lowByte;
        
    // データをエコーバック
    sendData(receivedData);
  }
  
  // バッファオーバーフロー対策
  if (Serial.available() > 32) {
    Serial.println("Buffer overflow - clearing");
    while (Serial.available() > 0) {
      Serial.read();
    }
  }
}
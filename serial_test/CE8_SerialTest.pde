import processing.serial.*;

Serial port;
int testValue = -548; // ここの値を適当に入れ替える（-32768 ~ 32767 の範囲）
int frameCounter = 0;
int sendInterval = 60; // 60フレーム(約1秒)に1回送信
int receivedData = 0;  // 受信データを保存
boolean dataReceived = false; // 受信データ有無のフラグ

void setup() {
  pixelDensity(2);
  size(400, 300);
  
  // 利用可能なポートを一覧表示
  println("=== 利用可能なシリアルポート ===");
  for (int i = 0; i < Serial.list().length; i++) {
    println("[" + i + "] " + Serial.list()[i]);
  }
  
  if (Serial.list().length == 0) {
    println("シリアルポートが見つかりません");
    exit();
    return;
  }
  
  try {
    String portName = Serial.list()[2]; // 環境に合わせて変更
    println("\n接続するポート: " + portName);
    port = new Serial(this, portName, 115200);
    port.clear(); // バッファをクリア
    println("接続成功！");
    delay(2000); // Arduinoの起動を待つ
  } catch (Exception e) {
    println("エラー: " + e.getMessage());
    exit();
    return;
  }
  
  println("\n準備完了！");
  println("スペースキーでデータ送信");
}

void draw() {
  background(30);
  
  // 情報表示
  fill(255);
  textSize(16);
  textAlign(LEFT);
  text("Serial Commun. Test", 20, 30);
  text("Sent Value: " + (-testValue), 20, 60);
  text("Space Key to transmit", 20, 90);
  
  // 受信データ表示
  if (dataReceived) {
    fill(0, 255, 0);
    textSize(20);
    text("Received data: " + receivedData, 20, 150);
  } else {
    fill(150);
    textSize(16);
    text("Waiting data...", 20, 150);
  }
}

void sendData(int data) {
  // 符号ビットを含む16bit符号付き整数として送信
  // -32768 ~ 32767 の範囲に制限
  int value = constrain(data, -32768, 32767);
  
  // 16bitデータをバイト単位に分割
  byte highByte = (byte)((value >> 8) & 0xFF);
  byte lowByte = (byte)(value & 0xFF);
  
  port.write(highByte);
  port.write(lowByte);
  println("送信: " + data);  
  println("  送信バイト: " + (highByte & 0xFF) + ", " + (lowByte & 0xFF));
}

void serialEvent(Serial p) {
  // バッファに2バイト以上あるか確認
  if (p.available() >= 2) {
    // 2バイト受信
    int highByte = p.read();  // 上位バイト
    int lowByte = p.read();   // 下位バイト
    
    // 16bit符号付き整数に復元
    receivedData = (highByte << 8) | lowByte;
    
    // 符号拡張（Javaのint型は32bit符号付き整数なので16bitの負の数は正になってしまう）
    if ((receivedData & 0x8000) != 0) {
      // 負の数の場合は符号拡張
      receivedData = receivedData | 0xFFFF0000;
    }
    
    dataReceived = true; // 受信フラグを立てる
    
    println("受信: " + receivedData );
    println("  受信バイト: " + highByte + ", " + lowByte );
  }
}

void keyPressed() {
  if (key == ' ') {
    // スペースキーでデータ送信
    sendData(testValue);
    testValue = -testValue; // 続いて正負を反転して送る
  } else if (key == 'c' || key == 'C') {
    // バッファクリア
    port.clear();
    println("バッファクリア");
  }
}

void stop() {
  if (port != null) {
    port.stop();
  }
  super.stop();
}

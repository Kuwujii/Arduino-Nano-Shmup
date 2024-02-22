#include <LCD_I2C.h>
#include <TM1637.h>

const byte PLAYER_UP[8] = {
  0b00000,
  0b00000,
  0b00000,
  0b00000,
  0b00000,
  0b01110,
  0b11011,
  0b10001
};

const byte PLAYER_DOWN[8] = {
  0b10001,
  0b11011,
  0b01110,
  0b00000,
  0b00000,
  0b00000,
  0b00000,
  0b00000
};

const byte BULLET_FULL[8] = {
  0b00000,
  0b00000,
  0b00010,
  0b11111,
  0b11111,
  0b00010,
  0b00000,
  0b00000
};

const byte BULLET_UP[8] = {
  0b00000,
  0b00000,
  0b00000,
  0b00000,
  0b00000,
  0b00000,
  0b00010,
  0b11111
};

const byte BULLET_DOWN[8] = {
  0b11111,
  0b00010,
  0b00000,
  0b00000,
  0b00000,
  0b00000,
  0b00000,
  0b00000
};

const byte ENEMY_BOSS[8] = {
  0b01100,
  0b01100,
  0b01110,
  0b01011,
  0b01011,
  0b01110,
  0b01100,
  0b01100
};

const byte ENEMY_REGULAR[8] = {
  0b00000,
  0b01110,
  0b11011,
  0b10001,
  0b10001,
  0b11011,
  0b01110,
  0b00000
};

const byte ENEMY_PLEBAN[8] = {
  0b00000,
  0b00001,
  0b00111,
  0b11101,
  0b11101,
  0b00111,
  0b00001,
  0b00000
};

const int BTTN_PIN = 2;
const int DIG4_DAT_PIN = 3;
const int DIG4_CLK_PIN = 4;
const int LED_COUNT = 10;
const int LED_PINS[] = {
  1, 5, 6, 7, 8, 9, 10, 11, 12, 13
}; 

TM1637 tm(DIG4_CLK_PIN, DIG4_DAT_PIN);
LCD_I2C lcd(0x27, 20, 4);

short playerPos = 0;
char area[17][4] = {
  {' ', ' ', ' ', ' '},
  {' ', ' ', ' ', ' '},
  {' ', ' ', ' ', ' '},
  {' ', ' ', ' ', ' '},
  {' ', ' ', ' ', ' '},
  {' ', ' ', ' ', ' '},
  {' ', ' ', ' ', ' '},
  {' ', ' ', ' ', ' '},
  {' ', ' ', ' ', ' '},
  {' ', ' ', ' ', ' '},
  {' ', ' ', ' ', ' '},
  {' ', ' ', ' ', ' '},
  {' ', ' ', ' ', ' '},
  {' ', ' ', ' ', ' '},
  {' ', ' ', ' ', ' '},
  {' ', ' ', ' ', ' '},
  {' ', ' ', ' ', ' '}
};

int score = 0;
short lvl = 0;
short combo = 0;

void setup() {
  pinMode(BTTN_PIN, INPUT_PULLUP);

  for(short thisLed = 0; thisLed < LED_COUNT; thisLed++) {
    pinMode(LED_PINS[thisLed], OUTPUT);
  }

  tm.init();
  tm.set(BRIGHT_TYPICAL);

  lcd.begin();
  lcd.backlight();

  lcd.createChar(0, ENEMY_REGULAR);
  lcd.createChar(1, PLAYER_UP);
  lcd.createChar(2, PLAYER_DOWN);

  lcd.createChar(3, BULLET_FULL);
  lcd.createChar(4, BULLET_UP);
  lcd.createChar(5, BULLET_DOWN);

  lcd.createChar(6, ENEMY_BOSS);
  //lcd.createChar(7, ENEMY_REGULAR);
  lcd.createChar(7, ENEMY_PLEBAN);
}

void loop() {
  if(score < 0) {
    tm.display(0, 0);
    tm.display(1, 0);
    tm.display(2, 0);
    tm.display(3, 0);

    for(short thisLed = 0; thisLed < LED_COUNT; thisLed++) {
      digitalWrite(LED_PINS[thisLed], LOW);
    }

    lcd.print("YOU LOSE    ");
  } else if(score > 9999) {
    tm.display(0, 9);
    tm.display(1, 9);
    tm.display(2, 9);
    tm.display(3, 9);

    for(short thisLed = 0; thisLed < LED_COUNT; thisLed++) {
      digitalWrite(LED_PINS[thisLed], HIGH);
    }

    lcd.print("YOU WIN    ");
  } else {
    lcd.clear();

    tm.display(0, (score/1000)%10);
    tm.display(1, (score/100)%10);
    tm.display(2, (score/10)%10);
    tm.display(3, score%10);

    lvl = floor(score/1000);

    for(short thisLed = 0; thisLed < LED_COUNT; thisLed++) {
      if(thisLed < combo) {
        digitalWrite(LED_PINS[thisLed], HIGH);
      } else {
        digitalWrite(LED_PINS[thisLed], LOW);
      }
    }

    if((random(1, 10001)/(lvl+1)) < 11) {
      area[16][random(0, 4)] = byte(6);
    } else if((random(1, 10001)/(lvl+1)) < 101) {
      area[16][random(0, 2)] = byte(0);
      area[16][random(2, 4)] = byte(0);
    } else if((random(1, 10001)/(lvl+1)) < 1001) {
      short ilemax = random(0, 4);

      for(short i = 0; i < ilemax; i++) {
        area[16][random(0, 4)] = byte(7);
      }
    }

    int analogPos = analogRead(A0);
    int buttonState = digitalRead(BTTN_PIN);

    playerPos = floor(analogPos/(1024/7));

    if(playerPos%2 == 0 || playerPos > 6) {
      lcd.setCursor(1, playerPos/2);
      lcd.write(byte(0));

      if(buttonState == LOW) {
        area[0][playerPos/2] = byte(3);
      }
    } else {
      lcd.setCursor(1, playerPos/2);
      lcd.write(byte(1));
      lcd.setCursor(1, (playerPos/2)+1);
      lcd.write(byte(2));

      if(buttonState == LOW) {
        area[0][playerPos/2] = byte(4);
        area[0][(playerPos/2)+1] = byte(5);
      }
    }

    for(short x = 0; x < 4; x++) {
      for(short y = 0; y < 17; y++) {
        lcd.setCursor(y+2, x);
        lcd.write(area[y][x]);
      }
    }

    for(short x = 0; x < 4; x++) {
      for(short y = 16; y > -1; y--) {
        if(area[y][x] == byte(3) || area[y][x] == byte(4) || area[y][x] == byte(5)) {
          if(area[y+1][x] == byte(6) || area[y+1][x] == byte(0) || area[y+1][x] == byte(7)) {
            if(combo < 10) {
              combo++;
            }
            
            if(area[y][x] == byte(4)) {
              area[y][x+1] = ' ';
            } else if(area[y][x] == byte(5)) {
              area[y+1][x-1] = ' ';
            }

            if(area[y+1][x] == byte(6)) {
              score += 100*combo;
            } else if(area[y+1][x] == byte(0)) {
              score += 10*combo;
            } else {
              score += 1*combo;
            }

            area[y][x] = ' ';
            area[y+1][x] = ' ';
          } else {
            area[y+1][x] = area[y][x];
            area[y][x] = ' ';
          }
        }
      }
    }

    for(short x = 0; x < 4; x++) {
      for(short y = 0; y < 17; y++) {
        if(area[y][x] == byte(6)) {
          if(y == 0) {
            area[y][x] = ' ';
            score -= 100;
            combo = 0;
          } else {
            short bok = random(0, 4);

            if(area[y-1][bok] == ' ') {
              area[y-1][bok] = area[y][x];
              area[y][x] = ' ';
            }
          }
        } else if(area[y][x] == byte(0)) {
          if(y == 0) {
            area[y][x] = ' ';
            score -= 10;
            combo = 0;
          } else {
            short bok = (x == 0) ? random(0, 2) : (
              (x == 3) ? random(-1, 1) : random(-1, 2)
            );

            if(area[y-1][x+bok] == ' ') {
              area[y-1][x+bok] = area[y][x];
              area[y][x] = ' ';
            }
          }
        } else if(area[y][x] == byte(7)) {
          if(y == 0) {
            area[y][x] = ' ';
            score--;
            combo = 0;
          } else {
            if(area[y-1][x] == ' ') {
              area[y-1][x] = area[y][x];
              area[y][x] = ' ';
            }
          }
        }
      }
    }

    lcd.setCursor(0, 0);
    lcd.print("L");
    lcd.setCursor(0, 1);
    lcd.print("V");
    lcd.setCursor(0, 2);
    lcd.print("L");
    lcd.setCursor(0, 3);
    lcd.print(lvl);

    lcd.setCursor(19, 0);
    lcd.print(lvl);
    lcd.setCursor(19, 1);
    lcd.print("L");
    lcd.setCursor(19, 2);
    lcd.print("V");
    lcd.setCursor(19, 3);
    lcd.print("L");

    delay(10/(lvl+1));
  }
}

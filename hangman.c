#include <stdio.h>
#include <stdlib.h>

char game[] = "   |-----|   Word: _______\n   |     |\n         |   Misses:        \n         |\n         |\n         |\n         |\n ---------\n";

//Head: 41
//Body 1 (center arms): 70
//Body 2: 81
//Center of legs: 92
//First letter of Word: 19
//First letter of Misses: 58

char word[] = "HANGMAN";
int wordLength = 7;
int missesCount = 0;
int hitsCount = 0;

char getInput();
int checkInput(char c);
void miss(char c);

int main(int argc, char *argv[]){
  printf("Welcome to Hangman!\nImplemented by Gary Dunn\n\n");
  while(0==0) {
      printf(game);
      char c = getInput();
      int correct = checkInput(c);
      if (correct == 0){
        miss(c);
      }
      hitsCount += correct;
      if(missesCount == 6) {
        printf(game);
        printf("\nYou lost; out of moves.\n");
        exit(0);
      }
      if(hitsCount == wordLength) {
        printf(game);
        printf("\nCongratulations! You have won.\n");
        exit(0);
      }
  }

}

char getInput() {
  char c;
  while(0==0) {
    printf("Enter next character (A-Z), or 0 to exit: ");

    do {
      c = getc(stdin);
    } while(c == '\n'); //This is the easiest way to get rid of newline characters.

    printf("\n\n");

    if (c >= 'A' && c <= 'Z') break;
    if (c == '0') exit(0);
    printf("\nInvalid input; try again.\n");
  }
  return c;

}

int checkInput(char c) {
  int count = 0;
  for(int i = 0; i < wordLength; i++){
    if (word[i] == c) {
      if (game[19 + i] != c) {
        game[19 + i] = c;
        count++;
      }
    }
  }
  return count;
}

void miss(char c) {
  game[58 + missesCount] = c;
  missesCount++;
      if(missesCount == 1) game[41] = 'O';
      if(missesCount == 2) {
        game[70] = '|';
        game[81] = '|';
      }
      if(missesCount == 3) game[69] = '\\';
      if(missesCount == 4) game[71] = '/';
      if(missesCount == 5) game[91] = '/';
      if(missesCount == 6) game[93] = '\\';
}

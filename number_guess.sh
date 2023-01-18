#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$(( RANDOM%1000 + 1 ))

echo -e "Enter your username:"

read USERNAME

USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE name = '$USERNAME'")

if [[ -z $USER_DATA ]]; then

  echo -e "\n Welcome, $USERNAME! It looks like this is your first time here."

  GAMES_PLAYED=1

  BEST_GAME=9999

else

  IFS="| "

  read GAMES_PLAYED BEST_GAME <<< $USER_DATA

  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

  ((GAMES_PLAYED++))

fi

echo -e "Guess the secret number between 1 and 1000:"

read GUESS

GUESS_TRIES=1

while (( GUESS != RANDOM_NUMBER )); do
  
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then

    echo -e "That is not an integer, guess again:"

  elif (( GUESS > RANDOM_NUMBER )); then

    echo -e "It's lower than that, guess again:"

  else

    echo -e "It's higher than that, guess again:"

  fi
  read GUESS
  ((GUESS_TRIES++))

done

if [[ -z $USER_DATA ]]; then

  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name, games_played, best_game) VALUES('$USERNAME', 1, $GUESS_TRIES)")

else

  if (( $GUESS_TRIES < $BEST_GAME )); then

    UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $GUESS_TRIES WHERE name = '$USERNAME';")

  else

    UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE name = '$USERNAME';")

  fi

fi

echo "You guessed it in $GUESS_TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"

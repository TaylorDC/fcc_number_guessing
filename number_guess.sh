#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"
echo -e "\n~~~ Number Guess Game ~~~\n"
echo -e "Enter your username:"
read USERNAME
USER_INFO=$($PSQL "SELECT name, games_played, best_game FROM users WHERE name = '$USERNAME'")
if [[ -z $USER_INFO ]]
  then
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
    #ADD_USER=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
  else
    read -r NAME BAR GAMES_PLAYED BAR BEST_GAME <<< "${USER_INFO}"
    echo -e "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
NUMBER=$(( RANDOM % 1000 ))
GUESS_COUNT=1

GET_GUESS () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\nGuess the secret number between 1 and 1000:"
  fi
  read GUESS
}
GET_GUESS
until [[ $GUESS == $NUMBER ]]
do
  ((GUESS_COUNT+=1))
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS < $NUMBER ]]
    then
      GET_GUESS "It's higher than that, guess again:" 
    else
      GET_GUESS "It's lower than that, guess again:"
    fi
  else
    GET_GUESS "That is not an integer, guess again:"
  fi
done
echo -e "You guessed it in $GUESS_COUNT tries. The secret number was $NUMBER. Nice job!"

#Update database
if [[ -z $USER_INFO ]]
then
  ADD_USER=$($PSQL "INSERT INTO users(name, games_played, best_game) VALUES('$USERNAME', 1, $GUESS_COUNT)")
else
  if [[ $GUESS_COUNT < $BEST_GAME ]]
  then
    UPDATE_USER=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED + 1, best_game = $GUESS_COUNT WHERE name = '$NAME'")
  else
    UPDATE_USER=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED + 1 WHERE name = '$NAME'")  
  fi
fi





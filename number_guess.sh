#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Get random number to generated
NUMBER=$(expr $RANDOM % 1000 + 1)

# User function
USER() {
  # ask for username
  echo "Enter your username:"
  read USERNAME

  # check if user exist
  USERNAME_RESULT=$($PSQL "SELECT * FROM users WHERE name = '$USERNAME'")

  # if user don't exist
  if [[ -z $USERNAME_RESULT ]]
  then
    echo "Welcome, $USERNAME>! It looks like this is your first time here."
     
    # input the user in the table
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")

    # get user id
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")

  # if user exist
  elif [[ ! -z $USERNAME_RESULT ]]
  then
    # get user id
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")

    #get number of game played
    NUMBER_GAME_PLAY=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")

    #get lowest game try
    LOWEST_GAME_TRY=$($PSQL "SELECT MIN(try) FROM games WHERE user_id = $USER_ID")

    echo "Welcome back, $USERNAME! You have played $NUMBER_GAME_PLAY games, and your best game took $LOWEST_GAME_TRY guesses."
  fi

  NUMBER_VALIDATION $USER_ID
}

# Number validation function
NUMBER_VALIDATION() {
  NUMBER_FOUND=false

  #insert game in games table
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(number, try, user_id) VALUES($NUMBER, 0, $1)")

  #get game_id
  GAME_ID=$($PSQL "SELECT game_id FROM games WHERE try = 0")

  # ask for number
  echo "Guess the secret number between 1 and 1000:"

  # If not a integer message
  while [[ $NUMBER_FOUND = false ]]
  do
    read NUMBER_GUESS

    if [[ ! $NUMBER_GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    else
      # Check if the guess if right
      if [[ $NUMBER_GUESS = $NUMBER ]]
      then
        # find number of try
        TRY=$($PSQL "SELECT try FROM games WHERE game_id = $GAME_ID")
        TRY_PLUS_ONE=$(expr $TRY + 1)

        echo "You guessed it in $TRY_PLUS_ONE tries. The secret number was $NUMBER. Nice job!"
        NUMBER_FOUND=true
      else
        # If guess is not right
        if [[ $NUMBER_GUESS > $NUMBER ]]
        then
          echo "It's lower than that, guess again:"
        elif [[ $NUMBER_GUESS < $NUMBER ]]
        then
          echo "It's higher than that, guess again:"
        fi
      fi
    fi
    UPDATE_GAME_TRY=$($PSQL "UPDATE games SET try = try + 1 WHERE game_id = $GAME_ID")
  done

}

USER

#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  # check if user was redirected here and if so, show message
  if [[ $1 ]]
  then
    echo $1
  fi

  # get available services
  SERVICES=$($PSQL "select service_id, name from services order by service_id;")
  # display available services
  echo -e "\nAvailable services:"
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # let user select a service
  echo -e "\nPlease select a service."
  read SERVICE_ID_SELECTED

  # check if service with chosen id exists
  CHOSEN_SERVICE=$($PSQL "select service_id from services where service_id = $SERVICE_ID_SELECTED;")
  # if not, start main menu again
  if [[ -z $CHOSEN_SERVICE ]]
  then
    MAIN_MENU "Please select a valid option."
  else
    READ_USER_INFO

    echo "Please choose a time for the service:"
    read SERVICE_TIME

    APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
    CHOSEN_SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED;")
    FORMATTED_SERVICE_NAME=$(echo $CHOSEN_SERVICE_NAME | sed 's/^ //')
    echo "I have put you down for a $FORMATTED_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

READ_USER_INFO() {
  # ask for phone number
  echo "Please enter your phone number:"
  read CUSTOMER_PHONE
  if [[ -z $CUSTOMER_PHONE ]]
  then
    READ_USER_INFO
  else
    # check if user is already in database
    CUSTOMER_INFO=$($PSQL "select customer_id, name from customers where phone = '$CUSTOMER_PHONE';")
    read CUSTOMER_ID BAR CUSTOMER_NAME < <(echo $CUSTOMER_INFO)

    # if user does not exist, create account
    if [[ -z $CUSTOMER_NAME ]]
    then
      while [[ -z $CUSTOMER_NAME ]]
      do
        echo "Please enter your name:"
        read CUSTOMER_NAME
      done

      $($PSQL "insert into customers(phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE';")

    fi

  fi
}


MAIN_MENU

#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
     echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?"
  fi

  # get services
  SERVICE_SELECTION=$($PSQL "SELECT * FROM services")
  # display services
  echo "$SERVICE_SELECTION" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  # input services
  read SERVICE_ID_SELECTED

   # If not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # Return to home with message
    MAIN_MENU "Please enter a valid number"
  else
    # get services
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    # If service doesn't exist
    if [[ -z $SERVICE_NAME ]] 
    then
      # Return to home with message
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      REGISTRATION_MENU "$SERVICE_ID_SELECTED" "$SERVICE_NAME"
    fi

  fi

}

REGISTRATION_MENU(){
  SERVICE_ID_SELECTED=$1
  SERVICE_NAME=$2

  # get customer phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # get customer name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get new customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')") 
  fi

  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # get time for appointment
  echo -e "\nWhat time would you like your cut, Fabio?"
  read SERVICE_TIME

  # insert appointment time to appointments
  NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # If appointment wasn't succesful
  if [[ $NEW_APPOINTMENT != "INSERT 0 1" ]] 
  then
    # Return to home with message
    MAIN_MENU "Could not schedule appointment, please schedule another service or try again later."
  else
    # Print success message
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME | sed -E 's/^ +| +$//g')."
    #echo -e "\nI have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME\n"
  fi
}

MAIN_MENU
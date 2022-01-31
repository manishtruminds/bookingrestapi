*** Settings ***
Variables        ../Variables/env.yaml
Variables        ../Variables/endpoints.yaml
Variables        ../Variables/testdata.yaml

Library         REST    ${env}[base_url]

*** Variables ***
${valid_booking_id}=    18
${invalid_booking_id}=    1787878

*** Test Cases ***

Health Check
    [Tags]    API    Invalid    Ping    HealthCheck
    GET    ${api}[ping]
    Output   response
    Integer    response status    201
    String    response reason    Created

Bad Request Health Check
    [Tags]    API    Invalid    Ping    HealthCheck
    POST    ${api}[ping]
    Output   response
    Integer    response status    404
    String    response reason    Not Found

CreateToken
    [Tags]    API    Valid    Auth    CreateToken
    [Documentation]
    POST    ${api}[auth]    body={ "username" : "${env}[admin_username]", "password" : "${env}[admin_password]" }
    Output   response body
    Integer    response status    200

    ${token}=    Output   response body token
    Log    ${token}
    Set Suite Variable    ${auth_token}    ${token}

Create Token With Invalid Credentials
    [Tags]    API    Invalid    Auth    CreateToken
    [Documentation]
    POST    ${api}[auth]    body={ "username" : "abc", "password" : "123" }
    Output   response
    Object    response body
    Integer    response status    200
    String    response reason    OK
    String    response body reason    Bad credentials

Create Booking
    [Tags]    API    Invalid    Booking    CreateBooking
    [Documentation]

    # 418 I'm a teapot
    POST    ${api}[booking]    body=${EXECDIR}/Variables/new_booking.json
    Output
    Object    response body
    Integer    response status    200
    String    response reason    OK

Get Booking With Invalid Id
    [Tags]    API    Invalid    Booking    GetBooking
    [Documentation]
    GET    ${api}[booking]/${invalid_booking_id}
    Output
    Integer    response status    404
    String    response reason    Not Found

Bad Get Booking Ids Request
    [Tags]    API    Invalid    Booking    GetBookingIds
    [Documentation]

    POST    ${api}[booking]
    Output    response
    Integer    response status    500
    String    response reason    Internal Server Error
    String    response body    Internal Server Error

UpdateBooking
    [Tags]    API    Invalid    Booking    UpdateBooking
    [Documentation]

    # 418 I'm a teapot

    # Log To Console    ${auth_token}
    PUT    ${api}[booking]/${valid_booking_id}
    ...    headers={"Cookie": "token=${auth_token}"}    body=${EXECDIR}/Variables/update_booking.json

    Output
    Object    response body
    Integer    response status    200
    String    response reason    OK

PartialUpdateBooking
    [Tags]    API    Invalid    Booking    PartialUpdateBooking
    [Documentation]

    # Log To Console    ${auth_token}
    PATCH    ${api}[booking]/${valid_booking_id}
    ...    headers={"Cookie": "token=${auth_token}"}    body=${EXECDIR}/Variables/partialupdate_booking.json

    Output
    Integer    response status    500
    String    response reason    Internal Server Error
    String    response body    Internal Server Error

# DeleteBooking
#     [Tags]    API    Invalid    Booking    DeleteBooking
#     [Documentation]

#     DELETE    ${api}[booking]/${valid_booking_id}
#     ...    headers={"Cookie": "token=${auth_token}"}

#     Output
#     Integer    response status    201
#     String    response reason    Created

Delete Booking With Invalid Invalid Id
    [Tags]    API    Invalid    Booking    DeleteBooking
    [Documentation]

    DELETE    ${api}[booking]/${invalid_booking_id}
    ...    headers={"Cookie": "token=${auth_token}"}

    Output
    Integer    response status    405
    String    response reason    Method Not Allowed

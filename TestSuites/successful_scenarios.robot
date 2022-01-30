*** Settings ***
Variables        ../Variables/env.yaml
Variables        ../Variables/endpoints.yaml
Variables        ../Variables/testdata.yaml

Library         REST    ${env}[base_url]

*** Variables ***


*** Test Cases ***

HealthCheck
    [Tags]    API    Valid    Ping    HealthCheck
    GET    ${api}[ping]
    Output   response body
    Integer    response status    201

CreateToken
    [Tags]    API    Valid    Auth    CreateToken
    [Documentation]
    POST    ${api}[auth]    { "username" : "${env}[admin_username]", "password" : "${env}[admin_password]" }
    Output   response body
    Integer    response status    200

CreateBooking
    [Tags]    API    Valid    Booking    CreateBooking
    [Documentation]

DeleteBooking
    [Tags]    API    Valid    Booking    DeleteBooking
    [Documentation]

GetBooking
    [Tags]    API    Valid    Booking    GetBooking
    [Documentation]

GetBookingIds
    [Tags]    API    Valid    Booking    GetBookingIds
    [Documentation]

PartialUpdateBooking
    [Tags]    API    Valid    Booking    PartialUpdateBooking
    [Documentation]

UpdateBooking
    [Tags]    API    Valid    Booking    UpdateBooking
    [Documentation]

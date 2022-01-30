*** Settings ***
Variables        ../Variables/env.yaml
Variables        ../Variables/endpoints.yaml
Variables        ../Variables/testdata.yaml

Library         REST    ${env}[base_url]

*** Variables ***


*** Test Cases ***

HealthCheck
    [Tags]    API    Invalid    Ping    HealthCheck
    GET    ${api}[ping]
    Output   response body
    Integer    response status    201


CreateToken
    [Tags]    API    Invalid    Auth    CreateToken
    [Documentation]
    POST    ${api}[auth]    { "username" : "abc", "password" : "123" }
    Output   response body
    String    response body reason    Bad credentials

CreateBooking
    [Tags]    API    Invalid    Booking    CreateBooking
    [Documentation]

DeleteBooking
    [Tags]    API    Invalid    Booking    DeleteBooking
    [Documentation]

GetBooking
    [Tags]    API    Invalid    Booking    GetBooking
    [Documentation]

GetBookingIds
    [Tags]    API    Invalid    Booking    GetBookingIds
    [Documentation]

PartialUpdateBooking
    [Tags]    API    Invalid    Booking    PartialUpdateBooking
    [Documentation]

UpdateBooking
    [Tags]    API    Invalid    Booking    UpdateBooking
    [Documentation]

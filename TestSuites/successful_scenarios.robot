*** Settings ***
Variables        ../Variables/env.yaml
Variables        ../Variables/endpoints.yaml
Variables        ../Variables/testdata.yaml

Library         REST    ${env}[base_url]
Library         OperatingSystem
Library         JSONLibrary
Library         Collections


*** Variables ***

${obj}          {"firstname" : "Jim","lastname" : "Brown","totalprice" : 111,"depositpaid" : true,"bookingdates" : {"checkin" : "2018-01-01","checkout" : "2019-01-01"},"additionalneeds" : "Breakfast"}
*** Test Cases ***

HealthCheck
    [Tags]    API    Valid    Ping    HealthCheck
    GET    ${api}[ping]
    Output   response body
    Integer    response status    201

CreateToken
    [Tags]    API    Valid    Auth   Flow   CreateToken
    [Documentation]
    POST    ${api}[auth]    { "username" : "${env}[admin_username]", "password" : "${env}[admin_password]" }
    ${token_val}   Output   response body token
    Set Suite Variable    ${token}    ${token_val}
    Log To Console    ${token}
    Integer    response status    200

CreateBooking
    [Tags]    API    Valid    Booking1    CreateBooking
    [Documentation]
    Log To Console    ${token}
    ${json_obj}=       load json from file     D:\\TruMinds\\restful-booker\\Variables\\test_data.json
    ${user1}=     get value from json     ${json_obj}   $.user1

    POST   ${api}[booking]    ${user1}[0]     headers={"Content-Type": "application/json"}
    Output  response body
    Integer  response status   200


GetBookingIds
    [Tags]    API    Valid    Flow   Booking3    GetBookingIds
    [Documentation]
    GET  ${api}[booking]
    ${l}=  Output  response body
    Set Suite Variable    ${some_id}    ${l}[0][bookingid]
    Integer  response status   200

GetBooking
    [Tags]    API    Valid   Flow   Booking3    GetBooking
    [Documentation]
    GET  ${api}[booking]/${some_id}
    Output  response body
    Integer  response status   200


DeleteBooking
    [Tags]    API    Valid    Flow    Booking3     DeleteBooking
    [Documentation]

    Delete    ${api}[booking]/${some_id}    headers={"Cookie": "token=${token}"}
    Output  response body
    #Integer  response status   200
    GET  ${api}[booking]
    Output  response body
    Integer  response status   200

PartialUpdateBooking
    [Tags]    API    Valid    Booking5    PartialUpdateBooking
    Log To Console    ${token}
    [Documentation]

UpdateBooking
    [Tags]    API    Valid    Booking    UpdateBooking
    [Documentation]

*** Settings ***
Variables        ../Variables/env.yaml
Variables        ../Variables/endpoints.yaml
Variables        ../Variables/testdata.yaml

Library         RequestsLibrary
Library         OperatingSystem
Library         JSONLibrary
Library         Collections


*** Variables ***
${base_url}    https://restful-booker.herokuapp.com

*** Test Cases ***
HealthCheck
    [Tags]    API    Valid    Ping   HealthCheck
    [Documentation]    A simple health check endpoint to confirm whether the API is up and running.
    ${response}=    GET    ${base_url}${api}[ping]
    ...     expected_status=201
    Should Be Equal As Strings    Created    ${response.content}

CreateToken
    [Tags]    API    Valid    Auth   CreateToken
    [Documentation]   Creates a new auth token to be used for PUT and DELETE operations
    ${headers}=    Create Dictionary     Content-Type=application/json

    ${auth_details}=    Create Dictionary    username=${env}[admin_username]    password=${env}[admin_password]

    ${response}=  POST      ${base_url}${api}[auth]
    ...     headers=${headers}
    ...     json=${auth_details}
    ...     expected_status=200

    #check token is present in response
    ${keys} =    Get Dictionary Keys    ${response.json()}

    Should Contain  ${keys}  token
    Set Suite Variable    ${token}    ${response.json()}[token]

CreateBooking
    [Tags]    API    Valid    Booking1    CreateBooking
    [Documentation]   Creating a new booking in the API

    ${json_obj}=       Load Json From File     ${EXECDIR}/Variables/json/test_data.json
    ${booking1}=     get value from json     ${json_obj}   $.booking1


    ${headers}=    Create Dictionary     Content-Type=application/json  Accept=application/json
    ${response}=  POST      ${base_url}${api}[booking]
    ...     headers=${headers}
    ...     json=${booking1}[0]
    ...     expected_status=200

    #check bookingid and booking are present in response
    Verify Response Contains    ${response}    ${booking1}

    Set Suite Variable    ${new_booking_id}    ${response.json()}[bookingid]

CreateManyBooking
    [Tags]    API    Valid    Booking1    CreateBooking
    [Documentation]    Creating many bookings in the API

    ${headers}=    Create Dictionary     Content-Type=application/json  Accept=application/json

    ${json_obj}=       Load Json From File     ${EXECDIR}/Variables/json/test_data.json
    ${booking2}=     get value from json     ${json_obj}   $.booking2
    ${booking3}=     get value from json     ${json_obj}   $.booking3
    ${booking4}=     get value from json     ${json_obj}   $.booking4



    ${response1}=  POST      ${base_url}${api}[booking]
    ...     headers=${headers}
    ...     json=${booking2}[0]
    ...     expected_status=200

    ${response2}=  POST      ${base_url}${api}[booking]
    ...     headers=${headers}
    ...     json=${booking3}[0]
    ...     expected_status=200

    ${response3}=  POST      ${base_url}${api}[booking]
    ...     headers=${headers}
    ...     json=${booking4}[0]
    ...     expected_status=200

    #check bookingid and booking are present in response
    Verify Response Contains    ${response1}    ${booking2}
    Verify Response Contains    ${response2}    ${booking3}
    Verify Response Contains    ${response3}    ${booking4}

GetBookingIds
    [Tags]    API    Valid    Booking    GetBookingIds
    [Documentation]    Returns the ids of all the bookings that exist within the API.
    ${response}=    GET   ${base_url}${api}[booking]
    ...     expected_status=200

GetBooking
    [Tags]    API    Valid   Booking1    GetBooking
    [Documentation]    Returns a specific booking based upon the booking id provided
    ${response}=    GET   ${base_url}${api}[booking]/${new_booking_id}
    ...     expected_status=200

    #check bookinginformation is correct in response
    ${json_obj}=       Load Json From File     ${EXECDIR}/Variables/json/test_data.json
    ${booking1}=     get value from json     ${json_obj}   $.booking1
    Should Be Equal    ${booking1}[0]    ${response.json()}

UpdateBooking
    [Tags]    API    Valid    Booking    UpdateBooking
    [Documentation]   Updates a current booking

    ${headers}=   Create Dictionary    Content-Type=application/json
    ...     Accept=application/json    Cookie=token=${token}

    ${json_obj}=       Load Json From File     ${EXECDIR}/Variables/json/updated_data.json


    ${response}=    PUT   ${base_url}${api}[booking]/${new_booking_id}
    ...     headers=${headers}
    ...     json=${json_obj}
    ...     expected_status=200


    #check bookinginformation is correct in response
    ${json_obj}=       Load Json From File     ${EXECDIR}/Variables/json/updated_data.json

    ${new_booking}=    GET    ${base_url}${api}[booking]/${new_booking_id}
    ...       expected_status=200
    Should Be Equal    ${json_obj}    ${new_booking.json()}

PartialUpdateBooking
    [Tags]    API    Valid    Booking    PartialUpdateBooking
    [Documentation]    Updates a current booking with a partial payload


    ${headers}=   Create Dictionary    Content-Type=application/json
    ...     Accept=application/json    Cookie=token=${token}
    ${data}=      Create Dictionary    firstname=Joseph   lastname=Maleno

    ${response}=    PATCH   ${base_url}${api}[booking]/${new_booking_id}
    ...   headers=${headers}
    ...   json=${data}
    ...   expected_status=200


    #check bookinginformation is correct in response
    ${new_booking}=    GET    ${base_url}${api}[booking]/${new_booking_id}
    ...       expected_status=200

    ${firstname}=  Set Variable     ${new_booking.json()}[firstname]
    ${lastname}=   Set Variable     ${new_booking.json()}[lastname]

    Should be equal  ${firstname}  ${data}[firstname]
    Should be equal  ${lastname}  ${data}[lastname]

DeleteBooking
    [Tags]    API    Valid    Booking     DeleteBooking
    [Documentation]   Returns the ids of all the bookings that exist within the API
    ${cookies}   Set Variable    token=${token}
    ${headers}=   Create Dictionary    Content-Type=application/json    Cookie=${cookies}
    ${response}=    DELETE    ${base_url}${api}[booking]/${new_booking_id}
    ...     headers=${headers}
    ...     expected_status=201

    Should Be Equal As Strings    Created    ${response.content}

    ${new_booking}=    GET    ${base_url}${api}[booking]/${new_booking_id}
    ...     expected_status=404


***Keywords***
Verify Response Contains

    [Arguments]   ${response}     ${booking}
    ${keys} =    Get Dictionary Keys    ${response.json()}
    Should Contain  ${keys}  bookingid
    Should Contain  ${keys}  booking
    Should Be Equal    ${booking}[0]    ${response.json()}[booking]

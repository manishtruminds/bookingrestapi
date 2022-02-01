*** Settings ***
Variables        ../Variables/env.yaml
Variables        ../Variables/endpoints.yaml
Variables        ../Variables/testdata.yaml

<<<<<<< HEAD
Library         RequestsLibrary
Library         OperatingSystem
Library         JSONLibrary
Library         Collections


*** Variables ***
${base_url}    https://restful-booker.herokuapp.com

*** Test Cases ***
HealthCheck
    [Tags]    API    Valid    Ping   HealthCheck
    [Documentation]
    ${response}=    GET    ${base_url}${api}[ping]
    ...     expected_status=201
    Should Be Equal As Strings    Created    ${response.content}

CreateToken
    [Tags]    API    Valid    Auth   CreateToken
    [Documentation]
    ${headers}=    Create Dictionary     Content-Type=application/json

    ${auth_details}=    Create Dictionary    username=admin   password=password123

    ${response}=  POST      ${base_url}${api}[auth]
    ...     headers=${headers}
    ...     json=${auth_details}
    ...     expected_status=200

    #check token is present in response
    ${keys} =    Get Dictionary Keys    ${response.json()}

    Should Contain  ${keys}  token
    Set Suite Variable    ${token}    ${response.json()}[token]

    #Check the value of the header Content-Type
    ${getHeaderValue}=  Get From Dictionary  ${response.headers}  Content-Type
    Should be equal  ${getHeaderValue}  application/json; charset=utf-8

CreateBooking
    [Tags]    API    Valid    Booking1    CreateBooking
    [Documentation]

    ${json_obj}=       load json from file     ${EXECDIR}/Variables/test_data.json
    ${headers}=    Create Dictionary     Content-Type=application/json  Accept=application/json
    ${response}=  POST      ${base_url}${api}[booking]
    ...     headers=${headers}
    ...     json=${json_obj}
    ...     expected_status=200


    #check bookingid and booking are present in response
    ${keys} =    Get Dictionary Keys    ${response.json()}
    Should Contain  ${keys}  bookingid
    Should Contain  ${keys}  booking
    Should Be Equal    ${json_obj}    ${response.json()}[booking]

    #Check the value of the header Content-Type
    ${getHeaderValue}=  Get From Dictionary  ${response.headers}  Content-Type
    Should be equal  ${getHeaderValue}  application/json; charset=utf-8

    Set Suite Variable    ${new_booking_id}    ${response.json()}[bookingid]
=======
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
>>>>>>> 4c7e8ea3362fb9a94168dfc35f38f2b5ece31781

GetBookingIds
    [Tags]    API    Valid    Booking    GetBookingIds
    [Documentation]
<<<<<<< HEAD
    ${response}=    GET   ${base_url}${api}[booking]
    ...     expected_status=200
    Log    ${response.json()}

GetBooking
    [Tags]    API    Valid   Booking1    GetBooking
    [Documentation]
    ${response}=    GET   ${base_url}${api}[booking]/${new_booking_id}
    ...     expected_status=200

    #check bookinginformation is correct in response
    ${json_obj}=       load json from file     ${EXECDIR}/Variables/test_data.json
    Should Be Equal    ${json_obj}    ${response.json()}

UpdateBooking
    [Tags]    API    Valid    Booking    UpdateBooking
    [Documentation]

    ${headers}=   Create Dictionary    Content-Type=application/json
    ...     Accept=application/json    Cookie=token=${token}

    ${json_obj}=       Load Json From File     ${EXECDIR}/Variables/updated_data.json
    ${response}=    PUT   ${base_url}${api}[booking]/${new_booking_id}
    ...     headers=${headers}
    ...     json=${json_obj}
    ...     expected_status=200


    #check bookinginformation is correct in response
    ${json_obj}=       load json from file     ${EXECDIR}/Variables/updated_data.json

    ${new_booking}=    GET    ${base_url}${api}[booking]/${new_booking_id}
    ...       expected_status=200
    Should Be Equal    ${json_obj}    ${new_booking.json()}

=======
>>>>>>> 4c7e8ea3362fb9a94168dfc35f38f2b5ece31781

PartialUpdateBooking
    [Tags]    API    Valid    Booking    PartialUpdateBooking
    [Documentation]

<<<<<<< HEAD
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
    [Documentation]
    ${cookies}   Set Variable    token=${token}
    ${headers}=   Create Dictionary    Content-Type=application/json    Cookie=${cookies}
    ${response}=    DELETE    ${base_url}${api}[booking]/${new_booking_id}
    ...     headers=${headers}
    ...     expected_status=201

    Should Be Equal As Strings    Created    ${response.content}

    ${new_booking}=    GET    ${base_url}${api}[booking]/${new_booking_id}
    ...     expected_status=404
    Log    ${new_booking}
=======
UpdateBooking
    [Tags]    API    Valid    Booking    UpdateBooking
    [Documentation]
>>>>>>> 4c7e8ea3362fb9a94168dfc35f38f2b5ece31781

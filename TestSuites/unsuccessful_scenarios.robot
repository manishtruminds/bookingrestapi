*** Settings ***
Library          RequestsLibrary
Library          JSONLibrary
Library    Collections
Variables        ../Variables/env.yaml
Variables        ../Variables/endpoints.yaml
Variables        ../Variables/testdata.yaml

*** Variables ***
${base_url}    ${env}[base_url]

*** Test Cases ***
Health Check
    [Tags]    API    Invalid    Ping    HealthCheck
    ${response}=    GET    ${base_url}${api}[ping]    expected_status=201
    Log To Console    ${response}

Invalid Health Check Request
    [Tags]    API    Invalid    Ping    HealthCheck
    ${response}=    POST    ${base_url}${api}[ping]    expected_status=404
    Log To Console    ${response}
    Should Be Equal As Strings    ${response.reason}    Not Found

Create Token With Valid Credentials
    [Tags]    API    Valid    Auth    CreateToken
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${body_json}=    Create Dictionary    username=${env}[admin_username]    password=${env}[admin_password]
    ${response}=    POST    ${base_url}${api}[auth]
    ...    headers=${headers}
    ...    json=${body_json}
    ...    expected_status=200

    Log To Console    ${response.json()}

    ${keys} =    Get Dictionary Keys    ${response.json()}
    Should Contain    ${keys}    token

    Set Suite Variable    ${auth_token}    ${response.json()}[token]

Create Token With Invalid Credentials
    [Tags]    API    Invalid    Auth    CreateToken
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${body_json}=    Create Dictionary    username=${testdata}[invalid_admin_username]    password=${testdata}[invalid_admin_password]
    ${response}=    POST    ${base_url}${api}[auth]
    ...    headers=${headers}
    ...    json=${body_json}
    ...    expected_status=200

    Log To Console    ${response.json()}
    Should Be Equal As Strings    ${response.json()}[reason]    Bad credentials

Create Booking With Missing Booking FirstName Field
    [Tags]    API    Invalid    Booking    CreateBooking
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${body_json}=    Load JSON From File    ${EXECDIR}/Variables/json/new_invalid_booking.json
    ${response}=    POST    ${base_url}${api}[booking]
    ...    headers=${headers}
    ...    json=${body_json}
    ...    expected_status=500

    Log To Console    ${response}
    Should Be Equal As Strings    ${response.reason}    Internal Server Error

Create Booking With Valid Booking Data
    [Tags]    API    Valid    Booking    CreateBooking
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${body_json}=    Load JSON From File    ${EXECDIR}/Variables/json/new_valid_booking.json
    ${response}=    POST    ${base_url}${api}[booking]
    ...    headers=${headers}
    ...    json=${body_json}
    ...    expected_status=200

    Log To Console    ${response.json()}

    Should Be Equal    ${body_json}    ${response.json()}[booking]

    Set Suite Variable    ${new_booking_id}    ${response.json()}[bookingid]

Get Booking With Invalid Booking Id
    [Tags]    API    Invalid    Booking    GetBooking
    [Documentation]
    ${response}=    GET    ${base_url}${api}[booking]/${testdata}[invalid_booking_id]   expected_status=404

    Log To Console    ${response}
    Should Be Equal As Strings    ${response.reason}    Not Found

Update Booking With Invalid Authorization Token
    [Tags]    API    Invalid    Booking    UpdateBooking
    ${headers}=    Create Dictionary
    ...    Content-Type=application/json    Accept=application/json
    ...    Cookie=token=${testdata}[invalid_auth_token]

    ${body_json}=    Load JSON From File    ${EXECDIR}/Variables/json/update_booking.json
    ${response}=    PUT    ${base_url}${api}[booking]/${new_booking_id}
    ...    headers=${headers}
    ...    json=${body_json}
    ...    expected_status=403

    Log To Console    ${response}

    Should Be Equal As Strings    ${response.reason}    Forbidden

Update Booking With Invalid Booking Id
    [Tags]    API    Invalid    Booking    UpdateBooking
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json    Cookie=token=${auth_token}
    ${body_json}=    Load JSON From File    ${EXECDIR}/Variables/json/update_booking.json
    ${response}=    PUT    ${base_url}${api}[booking]/${testdata}[invalid_booking_id]
    ...    headers=${headers}
    ...    json=${body_json}
    ...    expected_status=405

    Log To Console    ${response}

    Should Be Equal As Strings    ${response.reason}    Method Not Allowed

Partial Update Booking With Invalid Authorization Token
    [Tags]    API    Invalid    Booking    PartialUpdateBooking
    
    ${headers}=    Create Dictionary
    ...    Content-Type=application/json    Accept=application/json
    ...    Cookie=token=${testdata}[invalid_auth_token]

    ${body_json}=    Load JSON From File    ${EXECDIR}/Variables/json/partialupdate_booking.json
    ${response}=    PATCH    ${base_url}${api}[booking]/${new_booking_id}
    ...    headers=${headers}
    ...    json=${body_json}
    ...    expected_status=403

    Log To Console    ${response}

    Should Be Equal As Strings    ${response.reason}    Forbidden

Partial Update Booking With Invalid Booking Id
    [Tags]    API    Invalid    Booking    PartialUpdateBooking
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json    Cookie=token=${auth_token}
    ${body_json}=    Load JSON From File    ${EXECDIR}/Variables/json/partialupdate_booking.json
    ${response}=    PATCH    ${base_url}${api}[booking]/${testdata}[invalid_booking_id]
    ...    headers=${headers}
    ...    json=${body_json}
    ...    expected_status=405

    Log To Console    ${response}

    Should Be Equal As Strings    ${response.reason}    Method Not Allowed

Delete Booking With Invalid Authorization Token
    [Tags]    API    Invalid    Booking    DeleteBooking
    ${headers}=    Create Dictionary
    ...    Content-Type=application/json    Accept=application/json
    ...    Cookie=token=${testdata}[invalid_auth_token]

    ${response}=    DELETE    ${base_url}${api}[booking]/${new_booking_id}
    ...    headers=${headers}
    ...    expected_status=403

    Log To Console    ${response}

    Should Be Equal As Strings    ${response.reason}    Forbidden

Delete Booking With Invalid Booking Id
    [Tags]    API    Invalid    Booking    DeleteBooking
    ${headers}=    Create Dictionary    Content-Type=application/json    Cookie=token=${auth_token}
    ${response}=    DELETE    ${base_url}${api}[booking]/${testdata}[invalid_booking_id]
    ...    headers=${headers}
    ...    expected_status=405

    Log To Console    ${response}

    Should Be Equal As Strings    ${response.reason}    Method Not Allowed

*** Settings ***
Library    RequestsLibrary
Library    Collections
Suite Setup    Test Setup


*** Variables ***
${BASE_URL}    https://restful-booker.herokuapp.com
${BOOKING_DATA}   {"firstname": "Ropo", "lastname": "Lee", "totalprice": 450, "depositpaid": true, "bookingdates": {"checkin": "2025-01-01", "checkout": "2025-01-28"},"additionalneeds": "Breakfast"}
${BOOKING_ID}     None
${TOKEN_INFO}    {"username" : "admin","password" : "password123"}


*** Test Cases ***
Create_booking
    [Tags]    create
    ${header}=    Create Dictionary    Content-Type=application/json
    ${response}=    POST On Session    mySession    /booking    data= ${BOOKING_DATA}    headers=${header}
    Set Suite Variable    ${BOOKING_ID}    ${response.json()["bookingid"]}
    Should Be Equal As Integers    ${response.status_code}    200
    Log To Console    Booking created with ID: ${BOOKING_ID}


Get_Booking
    [Tags]    get
    ${response}=    GET On Session    mySession    /booking/${BOOKING_ID}
    Should Be Equal As Integers    ${response.status_code}    200
#    Extracting firstname from original BOOKING_DATA above to compare to retrieved firstname
    ${booking_data_dict}=    Evaluate    json.loads('${BOOKING_DATA}')    modules=json
    ${firstname}=    Get From Dictionary    ${booking_data_dict}    firstname
    Log To Console    ${BOOKING_ID}
    Log To Console    ${firstname}
    Should Contain    ${response.content}    ${firstname}

Delete Booking
    [Tags]    delete
    Log To Console    ${BOOKING_ID}
    ${header}=    Create Dictionary    Authorization=${TOKEN}    Content-Type=application/json
    ${response}=    DELETE On Session    mySession    /booking/${BOOKING_ID}    headers=${header}
    Should Be Equal As Integers    ${response.status_code}    200







*** Keywords ***
Test Setup
    Create Session    mySession    ${BASE_URL}
    ${header}=    Create Dictionary    Content-Type=application/json
    ${token_response}=    POST On Session    mySession    /auth    data= ${TOKEN_INFO}    headers=${header}
    ${json_data}=    Evaluate    json.loads('${token_response.content}')    modules=json
    ${token}=    Get From Dictionary    ${json_data}    token
    Set Suite Variable    ${TOKEN}    ${token}
    Log To Console    API is reachable
    
Test Teardown
    IF    ${BOOKING_ID} != None
        DELETE    mySession    /booking/${BOOKING_ID}
        Log    Booking ${BOOKING_ID} deleted
    END
*** Settings ***
Library           Selenium2Library
Library           String
Library           DateTime
Library           Collections
Library           Screenshot
Resource          epu.robot
Library           epu_service.py

*** Variables ***
${lot.titleEdt}    //*[@id="divLotsItemsDynamic"]/div[@class="panel panel-default"]/a/div/h4/div/div[@class="col-md-9"]/p/b    # заголовок лота на странице редктирования
${lot.hrefEdt}    //*[@id="divLotsItemsDynamic"]/div[@class="panel panel-default"]/a    # ссылка для раскрытия блока лота на странице редактирования
${lot.btnEditEdt}    //*[@id="divLotsItemsDynamic"]/div[@class="panel panel-default"]/div/div/div/div/button[@class="btn btn-dark_blue btn-sm"]    # кнопка редактирования лота
${lot.btnDelEdt}    //*[@id="divLotsItemsDynamic"]/div[@class="panel panel-default"]/div/div/div/div/button[@class="btn btn-yellow btn-sm"]    # кнопка удаления лота

*** Keywords ***
Додати предмет
    [Arguments]    ${tender_data}    ${index}    ${lot_title}
    [Documentation]    ${ARGUMENTS[0]} == ${tender_data}
    ...    ${ARGUMENTS[1]} == ${INDEX}
    ...    ${ARGUMENTS[1]} ==${txt_title} \ \ \ (lots title)
    \    # Wait Until Element Is Enabled    id=AddPoss
    \    # Click Element    id=AddPoss
    \    # Wait Until Page Contains Element    id=AddItemButton    10
    \    #
    Click Element   ${locator.stepTwo}
    #${lot_title}=    Get From List    ${ARGUMENTS}    2
    #${index}=    Get From List    ${ARGUMENTS}    1
    #${tender_date}=    Get From List    ${ARGUMENTS}    0
    ${items}=    Get From Dictionary    ${tender_data}    items
    ${item}=    Get From List    ${items}    ${index}
    ${editItemDetails}=    Get From Dictionary    ${item}    description
    \    #Log To Console    xpath=//input[@id-t='editItemDetails'] \ \ ${editItemDetails}
    Input text    xpath=//input[@id-t='editItemDetails']    ${editItemDetails}
    Run Keyword If    '${TEST NAME}' == 'Можливість оголосити мультилотовий тендер'    Select From List By Label    lot_combo    ${lot_title}
    \    #
    ${unit}=    Get From Dictionary    ${item}    unit
    ${tov}=    Get From Dictionary    ${unit}    name
    ${editItemQuantity}=    Get From Dictionary    ${item}    quantity
    Input Text    id=editItemQuantity    ${editItemQuantity}
    \    #Click Element    xpath=//button[@data-id="tov"]
    \    #Select From List By Label   unitCodet   ${tov}
    #choise CPV
    ${cpv_id}=    Get From Dictionary    ${item.classification}    id
    ${dkpp_id}=    Get From Dictionary    ${item.additionalClassifications[0]}    id
    Input Text    xpath=//input[@placeholder='CPV']   ${cpv_id}
    Input Text    xpath=//input[@placeholder='ДКПП']   ${dkpp_id}
    ${region}=    Get From Dictionary    ${items[0].deliveryAddress}    region
    \    #Select From List By Label   region    ${region}
    ${locality}=    Get From Dictionary    ${items[0].deliveryAddress}    locality
    Input Text    id=locality    ${locality}
    \    #
    ${items_description}=    Get From Dictionary    ${items[0].additionalClassifications[0]}    description
    ${quantity}=    Get From Dictionary    ${items[0]}    quantity
    ${cpv}=    Get From Dictionary    ${items[0].classification}    description
    ${unit}=    Get From Dictionary    ${items[0].unit}    code
    #
    ${postalCode}=    Get From Dictionary    ${items[0].deliveryAddress}    postalCode
    ${streetAddress}=    Get From Dictionary    ${items[0].deliveryAddress}    streetAddress
    #add address    -------------------------------------------
    ${deliveryDate}=    Get From Dictionary    ${items[0].deliveryDate}    endDate
    ${deliveryDate}=    epu_service.Convert Date To String    ${deliveryDate}
    Input Text    xpath=//input[@id-t='deliveryDateEndDate']    ${deliveryDate}
    \    #
    Input Text    id=postcode    ${postalCode}
    ${streetAddress}=    Get From Dictionary    ${items[0].deliveryAddress}    streetAddress
    Input Text    id=street    ${streetAddress}
    \    #

Додати багато лотів
    [Arguments]    ${tender_data}
    ${lots}=    Get From Dictionary    ${tender_data}    lots
    ${length}=    Get Length    ${lots}
    Run Keyword If    '${TEST NAME}' == 'Можливість оголосити мультилотовий тендер'    DeleteDefaultLot
    : FOR    ${INDEX}    IN RANGE    0    ${length}
    \    Click Element    AddLot
    \    Wait Until Element Is Visible    lot_name
    \    ${txt_title}=    Get From Dictionary    ${lots[${INDEX}]}    title
    \    Input Text    lot_name    ${txt_title}
    \    ${txt}=    Get From Dictionary    ${lots[${INDEX}]}    description
    \    Input Text    lot_description    ${txt}
    \    ${txt}=    Get From Dictionary    ${lots[${INDEX}].value}    amount
    \    ${txt}=    Convert To String    ${txt}
    \    Input Text    lot_budget    ${txt}
    \    ${txt}=    Get From Dictionary    ${lots[${INDEX}].minimalStep}    amount
    \    ${txt}=    Convert To String    ${txt}
    \    Input Text    lot_auction_min_step    ${txt}
    \    Wait Until Element Is Enabled    button_add_lot
    \    Click Button    button_add_lot
    \    Додати предмет    ${tender_data}    ${INDEX}    ${txt_title}
    \    Log To Console    item ${INDEX} added
    \    \    #

Додати багато предметів
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == tender_data
    ${items}=    Get From Dictionary    ${ARGUMENTS[0]}    items
    ${Items_length}=    Get Length    ${items}
    : FOR    ${INDEX}    IN RANGE    0    ${Items_length}
    \    Додати предмет    ${ARGUMENTS[0]}    ${INDEX}    0

Опублікувати тендер
    Click Button    ${locator.stepThree}
    sleep    1
    Click Button   id=tender
    sleep    50
    Go To    ${USERS.users['epu_Owner'].homepage}
    Click Element    id=btnView
    ${starttime}=    Get Current Date
    sleep    2
    ${tender_id}=    Get Text    id=tenderID
    [Return]    ${tender_id}

Отримати інформацію про title
    ${return_value}=   Get Text  id=headerTitle
    [return]  ${return_value}

Отримати інформацію про description
    ${return_value}=   Get Text  id=descriptionTender
    [return]  ${return_value}

Отримати інформацію про value.amount
    ${return_value}=   Get Text  id=amountTender
    ${return_value}=   Convert To Number    ${return_value}
    [return]  ${return_value}

Отримати інформацію про value.currency
    ${return_value}=   Get Text  id=currencyTender
    [return]  ${return_value}

Отримати інформацію про tenderID
    ${return_value}=   Get Text  id=tenderID
    [return]  ${return_value}

Отримати інформацію про enquiryPeriod.startDate
    ${return_value}=   Get Text    id=enquiryPeriod_start
    [return]  ${return_value}

Отримати інформацію про enquiryPeriod.endDate
    ${return_value}=   Get Text    id=enquiryPeriod_end
    [return]  ${return_value}

Отримати інформацію про tenderPeriod.startDate
    ${return_value}=   Get Text    id=tenderPeriod_start
    [return]  ${return_value}

Отримати інформацію про tenderPeriod.endDate
    ${return_value}=   Get Text    id=tenderPeriod_end
    [return]  ${return_value}

Отримати інформацію про minimalStep.amount
    ${return_value}=   Get Text  id=minimalStep
    ${return_value}=   Convert To Number    ${return_value}
    [return]  ${return_value}

Отримати інформацію про items[0].deliveryDate.endDate
    ${return_value}=   Get Text    id=deliveryDate_end
    [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.countryName
    ${return_value}=   Get Text  id=countryDelivery
    [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.postalCode
    ${return_value}=   Get Text  id=postalcodeDelivery
    [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.region
    ${return_value}=   Get Text  id=regionDelivery
    [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.locality
    ${return_value}=   Get Text  id=localityDelivery
    [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.streetAddress
    ${return_value}=   Get Text  id=streetAddress
    [return]  ${return_value}

TenderInfo
    [Arguments]    ${tender_data}
    ${title}=    Get From Dictionary    ${tender_data}    title
    ${description}=    Get From Dictionary    ${tender_data}    description
    ${budget}=    Get From Dictionary    ${tender_data.value}    amount
    ${step_rate}=    Get From Dictionary    ${tender_data.minimalStep}    amount
    \    #
    Input text    ${locator.tenderTitle}    ${title}
    Input text    ${locator.tenderDetail}    ${description}
    ${text}=    Convert To string    ${budget}
    Input text    ${locator.tenderBudget}    ${text}
    ${text}=    Convert To String    ${step_rate}
    Input text    ${locator.tenderStep}    ${text}
    Click Element    id=confirm-check

Заповнити дати тендеру
    [Arguments]    ${enquiryPeriod}    ${tenderPeriod}
    ${enquiry_end}=    Get From Dictionary    ${enquiryPeriod}    endDate
    #
    ${tender_start}=    Get From Dictionary    ${tenderPeriod}    startDate
    ${tender_end}=    Get From Dictionary    ${tenderPeriod}    endDate
    #
    ${dt2}=    epu_service.Convert Date To String    ${enquiry_end}
    Input text    ${locator.tenderComEnd}    ${dt2}
    Press Key    ${locator.tenderComEnd}    \\\13
    #
    ${dt3}=    epu_service.Convert Date To String    ${tender_start}
    Input text    ${locator.tenderStart}    ${dt3}
    Press Key    ${locator.tenderStart}    \\\13
    ${dt4}=    epu_service.Convert Date To String    ${tender_end}
    Input text    ${locator.tenderEnd}    ${dt4}
    Press Key    ${locator.tenderEnd}    \\\13
    Click Element   ${locator.stepOne}

SearchIdViewer
    sleep    120
    [Arguments]    ${tender_UAid}    ${username}
    sleep    2
    Go To    ${USERS.users['${username}'].homepage}search?q=${tender_UAid}
    sleep    2
    Click Element    id=title-head-tender-search
    sleep    2

DeleteDefaultLot
    Wait Until Page Contains Element    ${lot.titleEdt}    50
    Click Element    ${lot.hrefEdt}
    Wait Until Element Is Visible    ${lot.btnDelEdt}
    Click Element    ${lot.btnDelEdt}
    Wait Until Element Is Visible    button_delete_lot
    Click Element    button_delete_lot
    Wait Until Element Is Visible    AddLot

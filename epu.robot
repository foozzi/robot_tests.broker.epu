*** Settings ***
Library           Selenium2Library
Library           String
Library           DateTime
Library           Collections
Library           Screenshot
Resource          EPUtender_subkeywords.robot
Library           epu_service.py

*** Variables ***
${item_index}     0
${locator.tenderID}    xpath=//div[@id='tenderID']
${locator.modalLogin}   id=auth-button
${locatot.cabinetEnter}    id=auth-button
${locator.emailField}    id=loginEmailBox
${locator.passwordField}    id=loginPasswordBox
${locator.loginButton}    id=login_button
${locator.toTenderMenu}    id=toTenderMenu
${locator.buttonTenderAdd}    id=createTender

${local.tenderComEnd}   xpath=//input[@name='endDateEnquiryPeriod']

${locator.tenderTitle}    id=purchase-name
${locator.tenderDetail}    id=notices

${locator.tenderBudget}    id=excepted-prices
${locator.tenderStep}    id=step-auction

${locator.tenderComEnd}    xpath=//input[@name='endDateEnquiryPeriod']

${locator.tenderStart}    xpath=//input[@name='tenderPeriodStartDate']
${locator.tenderEnd}    xpath=//input[@name='tenderPeriodEndDate']

${locator.stepOne}   id=step1
${locator.stepTwo}   id=step2
${locator.stepThree}    id=step3

${locator.tenderAdd}    id=btnAdd
${locator.topSearch}    id=topsearch
${locator.searchButton}    id=btnSearch
${locator.findTender}    xpath=//p[@class='cut_title']
${locator.informationTable}    xpath=//li[@id='tab1']
${locator.title}    id=edtTenderTitle
${locator.descriptions}    id=edtTenderDetail
${locator.value.amount}    id=edtTenderBudget
${locator.tenderId}    id=titleTenderCode
${locator.procuringEntity.name}    id=author_legal_name

${locator.enquiryPeriod.endDate}    xpath=//input[@name='endDateEnquiryPeriod']

${locator.tenderPeriod.endDate}    xpath=//input[@name='tenderPeriodEndDate']
${locator.value.valueAddedTaxIncluded}    id=lblPDV
${locator.value.valueCurrencyTender}    id=currencyTender
${locator.items[0].deliveryLocation.latitude}    id=qdelivlatitude
${locator.items[0].deliveryLocation.longitude}    id=qdelivlongitude
${locator.items[0].deliveryAddress.postalCode}    id=qdelivaddrpost_code
${locator.items[0].deliveryAddress.countryName}    id=qdelivaddrcountry
${locator.items[0].deliveryAddress.locality}    id=qdeliv_addr_locality
${locator.items[0].deliveryAddress.streetAddress}    id=qdeliv_addrstreet
${locator.items[0].classification.scheme}    id=scheme2015
${locator.items[0].classification.id}    id=cpv_code
${locator.items[0].classification.description}    id=cpv_name
${locator.items[0].additionalClassifications[0].scheme}    id=scheme2010
${locator.items[0].additionalClassifications[0].id}    id=qdkpp_code
${locator.items[0].additionalClassifications[0].description}    id=qdkpp_name
${locator.items[0].description}    id=descriptionTenderItem
${locator.questions[0].title}    id=questionTitlespan1
${locator.questions[0].description}    id=titleQuestion
${locator.questions[0].date}    xpath=//span[@class="acc-date"]
${locator.items[0].deliveryDate.endDate}    id=ddto
${locator.value.currency}    id=lblTenderCurrency2
${locator.items[0].deliveryAddress.region}    id=qdeliv_addr_region
${locator.items[0].unit.code}    id=measure_prozorro_code
${locator.items[0].unit.name}    id=measure_name
${locator.items[0].quantity}    id=quantity
${locator.questions[0].answer}    id=answer

*** Keywords ***
Підготувати дані для оголошення тендера
    [Arguments]    ${username}    ${tender_data}
    ${tender_data}=    adapt_procuringEntity    ${tender_data}
    [Return]    ${tender_data}

Підготувати клієнт для користувача
    [Arguments]    @{ARGUMENTS}
    [Documentation]    [Documentation] \ Відкрити брaузер, створити обєкт api wrapper, тощо
    ...    ... \ \ \ \ \ ${ARGUMENTS[0]} == \ username
    Open Browser    ${USERS.users['${ARGUMENTS[0]}'].homepage}    ${USERS.users['${ARGUMENTS[0]}'].browser}    alias=${ARGUMENTS[0]}
    Set Window Size    @{USERS.users['${ARGUMENTS[0]}'].size}
    Set Window Position    @{USERS.users['${ARGUMENTS[0]}'].position}
    Run Keyword If    '${ARGUMENTS[0]}'!= 'epu_Viewer'    Login    @{ARGUMENTS}

Можливість додати тендерну документацію
    [Tags]    ${USERS.users['${tender_owner}'].broker}: Можливість завантажити документ
    [Documentation]   Закупівельник   ${USERS.users['${tender_owner}'].broker}  завантажує документацію  до  оголошеної закупівлі
    ${filepath}=   create_fake_doc
    ${doc_upload_reply}=  Викликати для учасника   ${tender_owner}   Завантажити документ  ${filepath}  ${TENDER['TENDER_UAID']}
    ${file_upload_process_data} =  Create Dictionary   filepath=${filepath}  doc_upload_reply=${doc_upload_reply}
    log  ${file_upload_process_data}
    Set To Dictionary  ${USERS.users['${tender_owner}']}   file_upload_process_data   ${file_upload_process_data}
    Log  ${USERS.users['${tender_owner}']}

Створити тендер
    [Arguments]    @{ARGUMENTS}
    [Documentation]    [Documentation]
    ...    ... \ \ \ \ \ ${ARGUMENTS[0]} == \ username
    ...    ... \ \ \ \ \ ${ARGUMENTS[1]} == \ tender_data
    Switch Browser    ${ARGUMENTS[0]}
    Return From Keyword If    '${ARGUMENTS[0]}' != 'epu_Owner'
    ${tender_data}=    Get From Dictionary    ${ARGUMENTS[1]}    data
    #
    Click Element    ${locator.toTenderMenu}
    sleep    3
    Click Element    ${locator.buttonTenderAdd}
    TenderInfo    ${tender_data}
    \    #
    Run Keyword If    '${TEST NAME}' == 'Можливість оголосити мультилотовий тендер'    Click Element    id=check-lots
    Заповнити дати тендеру    ${tender_data.enquiryPeriod}    ${tender_data.tenderPeriod}
    \    #
    sleep    1
    \    # Click Button    ${locator.tenderAdd}
    \    #
    Execute Javascript    window.scroll(1500,1500)
    Capture Page Screenshot
    Run Keyword If    '${TEST NAME}' == 'Можливість оголосити однопредметний тендер'    Додати предмет    ${tender_data}    0    0
    Run Keyword If    '${TEST NAME}' == 'Можливість оголосити багатопредметний тендер'    Додати багато предметів    ${tender_data}
    Run Keyword If    '${TEST NAME}' == 'Можливість оголосити мультилотовий тендер'    Додати багато лотів    ${tender_data}
    \    #    #
    ${tender_UAid}=    Опублікувати тендер
    Reload Page
    [Return]    ${tender_UAid}

Завантажити документ
    [Arguments]  ${username}  ${filepath}  ${tender_uaid}
    Switch Browser  ${username}
    Go to  ${USERS.users['${username}'].homepage}
    Click Element  id=editTender
    Click Button  ${locator.stepOne}
    Click Button  ${locator.stepTwo}
    Click Button  ${locator.stepThree}
    Click Button  id=openDocumentUpload
    Choose File  xpath=//input[@name='userfile']  ${filepath}
    Click Button  id=uploadFileTender_button
    Click Button  id=published

Завантажити документ в лот
    [Arguments]    ${username}    ${filepath}    ${TENDER_UAID}    ${lot_id}
    epu.Пошук тендера по ідентифікатору    ${username}    ${TENDER_UAID}
    Log To Console    ${filepath}
    Click Button    ButtonTenderEdit
    Click Element    addFile
    Select From List By Label    category_of    Документи закупівлі
    Select From List By Label    file_of    лоту
    Wait Until Element Is Enabled    id=FileComboSelection2
    Log To Console    ${lot_id}
    #Select From List By Label    id=FileComboSelection2    ${lot_id}
    Choose File    id=TenderFileUpload    ${filepath}
    Click Link    id=lnkDownload
    Wait Until Element Is Enabled    addFile

Пошук тендера по ідентифікатору
    [Arguments]    ${username}    ${tender_UAid}
    [Documentation]    ${ARGUMENTS[0]} == username
    Run Keyword And Return If    '${username}' == 'epu_Viewer'    SearchIdViewer    ${tender_UAid}    ${username}
    Go To    https://epu.com.ua/
    sleep    25
    Execute Javascript    window.scroll(1500,900)
    sleep    2
    Input text    id=inputSearch    ${tender_UAid}
    Click Button    id=btnSearch
    Click Element    id=title-head-tender-search
    sleep    5
    [Return]    ${tender_UAid}

Подати цінову пропозицію
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tenderId
    ...    ${ARGUMENTS[2]} == ${test_bid_data}
    Switch Browser    ${ARGUMENTS[0]}
    epu.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Reload Page
    Click Element    id=toBids
    ${amount}=    Get From Dictionary    ${ARGUMENTS[2].data.value}    amount
    Input Text    id=amountBid    ${amount}
    Click Element    id=check1
    Click Element    id=check2
    Click Element    id=check3
    Click Element    id=sendBid
    sleep    2
    Reload Page
    ${resp}=    Get Value    id=my_bid_id
    [Return]    ${resp}

Додати предмет закупівлі
    [Arguments]    ${username}    ${tenderID}    ${item}
    epu.Пошук тендера по ідентифікатору    ${username}    ${tenderID}
    Wait Until Page Contains Element    id=ButtonTenderEdit
    Click Element    id=ButtonTenderEdit
    Додати предмет    ${item}    0    0
    Click Element    id=btnPublishTop

Видалити предмет закупівлі
    epu.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Wait Until Page Contains Element    id=ButtonTenderEdit    10
    Click Element    id=ButtonTenderEdit
    : FOR    ${INDEX}    IN RANGE    1    ${ARGUMENTS[2]}-1
    \    sleep    5
    \    Click Element    xpath=//a[@class='deleteMultiItem'][last()]
    \    sleep    5
    \    Click Element    xpath=//a[@class='jBtn green']
    Wait Until Page Contains Element    id=AddItemButton    30
    Click Element    id=AddItemButton

Скасувати цінову пропозицію
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == none
    ...    ${ARGUMENTS[2]} == tenderId
    Switch Browser    ${ARGUMENTS[0]}
    epu.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Wait Until Page Contains    Прийом пропозицій    10
    Click Element    id=tab3
    Wait Until Element Is Enabled    id=btnDeleteBid
    Click Element    id=btnDeleteBid
    Wait Until Page Contains Element    id=addBidButton

Login
    [Arguments]    @{ARGUMENTS}
    Wait Until Element Is Visible    ${locatot.cabinetEnter}    10
    Click Element    ${locatot.cabinetEnter}
    Wait Until Element Is Visible    ${locator.emailField}    10
    Input Text    ${locator.emailField}    ${USERS.users['${ARGUMENTS[0]}'].login}
    sleep    2
    Input Text    ${locator.passwordField}    ${USERS.users['${ARGUMENTS[0]}'].password}
    sleep    2
    Click Element    ${locator.loginButton}

Оновити сторінку з тендером
    [Arguments]    @{ARGUMENTS}
    [Documentation]    [Documentation]
    ...    ... \ \ \ \ \ ${ARGUMENTS[0]} = \ username
    ...    ... \ \ \ \ \ ${ARGUMENTS[1]} = \ ${TENDER_UAID}
    Switch Browser    ${ARGUMENTS[0]}
    Reload Page

Відображення бюджету оголошеного тендера
    ${return_value}=    Отримати текст із поля і показати на сторінці    id=edtTenderBudget

Отримати інформацію із тендера
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == fieldname
    Switch browser    ${ARGUMENTS[0]}
    Run Keyword And Return    Отримати інформацію про ${ARGUMENTS[1]}

Отримати текст із поля і показати на сторінці
    [Arguments]    ${fieldname}
    sleep    3
    Wait Until Page Contains Element    ${locator.${fieldname}}    22
    Sleep    2
    ${return_value}=    Get Text    ${locator.${fieldname}}
    [Return]    ${return_value}

Відображення заголовку однопредметного тендера
    ${return_value}=   Get Text  id=headerTitle
    [return]  ${return_value}

Відображення опису однопредметного тендера
    ${return_value}=   Get Text  id=descriptionTenderItem
    [return]  ${return_value}

Відображення бюджету однопредметного тендера
    ${return_value}=  Get Text  id=amountTender
    Log  ${return_value}
    ${return_value}=   Convert To Number   ${return_value}
    [return]  ${return_value}

Відображення валюти однопредметного тендера
    ${return_value}=   Get Value  id=currencyTender
    Log  ${return_value}
    ${return_value}=   Convert To String  UAH
    [return]  ${return_value}

Отримати інформацію про value.valueAddedTaxIncluded
    ${return_value}=   Convert To Boolean   ${True}
    [Return]    ${return_value}

Відображення tenderID однопредметного тендера
    ${return_value}=  Get Text  ${locator.tenderID}
    ${return_value}=  Convert To String  ${return_value}
    [return]  ${return_value}

Отримати інформацію про procuringEntity.name
    ${return_value}=    Get Text  id=procuringEntity_name
    ${return_value}=  Convert To String  ${return_value}
    [Return]    ${return_value}

Відображення початку періоду уточнення однопредметного тендера
    ${return_value}=    Get Text  id=enquiryPeriod_start
    ${return_value}=    epu_service.parse_date    ${return_value}
    [Return]    ${return_value}

Відображення закінчення періоду уточнення однопредметного тендера
    ${return_value}=    Get Text  id=enquiryPeriod_end
    ${return_value}=    epu_service.parse_date    ${return_value}
    [Return]    ${return_value}

Відображення початку періоду прийому пропозицій однопредметного тендера
    ${return_value}=    Get Text  id=tenderPeriod_start
    ${return_value}=    epu_service.parse_date    ${return_value}
    [Return]    ${return_value}

Відображення закінчення періоду прийому пропозицій однопредметного тендера
    ${return_value}=    Get Text  id=tenderPeriod_end
    ${return_value}=    epu_service.parse_date    ${return_value}
    [Return]    ${return_value}

Відображення мінімального кроку однопредметного тендера
    ${return_value}=    Get Text  id=minimalStep
    ${return_value}=    Convert To Number    ${return_value}
    [Return]    ${return_value}

Відображення дати доставки номенклатури однопредметного тендера
    Capture Page Screenshot
    ${return_value}=    Get Text  id=deliveryDate_end
    ${return_value}=    epu_service.parse_date    ${return_value}
    [Return]    ${return_value}

Відображення назви нас. пункту доставки номенклатури однопредметного тендера
    ${return_value}=    Get Text  id=countryDelivery
    ${return_value}=    Convert To String    ${return_value}
    [Return]    ${return_value}

Відображення пошт. коду доставки номенклатури однопредметного тендера
    ${return_value}=    Get Text  id=postalcodeDelivery
    ${return_value}=    Convert To String    ${return_value}
    [Return]    ${return_value}

Відображення регіону доставки номенклатури однопредметного тендера
    ${return_value}=    Get Text  id=regionDelivery
    ${return_value}=    Convert To String    ${return_value}
    [Return]    ${return_value}

Відображення locality адреси доставки номенклатури однопредметного тендера
    ${return_value}=    Get Text  id=localityDelivery
    ${return_value}=    Convert To String    ${return_value}
    [Return]    ${return_value}

Відображення вулиці доставки номенклатури однопредметного тендера
    ${return_value}=    Get Text  id=streetAddress
    ${return_value}=    Convert To String    ${return_value}
    [Return]    ${return_value}

Отримати інформацію про items[0].classification.scheme
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].classification.scheme
    ${return_value}=    Remove String    ${return_value}    :
    [Return]    ${return_value}

Отримати інформацію про items[0].classification.id
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].classification.id
    [Return]    ${return_value}

Отримати інформацію про items[0].classification.description
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].classification.description
    [Return]    ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].scheme
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].additionalClassifications[0].scheme
    ${return_value}=    Remove String    ${return_value}    :
    [Return]    ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].id
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].additionalClassifications[0].id
    [Return]    ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].description
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].additionalClassifications[0].description
    [Return]    ${return_value}

Отримати інформацію про items[0].unit.name
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].unit.name
    [Return]    ${return_value}

Отримати інформацію про items[0].unit.code
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].unit.code
    [Return]    ${return_value}

Отримати інформацію про items[0].quantity
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].quantity
    ${return_value}=    Convert To Integer    ${return_value}
    [Return]    ${return_value}

Отримати інформацію про items[0].description
    [Arguments]    @{ARGUMENTS}
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].description
    [Return]    ${return_value}

Задати питання
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tenderUaId
    ...    ${ARGUMENTS[2]} == questionId
    ${title}=    Get From Dictionary    ${ARGUMENTS[2].data}    title
    ${description}=    Get From Dictionary    ${ARGUMENTS[2].data}    description
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    epu.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    sleep    2
    Click Element    id=toQuestions
    Click Button    id=addQuestButton
    Input text    id=question-theme    ${title}
    Input text    id=descriptionQuestion    ${description}
    sleep    2
    Click Element    id=sendButton
    Wait Until Page Contains    ${title}    10
    Capture Page Screenshot

Отримати інформацію про questions[0].title
    sleep    200
    Click Element    id=toQuestions
    sleep    2
    Click Button    id=viewQuestionAccordion
    sleep    2
    ${return_value}=    Get Text    id=titleQuestion
    [Return]    ${return_value}

Отримати інформацію про questions[0].description
    sleep    2
    ${return_value}=    Get Text    id=questionDescription
    [Return]    ${return_value}

Отримати інформацію про questions[0].date
    ${return_value}=    Get Text    id=dateQuestion
    [Return]    ${return_value}

Відповісти на питання
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} = username
    ...    ${ARGUMENTS[1]} = tenderUaId
    ...    ${ARGUMENTS[2]} = 0
    ...    ${ARGUMENTS[3]} = answer_data
    sleep    60
    Reload Page
    ${answer}=    Get From Dictionary    ${ARGUMENTS[3].data}    answer
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    epu.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Click Element    id=toQuestions
    Sleep    2
    Click Button    id=viewQuestionAccordion
    Sleep    2
    Input text    answerArea    ${answer}
    Click Element    id=answerButton
    Sleep    2
    Reload Page
    Capture Page Screenshot

Змінити цінову пропозицію
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tenderId
    ...    ${ARGUMENTS[2]} == amount
    ...    ${ARGUMENTS[3]} == amount.value
    sleep    5
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    epu.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Click Element    id=tab3
    Click Element    id=btnDeleteBid
    Clear Element Text    id=editBid
    Input Text    id=editBid    ${ARGUMENTS[3]}
    sleep    3
    Click Element    id=addBidButton
    Wait Until Page Contains    Ви подали пропозицію. Очікуйте посилання на аукціон.

Внести зміни в тендер
    [Arguments]    @{ARGUMENTS}
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    Click Element    id=editTender
    Sleep    2
    Input text    xpath=//input[@name='title']    ${ARGUMENTS[2]}
    Sleep    2
    Click Button    ${locator.stepOne}
    Click Button    ${locator.stepTwo}
    Click Button    ${locator.stepThree}
    Click Button    id=published
    Sleep    60
    Click Element    id=btnView
    Capture Page Screenshot

Отримати інформацію про questions[0].answer
    sleep    150
    Click Button    id=viewQuestionAccordion
    sleep    2
    ${return_value}=    Get Text    id=answer
    [Return]    ${return_value}

Завантажити документ в ставку
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[1]} == file
    ...    ${ARGUMENTS[2]} == tenderId
    sleep    10
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    Click Element    ${locatorDeals}
    Sleep    2
    Choose File    id=BidFileUpload    ${ARGUMENTS[1]}
    sleep    2
    Click Element    xpath=.//*[@id='lnkDownload'][@class="btn btn-success"]

Змінити документ в ставці
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == file
    ...    ${ARGUMENTS[2]} == tenderId
    sleep    10
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    Sleep    2
    Click Element    id=deleteBidFileButton
    Click Element    id=Button6
    sleep    2
    Choose File    id=BidFileUpload    ${ARGUMENTS[1]}
    sleep    5
    Reload Page
    Click Element    xpath=.//*[@id='lnkDownload'][@class="btn btn-success"]

Отримати посилання на аукціон для глядача
    [Arguments]    @{ARGUMENTS}
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    epu.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Wait Until Page Contains    Аукціон    5
    ${url} =    Get Element Attribute    xpath=//a[@id="a_auction_url"]@href
    [Return]    ${url}

Отримати посилання на аукціон для учасника
    [Arguments]    @{ARGUMENTS}
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    Click Element    xpath=//div[@id='bs-example-navbar-collapse-1']/div/div/a/img[2]
    Sleep    2
    Clear Element Text    id=topsearch
    Click Element    id=inprogress
    Input Text    id=topsearch    ${ARGUMENTS[1]}
    Click Element    id=btnSearch
    Click Element    xpath=//p[@class='cut_title']
    Capture Page Screenshot
    ${url}=    Get Element Attribute    xpath=//a[@id="labelAuction2"]@href
    [Return]    ${url}

Отримати інформацію про status
    Reload Page
    Sleep    5
    ${value}=    Get Text    id=status_tender
    # Provider
    Run Keyword And Return If    '${TEST NAME}' == 'Можливість подати цінову пропозицію першим учасником'    Active.tendering_provider    ${value}
    Run Keyword And Return If    '${TEST NAME}' == 'Можливість подати повторно цінову пропозицію першим учасником'    Active.tendering_provider    ${value}
    Run Keyword And Return If    '${TEST NAME}' == 'Можливість вичитати посилання на участь в аукціоні для першого учасника'    Active.auction_viewer    ${value}
    # Viewer
    Run Keyword And Return If    '${TEST NAME}' == 'Можливість вичитати посилання на аукціон для глядача'    Active.auction_viewer    ${value}
    [Return]    ${return_value}

Active.tendering_provider
    [Arguments]    ${value}
    Sleep    60
    ${return_value}=    Replace String    ${value}    Прийом пропозицій    active.tendering
    [Return]    ${return_value}

Active.auction_viewer
    [Arguments]    ${value}
    Sleep    60
    ${return_value}=    Replace String    ${value}    Аукціон    active.auction
    [Return]    ${return_value}

Створити лот
    [Arguments]    ${username}    ${tender_uaid}    ${lot}
    epu.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Click Button    ButtonTenderEdit
    Click Element    id=AddLot
    ${txt_title}=    Get From Dictionary    ${lot.data}    title
    Input Text    lot_name    ${txt_title}
    ${txt}=    Get From Dictionary    ${lot.data}    description
    Input Text    lot_description    ${txt}
    ${txt}=    Get From Dictionary    ${lot.data.value}    amount
    ${txt}=    Convert To String    ${txt}
    Input Text    lot_budget    ${txt}
    ${txt}=    Get From Dictionary    ${lot.data.minimalStep}    amount
    ${txt}=    Convert To String    ${txt}
    Input Text    lot_auction_min_step    ${txt}
    Click Element    id=button_add_lot

Видалити лот
    [Arguments]    ${username}    ${tender_uaid}    ${lot_id}
    epu.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Click Element    xpath=.//*[@id='headingThree']/h4/div[1]/div[2]/p/b[contains(text(), "${lot_id}")]
    sleep    2
    Click Element    xpath=.//div/div/div[2]/div[2]/a
    sleep    3
    Input Text    id=reason_lot_cancel    Відміна лота
    Click Element    id=Button3

Змінити лот
    [Arguments]    ${username}    ${tender_uaid}    ${lot_id}    ${fieldname}    ${fieldvalue}
    Switch Browser    ${username}
    epu.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Click Button    ButtonTenderEdit
    Execute Javascript    window.scroll(1500,1500)
    sleep    3
    Click Element    xpath=.//*[@id='headingThree']/h4/div[1]/div[2]/p/b[contains(text(), "${lot_id}")]
    Click Element    ${lot.btnEditEdt}
    Wait Until Element Is Visible    xpath=.//*[@id='button_delete_lot']
    Input Text    id=lot_description    ${fieldvalue}
    Click Element    id=button_add_lot

Додати предмет закупівлі в лот
    [Arguments]    ${username}    ${tender_uaid}    ${lot_id}    ${item}
    epu.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Click Button    ButtonTenderEdit
    Додати предмет    ${item}    0    ${lot_id}

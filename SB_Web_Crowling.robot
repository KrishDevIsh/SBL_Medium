*** Settings ***
Documentation       SBL Web Crowling

Library             RPA.Browser.Selenium    auto_close=${FALSE}
#Library    RPA.Windows
Library             RPA.FileSystem
Library             RPA.Tables
Library             Collections
Library             String
Library             RPA.HTTP


*** Variables ***
${ReferenceNumber}
${ImageTitle}
${CreationDate}
${LevelOfDescription}
${ExtentAndMedium}
${NameOfCreator}
${Repository}
${OccupationOrRole}
${Age}
${Gender}
${DateOfAdmission}
${DateOfdeath}
${DiseaseTranscribed}
${DiseaseStandardised}
${AdmittedUnderTheCareOf}
${MedicalExaminationPerformedBy}
${PostMortemExaminationPerformedBy}
${MedicalNotes}
${Bodypartsexaminedinthepostmortem}
${TypeOfIncident}
${ConditionsGoverningReproduction}
${languageOfMaterial}
${AlternativeIdentifier}
${FileName}
${RecordURL}
${SuccessStatus}                        Success


*** Keywords ***
SBL Web Crowling Process
    #Create Output directory
    ${Status}    ${Out}    Run Keyword And Ignore Error    Does Directory Exist    Output${/}
    IF    ${Out} == ${False}    Create Directory    Output${/}

    #Deleting all files from the output directory
    ${Status}    ${Out}    Run Keyword And Ignore Error    Clear Output Directory
    IF    '${Status}' == 'FAIL'
        ${SuccessStatus}    Set Variable    ${Out}
    END

    #Launch SBL Website
    ${Status}    ${Out}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds
    ...    5
    ...    5
    ...    Launch SBL Website
    IF    '${Status}' == 'FAIL'
        ${SuccessStatus}    Set Variable    ${Out}
    END

    #Click view button
    #${Status}    ${Out}    Run Keyword And Ignore Error
    #...    Wait Until Keyword Succeeds
    #...    5
    #...    5
    #...    Click on View button
    #IF    '${Status}' == 'FAIL'
    #    ${SuccessStatus}    Set Variable    ${Out}
    #END

    #Get Total number of Pages
    ${Status}    ${Pages}    Run Keyword And Ignore Error    Get The File count
    IF    '${Status}' == 'FAIL'
        ${SuccessStatus}    Set Variable    ${Pages}
    END

    #Get Total number of Images within the page
    ${Status}    ${TotalImageCount}    Run Keyword And Ignore Error    Get count of Images in a page
    IF    '${Status}' == 'FAIL'
        ${SuccessStatus}    Set Variable    ${TotalImageCount}
    END

    #Create column name as a list
    ${ColoumnName}    Create List
    ...    Reference_Number
    ...    Title
    ...    CreationDate
    ...    LevelOfDescription
    ...    ExtentAndMedium
    ...    NameOfCreator
    ...    Repository
    ...    Occupation_or_role
    ...    Age
    ...    Gender
    ...    Date_of_admission
    ...    Date_of_death
    ...    Disease_transcribed
    ...    Disease_standardised
    ...    Admitted_under_the_care_of
    ...    Medical_examination_performed_by
    ...    Post_mortem_examination_performed_by
    ...    Medical_notes
    ...    Body_parts_examined_in_the_post_mortem
    ...    Type_of_incident
    ...    ConditionsGoverningReproduction
    ...    LanguageOfMaterial
    ...    AlternativeIdentifier
    ...    FileName
    ...    Record_URL
    ...    Status

    #Create Table
    ${ImagePropertyTable}    Create Table    columns=${ColoumnName}

    #Start the loop for each page
    FOR    ${counter}    IN RANGE    0    2
        #${Pages}+1
        #Loop for each image
        FOR    ${Imagecounter}    IN RANGE    1    2    #${TotalImageCount}+1
            ${SuccessStatus}    Set Variable    Success
            #Get Record URL of the Image
            ${Status}    ${RecordURL}    Run Keyword And Ignore Error    Get RecordURL    ${Imagecounter}
            IF    '${Status}' == 'FAIL'
                ${SuccessStatus}    Set Variable    ${RecordURL}
            END

            #Click to the image
            ${Status}    ${out}    Run Keyword And Ignore Error    Select Image To Get Properties    ${Imagecounter}
            IF    '${Status}' == 'FAIL'
                ${SuccessStatus}    Set Variable    ${out}
            END

            ${handles}    Get Window Handles
            Switch Window    ${handles}[1]

            #Get all image properties
            ${Status}    ${PropertyDic}    Run Keyword And Ignore Error    Get Image Properties
            ...    ${Imagecounter}
            ...    ${RecordURL}

            IF    '${Status}' == 'FAIL'
                ${SuccessStatus}    Set Variable    ${PropertyDic}
            END

            #Save image to output directory
            ${Status}    ${Out}    Run Keyword And Ignore Error
            ...    Wait Until Keyword Succeeds
            ...    5
            ...    5
            ...    Save Image To Directory
            IF    '${Status}' == 'FAIL'
                ${SuccessStatus}    Set Variable    ${Out}
            END

            #Close the Active window and switch to Main window
            ${Status}    ${Out}    Run Keyword And Ignore Error
            ...    Close New Image Window and switch to main
            ...    ${handles}
            IF    '${Status}' == 'FAIL'
                ${SuccessStatus}    Set Variable    ${Out}
            END

            #Set exceptions to the dictionary
            Log    ${SuccessStatus}
            ${Status}    ${out}    Run Keyword And Ignore Error
            ...    Set To Dictionary
            ...    ${PropertyDic}
            ...    Status=${SuccessStatus}

            #Add Dictionary values to the table
            ${Status}    ${out}    Run Keyword And Ignore Error
            ...    Add Table Row
            ...    ${ImagePropertyTable}
            ...    ${PropertyDic}
        END

        #Click to Next button
        ${Status}    ${out}    Run Keyword And Ignore Error
        ...    Click to Next button
    END

    #Write the table to CSV
    Write table to CSV    ${ImagePropertyTable}    Output${/}Output.csv    delimiter=|
    [Teardown]    Close Browser

Launch SBL Website
    Open Available Browser
    ...    https://archives.sgul.ac.uk/informationobject/browse?collection=25712&topLod=0&view=card&onlyMedia=1
    Maximize Browser Window
    #${IsWebsiteOPen}    Does Page Contain Element    xpath=//*[@id="content"]
    #RETURN    ${IsWebsiteOPen}

Get The File count
    ${TotalPages}    Get Element Attribute
    ...    xpath=*//div[@class="pagination pagination-centered"]//li[@class="last"]/a
    ...    text
    RETURN    ${TotalPages}

Click to Next button
    Wait Until Element Is Visible    xpath=*//div[@class="pagination pagination-centered"]//li[@class="next"]/a
    Wait Until Keyword Succeeds    5    5    Click Element When Visible
    ...    xpath=*//div[@class="pagination pagination-centered"]//li[@class="next"]/a

Click on View button
    Wait Until Element Is Visible    xpath=*//span/div[@class="btn-group"]/a
    Click Element When Visible    xpath=*//span/div[@class="btn-group"]/a
    #${ClassActive}    Get Element Attribute    xpath=*//span/div[@class="btn-group"]/a    class
    #${IsClassActive}    Run Keyword And Return Status    Should Contain    ${ClassActive}    active
    #IF    ${IsClassActive} == ${True}
    #    RETURN    ${True}
    #ELSE
    #    RETURN    ${False}
    #END

Select Image To Get Properties
    [Arguments]    ${ImageNumber}
    Wait Until Element Is Visible    xpath=//*[@id="content"]/section/div[${ImageNumber}]
    Click Element When Visible    xpath=//*[@id="content"]/section/div[${ImageNumber}]    CTRL
    #Switch Window    new
    #Wait Until Element Is Enabled    xpath=*//section[@id="identityArea"]

Close New Image Window and switch to main
    [Arguments]    ${Handles}
    Close Window
    Switch Window    ${Handles}[0]

Get Image Properties
    [Arguments]    ${ImageNumber}    ${RecordURL}
    Wait Until Keyword Succeeds    10    5    Wait Until Element Is Visible    xpath=*//section[@id="identityArea"]
    ${Status}    ${ReferenceNumber}    Get Reference Number
    ${Status}    ${ImageTitle}    Get Image Title
    ${Status}    ${CreationDate}    Get Creation Date
    ${Status}    ${LevelOfDescription}    Get Level Of description
    ${Status}    ${ExtentAndMedium}    Get Extent and medium
    ${NameOfCreator}    Get Name Of Creator
    ${Status}    ${Repository}    Get Repository
    Wait Until Keyword Succeeds    5    5    Click to Enlarge Button
    #${Status}    ${ScopeAndContent}    Get Scope and condent
    ${Status}    ${ConditionsGoverningReproduction}    Get condition governing Reproduction
    ${Status}    ${LanguageOfMaterial}    Get Language Of Material
    ${AlternativeIdentifier}    Get Alternative Identifier
    ${Status}    ${FileName}    Get File Name
    ${OccupationOrRole}
    ...    ${Age}
    ...    ${Gender}
    ...    ${DateOfAdmission}
    ...    ${DateOfdeath}
    ...    ${DiseaseTranscribed}
    ...    ${DiseaseStandardised}
    ...    ${AdmittedUnderTheCareOf}
    ...    ${MedicalExaminationPerformedBy}
    ...    ${PostMortemExaminationPerformedBy}
    ...    ${MedicalNotes}
    ...    ${Bodypartsexaminedinthepostmortem}
    ...    ${TypeOfIncident}    Variable Reintialize

    ${OccupationOrRole}
    ...    ${Age}
    ...    ${Gender}
    ...    ${DateOfAdmission}
    ...    ${DateOfdeath}
    ...    ${DiseaseTranscribed}
    ...    ${DiseaseStandardised}
    ...    ${AdmittedUnderTheCareOf}
    ...    ${MedicalExaminationPerformedBy}
    ...    ${PostMortemExaminationPerformedBy}
    ...    ${MedicalNotes}
    ...    ${Bodypartsexaminedinthepostmortem}
    ...    ${TypeOfIncident}    Get Scope And Content Property

    &{ImageProperties}    Create Dictionary

    Set To Dictionary    ${ImageProperties}
    ...    Reference_Number=${ReferenceNumber}
    ...    Title=${ImageTitle}
    ...    CreationDate=${CreationDate}
    ...    LevelOfDescription=${LevelOfDescription}
    ...    ExtentAndMedium=${ExtentAndMedium}
    ...    NameOfCreator=${NameOfCreator}
    ...    Repository=${Repository}
    ...    Occupation_or_role=${OccupationOrRole}
    ...    Age=${Age}
    ...    Gender=${Gender}
    ...    Date_of_admission=${DateOfAdmission}
    ...    Date_of_death=${DateOfdeath}
    ...    Disease_transcribed=${DiseaseTranscribed}
    ...    Disease_standardised=${DiseaseStandardised}
    ...    Admitted_under_the_care_of=${AdmittedUnderTheCareOf}
    ...    Medical_examination_performed_by=${MedicalExaminationPerformedBy}
    ...    Post_mortem_examination_performed_by=${PostMortemExaminationPerformedBy}
    ...    Medical_notes=${MedicalNotes}
    ...    Body_parts_examined_in_the_post_mortem=${Bodypartsexaminedinthepostmortem}
    ...    Type_of_incident=${TypeOfIncident}
    ...    ConditionsGoverningReproduction=${ConditionsGoverningReproduction}
    ...    LanguageOfMaterial=${languageOfMaterial}
    ...    AlternativeIdentifier=${AlternativeIdentifier}
    ...    FileName=${FileName}
    ...    Record_URL=${RecordURL}

    RETURN    ${ImageProperties}

Click to Enlarge Button
    ${Status}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds
    ...    5
    ...    5
    ...    Click Element When Visible
    ...    xpath=//*[@id="contentAndStructureArea"]//span[@class="read-more"]/a
    IF    '${Status}' == 'FAIL'
        ${Status}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    xpath=//*[@id="contentAndStructureArea"]/div/div/div[2]/p
    END
    IF    '${Status}' == 'PASS'
        Click Element When Visible    xpath=//*[@id="contentAndStructureArea"]/div/div/div[2]/p
    END

Get count of Images in a page
    Wait Until Element Is Visible    //*[@id="main-column"]//section/div[@class="result-count"]
    ${TotalImagesText}    Get Text
    ...    xpath=//*[@id="main-column"]//section/div[@class="result-count"]
    ${SubImageText}    Get Substring    ${TotalImagesText}    7
    ${SplitImage}    Split String    ${SubImageText}    separator=of
    ${SplitImage}    Split String    ${SplitImage}[0]    separator=to
    ${ImageCount}    Set Variable    ${${SplitImage}[1]-(${SplitImage}[0]-1)}
    RETURN    ${ImageCount}

Save Image To Directory
    ${URLOfImage}    Wait Until Keyword Succeeds
    ...    10
    ...    5
    ...    Get Element Attribute
    ...    xpath=//*[@id="content"]/div[@class="digital-object-reference"]/a
    ...    href
    Wait Until Keyword Succeeds    10    5    Download    ${URLOfImage}    Output${/}    overwrite=${True}

Get RecordURL
    [Arguments]    ${ImageNumber}
    Wait Until Element Is Visible    xpath=//*[@id="content"]/section/div[${ImageNumber}]/a
    ${RecordURL}    Get Element Attribute    xpath=//*[@id="content"]/section/div[${ImageNumber}]/a
    ...    href
    RETURN    ${RecordURL}

Get Name Of Creator
    ${Status1}    ${NameOfCreator1}    Run Keyword And Ignore Error    Get Element Attribute
    ...    xpath=//*[@id="contextArea"]/div[1]/div[1]/div/div[1]/a
    ...    text

    ${Status2}    ${NameOfCreator2}    Run Keyword And Ignore Error    Get Element Attribute
    ...    xpath=//*[@id="contextArea"]/div[1]/div[2]/div/div[1]/a
    ...    text

    IF    '${Status1}' == 'FAIL'
        ${NameOfCreator}    Set Variable    ${NameOfCreator2}
    ELSE
        ${NameOfCreator}    Set Variable    ${NameOfCreator1},${NameOfCreator2}
    END

    RETURN    ${NameOfCreator}

Get Reference Number
    ${Status}    ${ReferenceNumber}    Run Keyword And Ignore Error    RPA.Browser.Selenium.Get Text
    ...    xpath=*//section[@id="identityArea"]//div[@class="referenceCode"]
    RETURN    ${Status}    ${ReferenceNumber}

Get Image Title
    ${Status}    ${ImageTitle}    Run Keyword And Ignore Error
    ...    Get Text
    ...    xpath=*//section[@id="identityArea"]//div[@class="title"]
    RETURN    ${Status}    ${ImageTitle}

Get Creation Date
    ${Status}    ${CreationDate}    Run Keyword And Ignore Error    Get Text
    ...    xpath=*//section[@id="identityArea"]//div[@class="creationDates"]/ul/li
    RETURN    ${Status}    ${CreationDate}

Get Level Of description
    ${Status}    ${LevelOfDescription}    Run Keyword And Ignore Error    Get Text
    ...    xpath=*//section[@id="identityArea"]//div[@class="levelOfDescription"]/p
    RETURN    ${Status}    ${LevelOfDescription}

Get Extent and medium
    ${Status}    ${ExtentAndMedium}    Run Keyword And Ignore Error    Get Text
    ...    xpath=*//section[@id="identityArea"]//div[@class="extentAndMedium"]/p
    RETURN    ${Status}    ${ExtentAndMedium}

Get Repository
    ${Status}    ${Repository}    Run Keyword And Ignore Error    Get Element Attribute
    ...    xpath=*//section[@id="contextArea"]//div[@class="repository"]/div/div/a
    ...    text
    RETURN    ${Status}    ${Repository}

Get condition governing Reproduction
    ${Status}    ${ConditionsGoverningReproduction}    Run Keyword And Ignore Error    Get Text
    ...    xpath=//*[@id="conditionsOfAccessAndUseArea"]//div[@class="conditionsGoverningReproduction"]/p
    RETURN    ${Status}    ${ConditionsGoverningReproduction}

Get Language Of Material
    ${Status}    ${LanguageOfMaterial}    Run Keyword And Ignore Error    Get Text
    ...    xpath=//*[@id="conditionsOfAccessAndUseArea"]//div[@class="languageOfMaterial"]/ul/li
    RETURN    ${Status}    ${LanguageOfMaterial}

Get Alternative Identifier
    ${Status}    ${AlternativeIdentifier1}    Run Keyword And Ignore Error    Get Text
    ...    xpath=//*[@id="notesArea"]//div[@class="alternativeIdentifiers"]/div/div/div/h3
    ${Status}    ${AlternativeIdentifier2}    Run Keyword And Ignore Error    Get Text
    ...    xpath=//*[@id="notesArea"]//div[@class="alternativeIdentifiers"]/div/div/div/h3/following-sibling::div
    ${AlternativeIdentifier}    Set Variable    ${AlternativeIdentifier1}:${AlternativeIdentifier2}
    RETURN    ${AlternativeIdentifier}

Get File Name
    ${Status}    ${FileName}    Run Keyword And Ignore Error    Get Text
    ...    xpath=//*[@id="content"]//div[@class="filename"]/p
    RETURN    ${Status}    ${FileName}

Variable Reintialize
    RETURN
    ...    ${OccupationOrRole}
    ...    ${Age}
    ...    ${Gender}
    ...    ${DateOfAdmission}
    ...    ${DateOfdeath}
    ...    ${DiseaseTranscribed}
    ...    ${DiseaseStandardised}
    ...    ${AdmittedUnderTheCareOf}
    ...    ${MedicalExaminationPerformedBy}
    ...    ${PostMortemExaminationPerformedBy}
    ...    ${MedicalNotes}
    ...    ${Bodypartsexaminedinthepostmortem}
    ...    ${TypeOfIncident}

Get Scope and content Property
    FOR    ${counter}    IN RANGE    1    12
        ${Status}    ${ScopeAndContent}    Run Keyword And Ignore Error    RPA.Browser.Selenium.Get Text
        ...    xpath=//*[@id="contentAndStructureArea"]/div/div/div[2]/p[${counter}]
        IF    '${Status}' == 'PASS'
            ${LineCount}    Get Line Count    ${ScopeAndContent}
            FOR    ${counter}    IN RANGE    0    ${LineCount}
                ${ContainsString}    Set Variable    ${False}
                ${TestText}    Get Line    ${ScopeAndContent}    ${counter}
                ${ContainsString}    Run Keyword And Return Status
                ...    Should Contain
                ...    ${TestText}
                ...    Occupation or role
                IF    ${ContainsString} == ${True}
                    ${Splitrole}    Split String    ${TestText}    separator=:
                    ${OccupationOrRole}    Set Variable    ${Splitrole}[1]
                END
                ${ContainsString}    Run Keyword And Return Status    Should Contain    ${TestText}    Age
                IF    ${ContainsString} == ${True}
                    ${SplitAge}    Split String    ${TestText}    separator=:
                    ${Age}    Set Variable    ${SplitAge}[1]
                END
                ${ContainsString}    Run Keyword And Return Status    Should Contain    ${TestText}    Gender
                IF    ${ContainsString} == ${True}
                    ${SplitGender}    Split String    ${TestText}    separator=:
                    ${Gender}    Set Variable    ${SplitGender}[1]
                END
                ${ContainsString}    Run Keyword And Return Status
                ...    Should Contain
                ...    ${TestText}
                ...    Date of admission
                IF    ${ContainsString} == ${True}
                    ${SplitDateOfAdmission}    Split String    ${TestText}    separator=:
                    ${DateOfAdmission}    Set Variable    ${SplitDateOfAdmission}[1]
                END
                ${ContainsString}    Run Keyword And Return Status    Should Contain    ${TestText}    Date of death
                IF    ${ContainsString} == ${True}
                    ${SplitDateOfdeath}    Split String    ${TestText}    separator=:
                    ${DateOfdeath}    Set Variable    ${SplitDateOfdeath}[1]
                END
                ${ContainsString}    Run Keyword And Return Status
                ...    Should Contain
                ...    ${TestText}
                ...    Disease (transcribed)
                IF    ${ContainsString} == ${True}
                    ${SplitDiseaseTranscribed}    Split String    ${TestText}    separator=:
                    ${DiseaseTranscribed}    Set Variable    ${SplitDiseaseTranscribed}[1]
                END
                ${ContainsString}    Run Keyword And Return Status
                ...    Should Contain
                ...    ${TestText}
                ...    Disease (standardised)
                IF    ${ContainsString} == ${True}
                    ${SplitDiseaseStandardised}    Split String    ${TestText}    separator=:
                    ${DiseaseStandardised}    Set Variable    ${SplitDiseaseStandardised}[1]
                END
                ${ContainsString}    Run Keyword And Return Status
                ...    Should Contain
                ...    ${TestText}
                ...    Admitted under the care of
                IF    ${ContainsString} == ${True}
                    ${SplitAdmittedUnderTheCareOf}    Split String    ${TestText}    separator=:
                    ${AdmittedUnderTheCareOf}    Set Variable    ${SplitAdmittedUnderTheCareOf}[1]
                END
                ${ContainsString}    Run Keyword And Return Status
                ...    Should Contain
                ...    ${TestText}
                ...    Medical examination performed by
                IF    ${ContainsString} == ${True}
                    ${SplitMedicalExaminationPerformedBy}    Split String    ${TestText}    separator=:
                    ${MedicalExaminationPerformedBy}    Set Variable    ${SplitMedicalExaminationPerformedBy}[1]
                END
                ${ContainsString}    Run Keyword And Return Status
                ...    Should Contain
                ...    ${TestText}
                ...    Post mortem examination performed by
                IF    ${ContainsString} == ${True}
                    ${SplitPostMortemExaminationPerformedBy}    Split String    ${TestText}    separator=:
                    ${PostMortemExaminationPerformedBy}    Set Variable    ${SplitPostMortemExaminationPerformedBy}[1]
                END
                ${ContainsString}    Run Keyword And Return Status    Should Contain    ${TestText}    Medical notes
                IF    ${ContainsString} == ${True}
                    ${SplitMedicalNotes}    Split String    ${TestText}    separator=:
                    ${MedicalNotes}    Set Variable    ${SplitMedicalNotes}[1]
                END
                ${ContainsString}    Run Keyword And Return Status
                ...    Should Contain
                ...    ${TestText}
                ...    Body parts examined in the post mortem
                IF    ${ContainsString} == ${True}
                    ${SplitBodypartsexaminedinthepostmortem}    Split String    ${TestText}    separator=:
                    ${Bodypartsexaminedinthepostmortem}    Set Variable    ${SplitBodypartsexaminedinthepostmortem}[1]
                END
                ${ContainsString}    Run Keyword And Return Status
                ...    Should Contain
                ...    ${TestText}
                ...    Type of incident:
                IF    ${ContainsString} == ${True}
                    ${SplitTypeOfIncident}    Split String    ${TestText}    separator=:
                    ${TypeOfIncident}    Set Variable    ${SplitTypeOfIncident}[1]
                END
            END
        ELSE
            Continue For Loop
        END
    END
    RETURN
    ...    ${OccupationOrRole}
    ...    ${Age}
    ...    ${Gender}
    ...    ${DateOfAdmission}
    ...    ${DateOfdeath}
    ...    ${DiseaseTranscribed}
    ...    ${DiseaseStandardised}
    ...    ${AdmittedUnderTheCareOf}
    ...    ${MedicalExaminationPerformedBy}
    ...    ${PostMortemExaminationPerformedBy}
    ...    ${MedicalNotes}
    ...    ${Bodypartsexaminedinthepostmortem}
    ...    ${TypeOfIncident}

Clear Output Directory
    ${Files}    Wait Until Keyword Succeeds    5    5    List Files In Directory    Output${/}
    FOR    ${File}    IN    @{Files}
        Remove File    ${File}
    END

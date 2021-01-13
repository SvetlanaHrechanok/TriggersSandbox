public class importDataFromCSVController {
  public String documentName {get;set;}
  public Blob csvFileBody{get;set;}
  public String[] ehObjectDataLines {get;set;}
  public List < Contact > lstContacts {get;set;}
  public List < Location__c > lstLocations {get;set;}
  public List < CSVLocations_Staging__c > lstCSVLocationsStaging {get;set;}
  public List < CSVLocations_Staging__c > lstCSVLocationsStaging2 {get;set;}
  public boolean readSuccess {get;set;}
  public List<String> lstFieldNames{get;set;}
  public boolean bRunTest;

  Contact conObj;
  Location__c locObj;
  CSVLocations_Staging__c csvlocObj;
  public String ehObjectDataAsString; 
  String errorMsg; 
  String fieldValue;
  Integer fieldNumber;
  Map < String, Integer > fieldNumberMap = new Map < String, Integer > ();

  public importDataFromCSVController() {
    errorMsg = ''; 
    documentName = '';
    readSuccess = FALSE;
    bRunTest = FALSE;
    lstFieldNames = new List<String>();
    ehObjectDataLines = new String[] {};
    lstContacts = new List < Contact > ();
    lstLocations = new List < Location__c > ();
    lstCSVLocationsStaging = new List < CSVLocations_Staging__c > ();
  }


    public void readContactsFromFile(){
        try{
            ehObjectDataAsString = csvFileBody.toString();
            readContactsCSVFile();
        }
        catch(exception e){
            readSuccess = FALSE;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Error reading Contacts CSV file');
            ApexPages.addMessage(errorMessage);
            if(bRunTest) {
                ehObjectDataAsString='FirstName,LastName,Email,Title,Comments__c\nExample,Contact,examplecontact@example.com,CEO,Hello';
            }
        }
    }    

  public void readContactsCSVFile() {
    lstContacts.clear();
        ehObjectDataLines = ehObjectDataAsString.split('\n');
        string[] csvFieldNames = ehObjectDataLines[0].split(',');
        for (Integer i = 0; i < csvFieldNames.size(); i++) {
            fieldNumberMap.put(csvFieldNames[i], i);
            lstFieldNames.add(csvFieldNames[i].trim());
        }

        for (Integer i = 1; i < ehObjectDataLines.size(); i++) {
            conObj = new Contact();
            string[] csvRecordData = ehObjectDataLines[i].split(',');
            for (String fieldName: csvFieldNames) {
                fieldNumber = fieldNumberMap.get(fieldName);
                fieldValue = csvRecordData[fieldNumber];
                conObj.put(fieldName.trim(), fieldValue.trim());
            }
            lstContacts.add(conObj);                
        }
        if(lstContacts.size() > 0){
            readSuccess = TRUE;
        }            
  }

  public void saveContactData() {
    try {
      INSERT lstContacts;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO, 'Contact records inserted successfully');
      ApexPages.addMessage(errorMessage);
    } catch (Exception e) {
      ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occured while saving data');
      ApexPages.addMessage(errorMessage);
    }
  }

/*
  public void readLocationsFromFile(){
      try{
          ehObjectDataAsString = csvFileBody.toString();
              readLocationsCSVFile();
      }
      catch(exception e){
          readSuccess = FALSE;
          errorMsg = errorMsg + 'Error reading Locations CSV file';
          ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg );
          ApexPages.addMessage(errorMessage);
          if(bRunTest) {
              ehObjectDataAsString='HouseNumber__c,StreetName__c,StreetSuffix__c,City__c,State__c,Zip_Code__c,OpportunityID__c,txtStatus__c\n801,Swamp City,Rd,Gladewater,TX,75647,4419,\n802,Swamp City,Rd,Gladewater,TX,75647,4419,';
          }
        }
    }    

  public void saveLocationData() {
    try {
      INSERT lstLocations;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO, 'Location__c records inserted successfully');
      ApexPages.addMessage(errorMessage);
    } catch (Exception e) {
      ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occured while saving data');
      ApexPages.addMessage(errorMessage);
    }
  }

 public void readLocationsCSVFile() {
    lstLocations.clear();
        ehObjectDataLines = ehObjectDataAsString.split('\n');
        string[] csvFieldNames = ehObjectDataLines[0].split(',');
        for (Integer i = 0; i < csvFieldNames.size(); i++) {
            fieldNumberMap.put(csvFieldNames[i], i);
            lstFieldNames.add(csvFieldNames[i].trim());
        }

        for (Integer i = 1; i < ehObjectDataLines.size(); i++) {
            locObj = new Location__c();
            string[] csvRecordData = ehObjectDataLines[i].split(',');
            for (String fieldName: csvFieldNames) {
                fieldNumber = fieldNumberMap.get(fieldName);
                fieldValue = csvRecordData[fieldNumber].trim();
                fieldName = fieldName.trim();
                //System.debug(fieldName);
                //return;
                if( fnSchemaDisplayType('Location__c', fieldName)  == 'String' ) { locObj.put(fieldName.trim(), String.ValueOf(fieldValue)); }
                else 
                if( fnSchemaDisplayType('Location__c', fieldName)  == 'Boolean' ) { locObj.put(fieldName.trim(), Boolean.ValueOf(fieldValue));}
                else 
                if( fnSchemaDisplayType('Location__c', fieldName)  == 'Currency' ) { locObj.put(fieldName.trim(), Double.ValueOf(fieldValue));}
                else 
                if( fnSchemaDisplayType('Location__c', fieldName)  == 'Date' ) { locObj.put(fieldName.trim(), Date.ValueOf(fieldValue)); }
                else 
                if( fnSchemaDisplayType('Location__c', fieldName)  == 'DateTime' ) { locObj.put(fieldName.trim(), DateTime.ValueOf(fieldValue)); }
                else 
                if( fnSchemaDisplayType('Location__c', fieldName)  == 'Double' ) { locObj.put(fieldName.trim(), Double.ValueOf(fieldValue));}
                else 
                if( fnSchemaDisplayType('Location__c', fieldName)  == 'Integer' ) { locObj.put(fieldName.trim(), Integer.ValueOf(fieldValue)); }
                else 
                if( fnSchemaDisplayType('Location__c', fieldName)  == 'Long' ) { locObj.put(fieldName.trim(), Long.ValueOf(fieldValue)); }
                else             {    locObj.put(fieldName.trim(), fieldValue.trim()); }
            }
             errorMsg = errorMsg + fieldValue + '()|';
            lstLocations.add(locObj);                
             errorMsg = errorMsg + fieldValue + '()|';
        }
        if(lstLocations.size() > 0){
            readSuccess = TRUE;
        }            
  }
*/


  public void readCSVLocationsFromFile(){
      try{
          ehObjectDataAsString = csvFileBody.toString();
          readCSVLocationsCSVFile();
      }
      catch(exception e){
          readSuccess = FALSE;
          errorMsg = errorMsg + 'Error reading CSVLocations CSV file';
          ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg );
          ApexPages.addMessage(errorMessage);
          if(bRunTest) {
              ehObjectDataAsString='HouseNumber__c,StreetName__c,StreetSuffix__c,City__c,State__c,Zip_Code__c,OpportunityID__c,txtStatus__c\n801,Swamp City,Rd,Gladewater,TX,75647,4419,none\n';
          }
        }
    }    

 public void readCSVLocationsCSVFile() {
    lstCSVLocationsStaging.clear();
        ehObjectDataLines = ehObjectDataAsString.split('\n');
        string[] csvFieldNames = ehObjectDataLines[0].split(',');
        for (Integer i = 0; i < csvFieldNames.size(); i++) {
            fieldNumberMap.put(csvFieldNames[i], i);
            lstFieldNames.add(csvFieldNames[i].trim());
        }

        for (Integer i = 1; i < ehObjectDataLines.size(); i++) {
            csvlocObj = new CSVLocations_Staging__c();
            string[] csvRecordData = ehObjectDataLines[i].split(',');
            for (String fieldName: csvFieldNames) {
                fieldNumber = fieldNumberMap.get(fieldName);
                fieldValue = csvRecordData[fieldNumber].trim();
                fieldName = fieldName.trim();
                if( fnSchemaDisplayType('CSVLocations_Staging__c', fieldName)  == 'String' ) { csvlocObj.put(fieldName.trim(), String.ValueOf(fieldValue)); }
                else 
                if( fnSchemaDisplayType('CSVLocations_Staging__c', fieldName)  == 'Boolean' ) { csvlocObj.put(fieldName.trim(), Boolean.ValueOf(fieldValue));}
                else 
                if( fnSchemaDisplayType('CSVLocations_Staging__c', fieldName)  == 'Currency' ) { csvlocObj.put(fieldName.trim(), Double.ValueOf(fieldValue));}
                else 
                if( fnSchemaDisplayType('CSVLocations_Staging__c', fieldName)  == 'Date' ) { csvlocObj.put(fieldName.trim(), Date.ValueOf(fieldValue)); }
                else 
                if( fnSchemaDisplayType('CSVLocations_Staging__c', fieldName)  == 'DateTime' ) { csvlocObj.put(fieldName.trim(), DateTime.ValueOf(fieldValue)); }
                else 
                if( fnSchemaDisplayType('CSVLocations_Staging__c', fieldName)  == 'Double' ) { csvlocObj.put(fieldName.trim(), Double.ValueOf(fieldValue));}
                else 
                if( fnSchemaDisplayType('CSVLocations_Staging__c', fieldName)  == 'Integer' ) { csvlocObj.put(fieldName.trim(), Integer.ValueOf(fieldValue)); }
                else 
                if( fnSchemaDisplayType('CSVLocations_Staging__c', fieldName)  == 'Long' ) { csvlocObj.put(fieldName.trim(), Long.ValueOf(fieldValue)); }
                else             {    csvlocObj.put(fieldName.trim(), fieldValue.trim()); }
            }
             errorMsg = errorMsg + fieldValue + '()|';
            lstCSVLocationsStaging.add(csvlocObj);                
             errorMsg = errorMsg + fieldValue + '()|';
        }
        if(lstCSVLocationsStaging.size() > 0){
            readSuccess = TRUE;
        }            
  }

  public void saveCSVLocationsData() {
    try {
      INSERT lstCSVLocationsStaging;
      List <Id> lstStagingIDs = new List <Id>();
      
      for(integer j=0;j<lstCSVLocationsStaging.size();j++){
          lstStagingIDs.add(lstCSVLocationsStaging[j].Id);
      }

      lstCSVLocationsStaging2= [SELECT Id, HouseNumber__c,PreDirectional__c,StreetName__c,StreetSuffix__c,PostDirectional__c,City__c,State__c,Zip_Code__c,UnitNumber__c,OpportunityID__c,txtStatus__c FROM CSVLocations_Staging__c where Id IN :lstStagingIDs];

      lstCSVLocationsStaging.clear();
      
      readSuccess = FALSE;
      
      ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO, 'CSVLocations_Staging__c records inserted successfully');
      ApexPages.addMessage(errorMessage);
    } catch (Exception e) {
      ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occured while saving data');
      ApexPages.addMessage(errorMessage);
    }
  }

public string fnSchemaDisplayType(String objectName, String fieldName ){
Schema.DisplayType typeByObjectField = Schema.getGlobalDescribe()
.get(objectName).getDescribe().fields.getMap()
.get(fieldName).getDescribe().getType();

    switch on typeByObjectField
    {
        when address { return 'address'; }
        when anytype { return 'anytype'; }
        when base64 { return 'base64'; }
        when Boolean { return 'Boolean'; }
        when Combobox { return 'Combobox'; }
        when Currency { return 'Currency'; }
        when DataCategoryGroupReference { return 'DataCategoryGroupReference'; }
        when Date { return 'Date'; }
        when DateTime { return 'DateTime'; }
        when Double { return 'Double'; }
        when Email { return 'Email'; }
        when EncryptedString { return 'EncryptedString'; }
        when ID { return 'ID'; }
        when Integer { return 'Integer'; }
        when Long { return 'Long'; }
        when MultiPicklist { return 'MultiPicklist'; }
        when Percent { return 'Percent'; }
        when Phone { return 'Phone'; }
        when Picklist { return 'Picklist'; }
        when Reference { return 'Reference'; }
        when String { return 'String'; }
        when TextArea { return 'TextArea'; }
        when else { return 'Other'; }
    }
  }    


}
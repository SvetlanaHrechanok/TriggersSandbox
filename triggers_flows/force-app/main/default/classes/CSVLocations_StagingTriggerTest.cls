@IsTest
private class CSVLocations_StagingTriggerTest {
    @IsTest
    static void aaCSVLocationsStagingTest() {

        Account acc = new Account(Name = 'test1');
        insert acc;

        Opportunity opp = new Opportunity(
                Create_Sitetracker__c = false,
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Close_Date__c = Date.today(),
                Name = 'Opp Test 1',
                AccountId = acc.id,
                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId()
        );
        insert opp;
        opp = [SELECT Id, Name, OpportunityID__c FROM Opportunity WHERE Id = :opp.Id];

        Location__c rec_Location = new Location__c(
                HouseNumber__c = 12,
                StreetName__c = 'Test Street',
                StreetSuffix__c = 'Str',
                City__c = 'Test City',
                State__c = 'St',
                Zip_Code__c = '123'
        );
        rec_Location.Name = rec_Location.FullAddress__c;
        insert rec_Location;

        OppLineItem__c rec_M4RGLoc = new OppLineItem__c(
                Opportunity__c = opp.Id,
                Location__c = rec_Location.Id,
                Name = rec_Location.FullAddress__c
        );
        insert rec_M4RGLoc;

        CSVLocations_Staging__c csv_Location1 = new CSVLocations_Staging__c(
                HouseNumber__c = 12,
                StreetName__c = 'Test Street',
                StreetSuffix__c = 'Str',
                City__c = 'Test City',
                State__c = 'St',
                Zip_Code__c = '123',
                OpportunityID__c = opp.OpportunityID__c
        );
        insert csv_Location1;
        csv_Location1 = [SELECT Id, Name, OpportunityID__c FROM CSVLocations_Staging__c WHERE Id = :csv_Location1.Id];

        CSVLocations_Staging__c csv_Location2 = new CSVLocations_Staging__c(
                HouseNumber__c = 12,
                StreetName__c = 'Test Street',
                StreetSuffix__c = 'Str',
                City__c = 'New City',
                State__c = 'St',
                Zip_Code__c = '1234',
                OpportunityID__c = opp.OpportunityID__c
        );
        insert csv_Location2;
        csv_Location2 = [SELECT Id, Name, OpportunityID__c FROM CSVLocations_Staging__c WHERE Id = :csv_Location2.Id];

        CSVLocations_Staging__c csv_Location3 = new CSVLocations_Staging__c(
                HouseNumber__c = 12,
                StreetName__c = 'Test Street',
                StreetSuffix__c = 'Str',
                City__c = 'City',
                State__c = 'St',
                Zip_Code__c = '12'
        );
        insert csv_Location3;
        csv_Location3 = [SELECT Id, Name, OpportunityID__c FROM CSVLocations_Staging__c WHERE Id = :csv_Location3.Id];

        Test.startTest();

        CSVLocations_Staging__c csvLoc1 = [
          SELECT Id, txtStatus__c FROM CSVLocations_Staging__c WHERE Zip_Code__c = '123' LIMIT 1
        ];

        System.assertEquals('|Location EXISTs|M4RevGenLoc Created', csvLoc1.txtStatus__c);

        CSVLocations_Staging__c csvLoc2 = [
                SELECT Id, txtStatus__c FROM CSVLocations_Staging__c WHERE Zip_Code__c = '1234' LIMIT 1
        ];

        System.assertEquals('|Location Created|M4RevGenLoc Created', csvLoc2.txtStatus__c);

        CSVLocations_Staging__c csvLoc3 = [
                SELECT Id, txtStatus__c FROM CSVLocations_Staging__c WHERE Zip_Code__c = '12' LIMIT 1
        ];

        System.assertEquals('FAIL: Opportunity doesn\'t exist', csvLoc3.txtStatus__c);


        Test.stopTest();





    }
}
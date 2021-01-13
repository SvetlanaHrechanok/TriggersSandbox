@IsTest
private class tr_OppLineItemTest {
    @IsTest
    static void revGenLocationActionsTest() {
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
                Zip_Code__c = '123456'
        );
        rec_Location.Name = rec_Location.FullAddress__c;
        insert rec_Location;

        Serviceable_Zip_Codes__c zipCodes = new Serviceable_Zip_Codes__c(
                ICB__c = 'ICB',
                Name = '123456'
        );
        insert zipCodes;

        OppLineItem__c rec_M4RGLoc = new OppLineItem__c(
                Opportunity__c = opp.Id,
                Name = '12 Test Street Str Test City St 123',
                Location__c = rec_Location.Id
        );
        insert rec_M4RGLoc;

        Test.startTest();

        OppLineItem__c oppLine = [SELECT Id, Serviceable__c, Zip_Code__c, Location__r.Zip_Code__c FROM OppLineItem__c LIMIT 1];
        System.assertEquals('ICB', oppLine.Serviceable__c);

        Serviceable_Zip_Codes__c zipCodes1 = new Serviceable_Zip_Codes__c(
                ICB__c = 'NONE',
                Name = '123'
        );
        insert zipCodes1;

        oppLine.Serviceable__c = '';
        update oppLine;

        Location__c loc = [SELECT Id, Zip_Code__c FROM Location__c LIMIT 1];
        loc.Zip_Code__c = '123';
        update loc;

        update oppLine;
        oppLine = [SELECT Id, Serviceable__c, Zip_Code__c, Location__r.Zip_Code__c FROM OppLineItem__c LIMIT 1];
        System.assertEquals('Serviceable', oppLine.Serviceable__c);

        oppLine.Serviceable__c = '';
        update oppLine;

        loc = [SELECT Id, Zip_Code__c FROM Location__c LIMIT 1];
        loc.Zip_Code__c = '789';
        update loc;

        update oppLine;
        oppLine = [SELECT Id, Serviceable__c, Zip_Code__c, Location__r.Zip_Code__c FROM OppLineItem__c LIMIT 1];
        System.assertEquals('Not Serviceable', oppLine.Serviceable__c);

        Test.stopTest();
    }
}
@isTest
private class TestLocationCreate {
    @isTest static void TestLocationCreate() {

      Location__c loc = new Location__c(Name='xx', HouseNumber__c = 123, StreetName__c = 'Main', City__c = 'New York', State__c = 'NY');
        Opportunity opp = new Opportunity(Name='ashley opp');
        
        Test.startTest();
        
        Database.SaveResult result = Database.insert(loc, false);
                
        Database.SaveResult resultOpp = Database.insert(opp, false);
        
        OppLineItem__c oli = new OppLineItem__c(Name='aa', Opportunity__c=opp.Id, Location__c=loc.Id);
        
        Database.SaveResult resultOli = Database.insert(oli, false);
        
        Test.stopTest();
        
        List<Location__c> loc2 = [select Name from Location__c where Id=:loc.Id];
        
        //System.assert(result.isSuccess());
        //System.assert(resultOpp.isSuccess());
        //System.assert(resultOli.isSuccess());
        
        //System.assertEquals(loc2[0].Name, '123 Main New York, NY');
    }
}
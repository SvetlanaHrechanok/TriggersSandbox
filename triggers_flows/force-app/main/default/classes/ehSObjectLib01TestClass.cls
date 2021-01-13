@isTest
private class ehSObjectLib01TestClass {
    static testMethod void validatefunction1() {
        string strFieldList;
        List<SObject> lstRecOpp = ehSObjectLib01.soObjectFromQueryFixed('Opportunity', '', 'Id desc', '1');
        List<OppLineItem__c> lstM4RGLoc = ehSObjectLib01.soObjectFromQueryCustom( 'OppLineItem__c', 'Opportunity__c >= \'000000000000000000\'', 'Location__c asc', '10', 'Id, Location__c, Location__r.HouseNumber__c, Location__r.PreDirectional__c, Location__r.StreetName__c, Location__r.StreetSuffix__c, Location__r.PostDirectional__c, Location__r.City__c,Location__r.MapcomStructureId__c,Location__r.OwnerId,Location__r.Zip_Code__c,Location__r.State__c,Location__r.UnitNumber__c, Opportunity__r.AccountId, Opportunity__r.Account.Account_Type__c, Opportunity__r.Id, Opportunity__r.Region__c, Opportunity__r.RecordType.Name');
        strFieldList = ehSObjectLib01.strCommaFieldList('OppLineItem__c');
        List<Id> lstSrvSiteIDs = ehSObjectLib01.fnListIDs(lstM4RGLoc , 'Id');
        if ( lstRecOpp.size() > 0 )
        {
            strFieldList = ehSObjectLib01.strCommaFieldList('OppLineItem__c');
            Opportunity AA_INVAR_rec_Opportunity = (Opportunity) (lstRecOpp[0]);
        }
            return;
    }
}
/*******************************************************************************
*   Author:          Christian Aguirre / Torrent Consulting
*   Company Contact: development@torrentconsulting.com / 
*                    christian.aguirre@torrentconsulting.com
*   Purpose:         Unit test for the class CPQQuoteService
*   Last Modified By:       Ayoola Olapo / Torrent Cosulting 
*
*   Version History: 2/14/19 - Added Quote Lines to Quote Group to reflect new funcionality

*******************************************************************************/
@isTest
private class CPQQuoteTrigger_Test {
    @isTest 
    static void test_Quote_XIRR_Calculation(){
        Account acc = new Account(Name = 'test1');
        insert acc;
        Opportunity opp = new Opportunity(
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Close_Date__c = Date.today(),
            Name = 'Opp Test',
            AccountId = acc.id
        );
        System.debug('\n\n[CPQQuoteTrigger_Test]opp: ' + JSON.serialize(opp) + '\n\n');
        Insert opp;

        Id draftRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();

        Product2 quoteProd = new Product2(
            Name = 'E-line UNI - 100',
            ProductCode = 'MEUNI100M',
            Product_Category__c = 'E-line',
            Product_Item__c = 'UNI',
            IsActive = True,
            SBQQ__BlockPricingField__c = 'Quantity',
            Family = 'Fiber Ethernet',
            SBQQ__AssetAmendmentBehavior__c = 'Default',
            SBQQ__AssetConversion__c = 'One per quote line',
            SBQQ__DefaultQuantity__c = 1,
            Description = '100 Mbps Fiber Ethernet UNI',
            SBQQ__OptionSelectionMethod__c = 'Click',
            SBQQ__PricingMethod__c = 'List',
            SBQQ__PriceEditable__c = True,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__SubscriptionTerm__c = 1,
            SBQQ__SubscriptionBase__c = 'List',
            SBQQ__SubscriptionType__c = 'Renewable'
        );
        Insert quoteProd;

        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c = opp.Id,
            RecordTypeId =  draftRecordTypeId,
            SBQQ__SubscriptionTerm__c = 60,
            SBQQ__Account__c = acc.id
        );
        Insert quote;
 /*20200706 - BEGIN erin's new code */

    Location__c recLocation;
    OppLineItem__c recM4RgLoc;
    List<Location__c> lstLocations = [SELECT Id, City__c, State__c, Name, PostDirectional__c, PreDirectional__c, MapcomStructureId__c, HouseNumber__c, StreetName__c, StreetSuffix__c, UnitNumber__c, Zip_Code__c, FullAddress__c from Location__c where Name = '620 Romero St Lake Charles LA 70607' limit 1 ];
    
    if( lstLocations.size() > 0 )
        recLocation = lstLocations[0];
    else
    {
        recLocation = new Location__c ( City__c = 'Lake Charles', State__c = 'LA', Name = '620 Romero St Lake Charles LA 70607', PostDirectional__c = '', PreDirectional__c = ''    , HouseNumber__c = 620    , StreetName__c = 'Romero'    , StreetSuffix__c = 'St', UnitNumber__c = ''    , Zip_Code__c = '70607' );
        INSERT recLocation;
    }
    
    List<OppLineItem__c> lstM4RgLoc = [ SELECT Id, Name, Location__c, M4_RevGen_Location_ID__c, Opportunity__c, Zip_Code__c, Location_Cost_With_Tax__c, LocationCost__c, LocationDistance__c, Revgen_Structure_ID_2__c, Revgen_Structure_ID_3__c from OppLineItem__c where Location__c =:recLocation.Id limit 1 ];

    if( lstM4RgLoc.size() > 0 )
        recM4RgLoc = lstM4RgLoc[0];
    else
    {
        recM4RgLoc = new OppLineItem__c ( Name = '620 Romero St Lake Charles LA 70607', Location__c = recLocation.Id, Opportunity__c = opp.Id );
        INSERT recM4RgLoc;
    }
    
 /*END erin's new code */
 
        SBQQ__QuoteLineGroup__c  quoteLineGroup = new SBQQ__QuoteLineGroup__c(
            Name = 'Erin/Tim CPQQuoteTrigger_Test',
            SBQQ__Quote__c = quote.id,
            M4_RevGen_Location__c = recM4RgLoc.Id,
            Capex__c = 12
        );
        insert quoteLineGroup;
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quote.Id,
            SBQQ__Quantity__c = 1,
            NRC_Cost__c = 1000,
            NRC_Rev__c = 1000,
            MRC_Cost__c = 500,
            MRC_Rev__c = 1500, 
            SBQQ__Product__c = quoteProd.Id,
            SBQQ__Group__c = quoteLineGroup.Id
        );
        Insert quoteLine;

        SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quote.Id,
            SBQQ__Quantity__c = 1,
            NRC_Cost__c = 2000,
            NRC_Rev__c = 2000,
            MRC_Cost__c = 1000,
            MRC_Rev__c = 2000,
            SBQQ__Product__c = quoteProd.Id,
            SBQQ__Group__c = quoteLineGroup.Id
        );
        Insert quoteLine2;

        quote.SBQQ__StartDate__c = Date.today();


        /* This piece of code fires the CPQQuoteTrigger custom trigger that calculates the IRR value*/
        Test.startTest();
        update quote;
        Test.stopTest();

        /* Test the result of the IRR calculation*/
        List<SBQQ__Quote__c> quoteList = [
            select id, NRC_Total_Rev__c, Total_Capex__c, NRC_Total_Cost__c, Initial_Cash_Flow__c, MRC_Total_Rev__c, MRC_Total_Cost__c, Yearly_Cash_Flow__c, Term__c, IRR__c
            from SBQQ__Quote__c
        ];

        System.debug('\n\n[CPQQuoteTrigger_Test]quoteList: ' + JSON.serialize(quoteList) + '\n\n');

        System.assertEquals(false, quoteList[0].IRR__c != null);
    }
}
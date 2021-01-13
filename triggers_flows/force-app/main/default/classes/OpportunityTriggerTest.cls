@isTest
public with sharing class OpportunityTriggerTest {

    public static sitetracker__Project_Template__c testTemplate {
        get {
            if (testTemplate == null){
                sitetracker__Project_Template__c template = new sitetracker__Project_Template__c(
                    Name = 'TestTemplate',
                    sitetracker__Active__c = true,
                    sitetracker__Complete_Status__c = 'Complete',
                    sitetracker__SiteTraker_Object__c = 'sitetracker__Project__c',
                    sitetracker__Project_Extension_Objects__c = 'sitetracker__Milestone__c',
                    sitetracker__Manual_Forecast_Change_Behavior__c = 'Lock the Forecast Date'
                );
                insert template;

                testTemplate = template;            
            }
            return testTemplate;
        }
        set;
    }

    @isTest static void serviceSitesTBELK_Higgins() {
        // create account
        Account acc = new Account(Name = 'test1');
        insert acc;

        // create opportunity
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

        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Account__c = acc.Id,
            SBQQ__StartDate__c = Date.today(),
            Term_Length__c = '2',
            SBQQ__Status__c = 'Draft',
            RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId(),
            SBQQ__Opportunity2__c = opp.Id
        );
        insert quote;

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
        insert quoteProd;

        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = quoteProd.Id,
            IsActive = true,
            UnitPrice = 100
        );
        insert pricebookEntry;

        Location360__c location1 = new Location360__c(
            Name = 'Loc1',
            City__c = 'New York',
            State_Text__c = 'NY',
            Street_Name__c = 'Broadway',
            Street_Suffix__c = '',
            HouseNumber__c = 253,
            Zip_Postal__c = '10007'
        );
        Location360__c location2 = new Location360__c(
            Name = 'Loc2',
            City__c = 'New York',
            State_Text__c = 'NY',
            Street_Name__c = 'Broadway',
            Street_Suffix__c = '',
            HouseNumber__c = 253,
            Zip_Postal__c = '10007'
        );
        insert new List<Location360__c> {location1, location2};

        // create service site
        Service_Sites__c ss1 = new Service_Sites__c(
            Opportunity__c = opp.Id,
            State__c = 'NY',
            Street_Address__c = '253 Broadway, New York, NY 10007, United States',
            Location360__c = location1.Id
        );
        insert new List<Service_Sites__c> { ss1 };

        Location__c location = new Location__c(
            City__c = 'New York',
            State__c = 'NY',
            StreetName__c = 'Broadway',
            StreetSuffix__c = '',
            HouseNumber__c = 253,
            Zip_Code__c = '10007'
        );
        insert location;

        OppLineItem__c m4RevGenLocation1 = new OppLineItem__c(
            Location__c = location.Id,
            Opportunity__c = opp.Id,
            Location360__c = location1.Id
        );
        OppLineItem__c m4RevGenLocation2 = new OppLineItem__c(
            Location__c = location.Id,
            Opportunity__c = opp.Id,
            Location360__c = location2.Id
        );
        insert new List<OppLineItem__c> { m4RevGenLocation1, m4RevGenLocation2 };

        Program__c program1 = new Program__c(
            Name = 'Opp:' + opp.Name + '[' + opp.Id + ']'
        );
        insert new List<Program__c> { program1 };

        
        sitetracker__Site__c site = new sitetracker__Site__c(
            Service_Site__c = ss1.Id
        );
        insert site;
        
        sitetracker__Segment__c segment = new sitetracker__Segment__c(
            sitetracker__Z_Location__c = site.Id
        );
        insert segment;
        
        sitetracker__Project__c project = new sitetracker__Project__c(
            Program__c = program1.Id,
            sitetracker__ProjectTemplate__c = OpportunityTriggerTest.testTemplate.Id,
            Segment__c = segment.Id
        );
        insert project;

        SBQQ__QuoteLineGroup__c quoteLineGroup = new SBQQ__QuoteLineGroup__c(
            Name = m4RevGenLocation1.Name,
            M4_RevGen_Location__c = m4RevGenLocation1.Id,
            SBQQ__Quote__c = quote.Id,
            SBQQ__Number__c = 10,
            SBQQ__ListTotal__c = 0,
            SBQQ__CustomerTotal__c = 0,
            SBQQ__NetTotal__c = 0
        );
        insert quoteLineGroup;

        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quote.Id,
            SBQQ__Group__c = quoteLineGroup.Id,
            Location360__c = location1.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__Product__c = quoteProd.Id,
            NRC_Cost__c = 1000,
            NRC_Rev__c = 1000,
            MRC_Cost__c = 1000,
            MRC_Rev__c = 1000
        );

        insert quoteLine;

        System.assertEquals(1, [SELECT count() FROM Service_Sites__c WHERE Opportunity__c = :opp.Id]);

        // Test.startTest();
        update new Opportunity(
            Id = opp.Id,
            Create_Sitetracker__c = true,
            SBQQ__PrimaryQuote__c = quote.Id
        );
        // Test.stopTest();

        System.assertEquals(2, [SELECT count() FROM Service_Sites__c WHERE Opportunity__c = :opp.Id]);
        System.assertEquals(location1.Id, [SELECT Location360__c FROM Service_Sites__c WHERE Id = :ss1.Id]?.Location360__c);
        System.assertEquals(m4RevGenLocation2.Id, [SELECT M4RGL__c FROM Service_Sites__c WHERE Location360__c = :location2.Id]?.M4RGL__c);
        System.assertEquals(opp.Id, [SELECT Opportunity__c FROM Program__c WHERE Id = :program1.Id]?.Opportunity__c);
        System.assertEquals(1, [SELECT count() FROM Service_Site_Product__c WHERE Opportunity__c = :opp.Id]);
    }

    @isTest static void serviceSitesTBELK_Higgins_svcSiteTracker1() {
        // create account
        Account acc = new Account(Name = 'account');
        insert acc;

        // create opportunitie
        Opportunity opp = new Opportunity(
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Close_Date__c = Date.today(),
            Name = 'Opp Test 1',
            AccountId = acc.id,
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enablement').getRecordTypeId()
        );
        insert opp;
        
        // create service site
        Service_Sites__c seviceSites = new Service_Sites__c(
            Opportunity__c = opp.Id,
            State__c = 'NY',
            Street_Address__c = '253 Broadway, New York, NY 10007, United States'
        );
        insert seviceSites;

        // create service site product
        Service_Site_Product__c ssProduct = new Service_Site_Product__c(
            Opportunity__c = opp.Id,
            Service_Site_RecordID__c = seviceSites.Id
        );
        insert ssProduct;

        // create service site opportunity
        Service_Site_Opportunities__c ssOpportunity = new Service_Site_Opportunities__c(
            Opportunity__c = opp.Id
        );
        insert ssOpportunity;

        // create service site account
        Service_Site_Accounts__c ssAccounts = new Service_Site_Accounts__c(
            Opportunity__c = opp.Id,
            Account__c = acc.id
        );
        insert ssAccounts;

        // verify that opportunity is related to Service Site Product, Service Site Opportunities, Service Site Accounts
        System.assertEquals(1, [SELECT count() FROM Service_Site_Product__c WHERE Opportunity__c = :opp.Id]);
        System.assertEquals(1, [SELECT count() FROM Service_Site_Opportunities__c WHERE Opportunity__c = :opp.Id]);
        System.assertEquals(1, [SELECT count() FROM Service_Site_Accounts__c WHERE Opportunity__c = :opp.Id]);

        update new Opportunity(
            Id = opp.Id,
            Name = 'Opp Test'
        );
        
        // opportunity hasn't all the requirements for trigger handling (Create_Sitetracker__c = false && RecordType != 'Enterprise')
        // therefore the related records were not deleted
        System.assertEquals(1, [SELECT count() FROM Service_Site_Product__c WHERE Opportunity__c = :opp.Id]);
        System.assertEquals(1, [SELECT count() FROM Service_Site_Opportunities__c WHERE Opportunity__c = :opp.Id]);
        System.assertEquals(1, [SELECT count() FROM Service_Site_Accounts__c WHERE Opportunity__c = :opp.Id]);

        update new Opportunity(
            Id = opp.Id,
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId(),
            Create_Sitetracker__c = true
        );
        
        // opportunity has all the requirements for trigger handling
        // therefore the related records were deleted
        System.assertEquals(0, [SELECT count() FROM Service_Site_Product__c WHERE Opportunity__c = :opp.Id]);
        System.assertEquals(0, [SELECT count() FROM Service_Site_Opportunities__c WHERE Opportunity__c = :opp.Id]);
        System.assertEquals(0, [SELECT count() FROM Service_Site_Accounts__c WHERE Opportunity__c = :opp.Id]);
    }
        
}
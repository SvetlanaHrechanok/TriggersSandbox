@IsTest
private with sharing class QuoteTriggerTest {
    @testSetup static void setup() {
        Account acc = new Account(Name = 'test1');
        insert acc;

        Opportunity opp = new Opportunity(
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Close_Date__c = Date.today(),
            Name = 'Opp Test',
            AccountId = acc.id
        );
        insert opp;

        Id draftRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        Id pricebookId = Test.getStandardPricebookId();

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
            Pricebook2Id = pricebookId,
            Product2Id = quoteProd.Id,
            IsActive = true,
            UnitPrice = 100
        );
        insert pricebookEntry;

        Location__c recLocation = new Location__c ( 
            City__c = 'Lake Charles', 
            State__c = 'LA', 
            Name = '620 Romero St Lake Charles LA 70607', 
            PostDirectional__c = '', 
            PreDirectional__c = '', 
            HouseNumber__c = 620, 
            StreetName__c = 'Romero', 
            StreetSuffix__c = 'St', 
            UnitNumber__c = '', 
            Zip_Code__c = '70607' 
        );
        insert recLocation;

        OppLineItem__c recM4RgLoc = new OppLineItem__c ( 
            Name = '620 Romero St Lake Charles LA 70607', 
            Location__c = recLocation.Id, 
            Opportunity__c = opp.Id 
        );
        insert recM4RgLoc;

        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c = opp.Id,
            RecordTypeId =  draftRecordTypeId,
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Account__c = acc.id,
            SBQQ__StartDate__c = Date.today(),
            Term_Length__c = '2',
            SBQQ__Status__c = 'Draft'
        );
        insert quote;

        SBQQ__QuoteLineGroup__c quoteLineGroup = new SBQQ__QuoteLineGroup__c(
            M4_RevGen_Location__c = recM4RgLoc.Id,
            Name = recM4RgLoc.Name,
            SBQQ__Quote__c = quote.Id,
            SBQQ__Number__c = 10,
            SBQQ__ListTotal__c = 0,
            SBQQ__CustomerTotal__c = 0,
            SBQQ__NetTotal__c = 0
        );
        insert quoteLineGroup;
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quote.Id,
            SBQQ__Quantity__c = 1,
            NRC_Cost__c = 1000,
            NRC_Rev__c = 1000,
            MRC_Cost__c = 1000,
            MRC_Rev__c = 1000, 
            SBQQ__Product__c = quoteProd.Id,
            SBQQ__Group__c = quoteLineGroup.Id
        );
        insert quoteLine;

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
        insert quoteLine2;

    }

    @IsTest
    static void approvalMatrixAndSetTermsTest() {
        SBQQ__Quote__c quote = [
            SELECT Id, Gross_Profit_Approval__c, GP_Payback_AE_Approval__c, GP_Payback_ASM_Approval__c, GP_Payback_VP_Approval__c,
                GP_Payback_Exec_Approval__c, Approval_Level__c, Payback_GM_Months__c
            FROM SBQQ__Quote__c
            LIMIT 1
        ];

        List<SBQQ__QuoteLine__c> lines = [
            SELECT Id, NRC_Cost__c, NRC_Rev__c, MRC_Cost__c, MRC_Rev__c
            FROM SBQQ__QuoteLine__c
        ];

        Test.startTest();
        quote.Term_Length__c = '1';
        update quote;
        System.assertEquals('ASM Approval', quote.Approval_Level__c);

        quote.Term_Length__c = '7';
        lines[1].NRC_Cost__c = 7000;
        lines[1].NRC_Rev__c = 2500;
        lines[1].MRC_Cost__c = 1500;
        lines[1].MRC_Rev__c = 7000;
        update lines;
        update quote;

        Test.stopTest();
    }

    @IsTest
    static void includeDocumentsTest() {
        SBQQ__Quote__c quote = [
            SELECT Id, Exclude_Enterprise_Cust_LOA__c, Transfer_Number_Service_Count__c, Voice_Services_Count__c, 
            Exclude_Enterprise_Cust_911_Acknowledgem__c, Exclude_Enterprise_Cust_IP_Justification__c, Exclude_Enterprise_Cust_T_Cs_Attachment__c,
            Transfer_Toll_Free_Count__c, Static_IPs_Over_5_Count__c, Include_LOA_Document__c, Include_RespOrg_Document__c
            FROM SBQQ__Quote__c
            LIMIT 1
        ];

        Test.startTest();
        quote.Exclude_Enterprise_Cust_LOA__c = false;
        quote.Transfer_Number_Service_Count__c = 0;
        quote.Voice_Services_Count__c = 0;
        update quote;

        quote.Exclude_Enterprise_Cust_911_Acknowledgem__c = false;
        quote.Voice_Services_Count__c = 0;
        update quote;
        System.assertEquals(false, quote.Exclude_Enterprise_Cust_911_Acknowledgem__c);

        quote.Exclude_Enterprise_Cust_IP_Justification__c = false;
        quote.Static_IPs_Over_5_Count__c = 0;
        update quote;
        System.assertEquals(false, quote.Exclude_Enterprise_Cust_IP_Justification__c);

        quote.Exclude_Enterprise_Cust_T_Cs_Attachment__c = false;
        quote.Voice_Services_Count__c = 0;
        update quote;
        System.assertEquals(false, quote.Exclude_Enterprise_Cust_T_Cs_Attachment__c);

        quote.Transfer_Toll_Free_Count__c = 0;
        update quote;
        System.assertEquals(false, quote.Include_RespOrg_Document__c);
        Test.stopTest();
    }

    @IsTest
    static void setApproversTest() {
        SBQQ__Quote__c quote = [
            SELECT Id, ASM_Approver__c, VP_Approver__c, SBQQ__SalesRep__r.ASM_Approver__c, SBQQ__SalesRep__c,
            SBQQ__SalesRep__r.VP_Approver__c
            FROM SBQQ__Quote__c
            LIMIT 1
        ];

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User cuttentUser = new User(  
            Firstname = 'fName',
            LastName = 'lName',
            Email = uniqueName + '@test' + orgId + '.org',
            Username = uniqueName + '@test' + orgId + '.org',
            EmailEncodingKey = 'ISO-8859-1',
            Alias = uniqueName.substring(18, 23),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert cuttentUser;

        Test.startTest();
        quote.SBQQ__SalesRep__c = cuttentUser.Id;
        update quote;
        System.assertNotEquals(cuttentUser.Id, quote.ASM_Approver__c);
        System.assertNotEquals(cuttentUser.Id, quote.VP_Approver__c);

        Test.stopTest();
    }

    @IsTest
    static void updateDraftRecordTypeOnClonedQuoteTest() {
        SBQQ__Quote__c quote = [
            SELECT Id, RecordTypeId, SBQQ__Status__c
            FROM SBQQ__Quote__c
            LIMIT 1
        ];

        Test.startTest();
        quote.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Approved').getRecordTypeId();
        update quote;
        System.assertNotEquals('Draft', Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosById().get(quote.RecordTypeId).getName());

        Test.stopTest();
    }
}
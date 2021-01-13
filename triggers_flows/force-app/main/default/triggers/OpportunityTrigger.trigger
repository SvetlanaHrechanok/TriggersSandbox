trigger OpportunityTrigger on Opportunity (before insert, before update) {

    if ( Trigger.isInsert && Trigger.isBefore) {
        System.debug('OpportunityTrigger.Trigger.isBefore && Trigger.isInsert');
        closedWon_Interactions(Trigger.new, Trigger.oldMap, Trigger.newMap);
        serviceSitesTBELK_Higgins(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }

    if ( Trigger.isUpdate && Trigger.isBefore) {
        System.debug('OpportunityTrigger.Trigger.isBefore && Trigger.isUpdate');
        closedWon_Interactions(Trigger.new, Trigger.oldMap, Trigger.newMap);
        serviceSitesTBELK_Higgins(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }

    public static void closedWon_Interactions(List<Opportunity> opportunities, Map<Id, Opportunity> oldMapOpportunities, Map<Id, Opportunity> newMapOpportunities) {
        try {
            List<Opportunity> changedOpportunities = new List<Opportunity>();
            Set<Id> quoteIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            for (Opportunity item : opportunities) {
                if ( item.StageName == 'Closed Won' && oldMapOpportunities?.get(item.Id).StageName != newMapOpportunities?.get(item.Id).StageName) {
                    changedOpportunities.add(item);
                    if ( item.SBQQ__PrimaryQuote__c != null ) quoteIds.add(item.SBQQ__PrimaryQuote__c);
                    if ( item.AccountId != null ) accountIds.add(item.AccountId);
                }
            }    

            List<Account> accounts = [
                SELECT Id, Contract_Signed__c, Contract_Term__c, MRC_Initial__c, MRC_Rollup__c, NRC_Upfront__c
                FROM Account
                WHERE Id IN :accountIds
            ];
            
            Map<Id, SBQQ__Quote__c> mapQuotes = new Map<Id, SBQQ__Quote__c>();
            if ( !quoteIds.isEmpty() ) {
                for (SBQQ__Quote__c quote : [SELECT Id, Term_Length__c, MRC_Total_Rev__c, NRC_Total_Rev__c, Total_Location_Capex__c
                                             FROM SBQQ__Quote__c
                                             WHERE Id IN :quoteIds] ) {
                    mapQuotes.put(quote.Id, quote);
                }
            }
            
            for (Opportunity item : changedOpportunities) {
                if ( !accounts.isEmpty() ) {
                    for (Account acc : accounts) {
                        if ( item.AccountId.equals(acc.Id) ) {
                            acc.Contract_Signed__c = item.Close_Date__c;
                            acc.Contract_Term__c = mapQuotes.size() != 0 ? mapQuotes.get(item.SBQQ__PrimaryQuote__c).Term_Length__c : '';
                            acc.MRC_Initial__c = mapQuotes.size() != 0 ? mapQuotes.get(item.SBQQ__PrimaryQuote__c).MRC_Total_Rev__c : 0;
                            acc.MRC_Rollup__c = mapQuotes.size() != 0 ? mapQuotes.get(item.SBQQ__PrimaryQuote__c).MRC_Total_Rev__c : 0;
                            acc.NRC_Upfront__c = mapQuotes.size() != 0 ? mapQuotes.get(item.SBQQ__PrimaryQuote__c).NRC_Total_Rev__c : 0;
                        }
                    }
                }
                
                item.Estimated_CAPEX__c = mapQuotes.size() != 0 ? mapQuotes.get(item.SBQQ__PrimaryQuote__c).Total_Location_Capex__c : 0;
                item.NRC__c = mapQuotes.size() != 0 ? mapQuotes.get(item.SBQQ__PrimaryQuote__c).NRC_Total_Rev__c : 0;
                item.New_MRC__c = mapQuotes.size() != 0 ? mapQuotes.get(item.SBQQ__PrimaryQuote__c).MRC_Total_Rev__c : 0;
            }

            if ( !accounts.isEmpty() ) update accounts;

        } catch (Exception ex) {
            System.debug('Exception closedWon_Interactions');
            System.debug(ex.getMessage());
            System.debug('getStackTraceString');
            System.debug(ex.getStackTraceString());
            System.debug('getTypeName');
            System.debug(ex.getTypeName());
            System.debug('getLineNumber');
            System.debug(ex.getLineNumber());
            System.debug('getCause');
            System.debug(ex.getCause());
            for (Opportunity opp : Trigger.new) {
                opp.addError(ex.getMessage());
            }
        }
    } 

    public static void serviceSitesTBELK_Higgins(List<Opportunity> opportunities, Map<Id, Opportunity> oldMapOpportunities, Map<Id, Opportunity> newMapOpportunities) {
        System.debug('OpportunityTrigger.serviceSitesTBELK_Higgins');
        try {
            Map<Id, Opportunity> quoteIdToOpportunity = new Map<Id, Opportunity>();
            Set<Id> opportunityIds = new Set<Id>();
            for (Opportunity opp : opportunities) {
                if ( opp.Create_Sitetracker__c == true && 
                    oldMapOpportunities?.get(opp.Id).Create_Sitetracker__c != newMapOpportunities?.get(opp.Id).Create_Sitetracker__c &&
                    Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.RecordTypeId).getName().equals('Enterprise') ) {
                        if ( opp.SBQQ__PrimaryQuote__c != null ) quoteIdToOpportunity.put(opp.SBQQ__PrimaryQuote__c, opp);
                        opportunityIds.add(opp.Id);
                } 
            }
            
            svcSiteTracker1(opportunityIds);
            svcSiteTracker3(opportunityIds, quoteIdToOpportunity, opportunities);
        } catch (Exception ex) {
            System.debug('Exception serviceSitesTBELK_Higgins');
            System.debug(ex.getMessage());
            System.debug('getStackTraceString');
            System.debug(ex.getStackTraceString());
            System.debug('getTypeName');
            System.debug(ex.getTypeName());
            System.debug('getLineNumber');
            System.debug(ex.getLineNumber());
            System.debug('getCause');
            System.debug(ex.getCause());
            for (Opportunity opp : Trigger.new) {
                opp.addError(ex.getMessage());
            }
        }
    } 

    public static void svcSiteTracker1(Set<Id> opportunityIds) {
        System.debug('OpportunityTrigger.svcSiteTracker1');
        try {

            Set<Id> accountIds = new Set<Id>();
            for( Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE Id IN :opportunityIds]) {
                accountIds.add(opp.AccountId);
            }
            
            List<Service_Site_Product__c> svcSiteProducts = [
                SELECT Id
                FROM Service_Site_Product__c
                WHERE Opportunity__c IN :opportunityIds
            ];
            
            if ( !svcSiteProducts.isEmpty() ) {
                delete svcSiteProducts;
            }

            List<Service_Site_Opportunities__c> svcSiteOpportunities = [
                SELECT Id
                FROM Service_Site_Opportunities__c
                WHERE Opportunity__c IN :opportunityIds
            ];
            
            if ( !svcSiteOpportunities.isEmpty() ) {
                delete svcSiteOpportunities;
            }

            List<Service_Site_Accounts__c> svcSiteAccounts = [
                SELECT Id
                FROM Service_Site_Accounts__c
                WHERE Opportunity__c IN :opportunityIds
                AND Account__c IN :accountIds
            ];
            
            if ( !svcSiteAccounts.isEmpty() ) {
                delete svcSiteAccounts;
            }
            
        } catch (Exception ex) {
            System.debug('Exception svcSiteTracker1');
            System.debug(ex.getMessage());
            System.debug('getStackTraceString');
            System.debug(ex.getStackTraceString());
            System.debug('getTypeName');
            System.debug(ex.getTypeName());
            System.debug('getLineNumber');
            System.debug(ex.getLineNumber());
            System.debug('getCause');
            System.debug(ex.getCause());
            for (Opportunity opp : Trigger.new) {
                opp.addError(ex.getMessage());
            }
        }
    }

    public static void svcSiteTracker3(Set<Id> opportunityIds, Map<Id, Opportunity> quoteIdToOpportunity, List<Opportunity> opportunities) {
        System.debug('OpportunityTrigger.svcSiteTracker3');
        try {
            Map<Id, SBQQ__Quote__c> mapQuotes = new Map<Id, SBQQ__Quote__c>([
                SELECT Id, Name, SBQQ__NetAmount__c, Total_Location_Capex__c, NRC_Total_Rev__c, MRC_Total_Rev__c, Term_Length__c
                FROM SBQQ__Quote__c
                WHERE Id IN :quoteIdToOpportunity.keySet()
            ]);
    
            Integer iCountExistingSrvSites = 0;
            Integer ZZ_OUTVAR_iCountNEWSrvSites = 0;
            List<String> mpl_Existing_SrvSite_Locations = new List<String>{'*****$$$$$9QQqq&&&'};
            Set<Id> ZZ_OUTVAR_mpl_Existing_SrvSite_RecordIds = new Set<Id>();
            String strConcatExistingServiceSites = '';
    
            for (Service_Sites__c loopRec_ServiceSite : [SELECT Location360__c, Opportunity__c FROM Service_Sites__c WHERE Opportunity__c IN :opportunityIds ORDER BY Location360__c ASC]) {
                iCountExistingSrvSites ++;
                mpl_Existing_SrvSite_Locations.add(loopRec_ServiceSite.Location360__c);
                ZZ_OUTVAR_mpl_Existing_SrvSite_RecordIds.add(loopRec_ServiceSite.Id);
                strConcatExistingServiceSites += loopRec_ServiceSite.Id;
            }

            List<Service_Sites__c> serviceSitesAll = new List<Service_Sites__c>();
            List<Service_Sites__c> serviceSitesToInsert = new List<Service_Sites__c>();
            List<Service_Sites__c> serviceSitesToUpdate = new List<Service_Sites__c>();
            Map<Id, Service_Sites__c> locationIdToServiceSite = new Map<Id, Service_Sites__c>();
    
            for (OppLineItem__c loopRec_M4RGLoc : [SELECT Id, Location360__c, Opportunity__r.AccountId, Location360__r.HouseNumber__c, Location360__r.City__c, Opportunity__r.Account.Account_Type__c, 
                Location360__r.MapcomStructureId__c, Opportunity__c, Opportunity__r.OwnerId, Opportunity__r.Region__c, Opportunity__r.RecordType.Name, Location360__r.State_Text__C,
                Location360__r.PreDirectional__c, Location360__r.Street_Name__c, Location360__r.Street_Suffix__c, Location360__r.PostDirectional__c, Location360__r.UnitNumber__c, Location360__r.Zip_Postal__c, 
                Opportunity__r.SBQQ__PrimaryQuote__c FROM OppLineItem__c WHERE Opportunity__c IN :opportunityIds ORDER BY Location360__c ASC]) 
            {
                Service_Sites__c loopRec_ServiceSite = new Service_Sites__c(
                    Account__c = loopRec_M4RGLoc.Opportunity__r.AccountId,
                    Building_Number__c = loopRec_M4RGLoc.Location360__r.HouseNumber__c,
                    City__c = loopRec_M4RGLoc.Location360__r.City__c,
                    Customer_Vertical__c = loopRec_M4RGLoc.Opportunity__r.Account.Account_Type__c,
                    Date_Sold__c = Date.today(),
                    Location360__c = loopRec_M4RGLoc.Location360__c,
                    MapcomStructureId__c = String.valueOf(loopRec_M4RGLoc.Location360__r.MapcomStructureId__c),
                    NEID__c = loopRec_M4RGLoc.Opportunity__c,
                    Opportunity__c = loopRec_M4RGLoc.Opportunity__c,
                    OwnerId = loopRec_M4RGLoc.Opportunity__r.OwnerId,
                    Region__c = loopRec_M4RGLoc.Opportunity__r.Region__c,
                    Reporting_Vertical__c = loopRec_M4RGLoc.Opportunity__r.RecordType.Name,
                    State__c = loopRec_M4RGLoc.Location360__r.State_Text__C,
                    Street_Address__c = loopRec_M4RGLoc.Location360__r.PreDirectional__c + ' '  + loopRec_M4RGLoc.Location360__r.Street_Name__c + ' '  + loopRec_M4RGLoc.Location360__r.Street_Suffix__c + ' '  + loopRec_M4RGLoc.Location360__r.PostDirectional__c,
                    Suite_Number__c = loopRec_M4RGLoc.Location360__r.UnitNumber__c,
                    Total_Contract_Value__c = mapQuotes?.get(loopRec_M4RGLoc.Opportunity__r.SBQQ__PrimaryQuote__c) == null ? 0 : mapQuotes.get(loopRec_M4RGLoc.Opportunity__r.SBQQ__PrimaryQuote__c).SBQQ__NetAmount__c,
                    Zip__c = loopRec_M4RGLoc.Location360__r.Zip_Postal__c,
                    On_Net__c = false,
                    M4RGL__c = loopRec_M4RGLoc.Id

                );

                if ( iCountExistingSrvSites > 0 &&  mpl_Existing_SrvSite_Locations.contains(loopRec_M4RGLoc.Location360__c) ) {
                    loopRec_ServiceSite.Id = strConcatExistingServiceSites.trim().left(18);
                    strConcatExistingServiceSites = strConcatExistingServiceSites.trim().right(strConcatExistingServiceSites.trim().length() - 18);
                    serviceSitesToUpdate.add(loopRec_ServiceSite);
                } else {
                    ZZ_OUTVAR_iCountNEWSrvSites ++;
                    serviceSitesToInsert.add(loopRec_ServiceSite);
                }
                locationIdToServiceSite.put(loopRec_ServiceSite.Location360__c, loopRec_ServiceSite);
            }

            if (!serviceSitesToUpdate.isEmpty()) {
                update serviceSitesToUpdate;
            }
            if (!serviceSitesToInsert.isEmpty()) {
                insert serviceSitesToInsert;
            }

            serviceSitesAll.addAll(serviceSitesToUpdate);
            serviceSitesAll.addAll(serviceSitesToInsert);

            if (!serviceSitesAll.isEmpty()) {
                System.debug('OpportunityTrigger.svcSiteTracker2');           
                Set<String> programNames = new Set<String>();
                for (Opportunity opp : opportunities) {
                    programNames.add('Opp:' + opp.Name + '[' + opp.Id + ']');
                    programNames.add('Opp:' + opp.Name.abbreviate(60) + '[' + String.valueOf(opp.Id).right(9) + ']');
                }
                
                Map<String, Id> programIdMap = new Map<String, Id>();
                for (Program__c program : [SELECT Name, Opportunity__c FROM Program__c WHERE Name IN :programNames]) 
                {
                    if (program.Opportunity__c != null) {
                        programIdMap.put(program.Opportunity__c, program.Id);
                    } else {
                        programIdMap.put(program.Name, program.Id);
                    }
                }
                
                List<Program__c> programsToUpsert = new List<Program__c>();
                
                for (Opportunity opp : opportunities) {
                    Id programId = programIdMap.get(opp.Id);
                    if (programId == null) {
                        if (programIdMap.containsKey('Opp:' + opp.Name + '[' + opp.Id + ']')) {
                            programId = programIdMap.get('Opp:' + opp.Name + '[' + opp.Id + ']');
                        } else if (programIdMap.containsKey('Opp:' + opp.Name.abbreviate(60) + '[' + String.valueOf(opp.Id).right(9) + ']')) {
                            programId = programIdMap.get('Opp:' + opp.Name.abbreviate(60) + '[' + String.valueOf(opp.Id).right(9) + ']');
                        }
                    }

                    programsToUpsert.add(new Program__c(
                        Id = programId,
                        Name = 'Opp:' + opp.Name.abbreviate(60) + '[' + String.valueOf(opp.Id).right(9) + ']',
                        OwnerId = opp.OwnerId,
                        Customer__c = opp.AccountId,
                        OppContract_Type__c = opp.Contract_Type__c,
                        Incremental_Change__c = opp.Incremental_Change__c,
                        Opportunity__c = opp.Id,
                        Total_Contract_Value__c = mapQuotes.get(opp.SBQQ__PrimaryQuote__c) == null ? 0 : mapQuotes.get(opp.SBQQ__PrimaryQuote__c).SBQQ__NetAmount__c,
                        Total_NRR_Sold__c = mapQuotes.get(opp.SBQQ__PrimaryQuote__c) == null ? 0 : mapQuotes.get(opp.SBQQ__PrimaryQuote__c).NRC_Total_Rev__c,
                        Total_MRR_Sold__c = mapQuotes.get(opp.SBQQ__PrimaryQuote__c) == null ? 0 : mapQuotes.get(opp.SBQQ__PrimaryQuote__c).MRC_Total_Rev__c,            
                        PrimaryQuote__c = opp.SBQQ__PrimaryQuote__c
                    ));
                }
                    
                try {
                    upsert programsToUpsert;
                } catch (Exception ex) {
                    System.debug('Exception svcSiteTracker2');
                    System.debug(ex.getMessage());
                    System.debug('getStackTraceString');
                    System.debug(ex.getStackTraceString());
                    System.debug('getTypeName');
                    System.debug(ex.getTypeName());
                    System.debug('getLineNumber');
                    System.debug(ex.getLineNumber());
                    System.debug('getCause');
                    System.debug(ex.getCause());
                }

                svcSiteTracker4(locationIdToServiceSite, quoteIdToOpportunity);
                svcSiteTracker5(opportunityIds, quoteIdToOpportunity.keySet(), serviceSitesAll);
                svcSiteTracker6(opportunityIds, mapQuotes, programsToUpsert, serviceSitesToInsert,  ZZ_OUTVAR_iCountNEWSrvSites, ZZ_OUTVAR_iCountNEWSrvSites + iCountExistingSrvSites);
            }
            
        } catch (Exception ex) {
            System.debug('Exception svcSiteTracker3');
            System.debug(ex.getMessage());
            System.debug('getStackTraceString');
            System.debug(ex.getStackTraceString());
            System.debug('getTypeName');
            System.debug(ex.getTypeName());
            System.debug('getLineNumber');
            System.debug(ex.getLineNumber());
            System.debug('getCause');
            System.debug(ex.getCause());
            for (Opportunity opp : Trigger.new) {
                opp.addError(ex.getMessage());
            }
        }
    }

    public static void svcSiteTracker4(Map<Id, Service_Sites__c> locationIdToServiceSite, Map<Id, Opportunity> quoteIdToOpportunity) {
        System.debug('OpportunityTrigger.svcSiteTracker4');
        List<Service_Site_Product__c> productsToInsert = new List<Service_Site_Product__c>();
        List<Service_Sites__c> serviceSitesToUpdate = new List<Service_Sites__c>();

        for (SBQQ__QuoteLine__c quoteLine : [SELECT Name, SBQQ__ProductCode__c, SBQQ__ProductName__c, MRC_Rev__c, NRC_Rev__c, SBQQ__Quantity__c, SBQQ__ListPrice__c, 
            SBQQ__Quote__c, Location360__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :quoteIdToOpportunity.keySet() AND SBQQ__Group__c != null AND SBQQ__Group__c != '']) 
        {
            if (locationIdToServiceSite.containsKey(quoteLine.Location360__c)) {
                Opportunity opp = quoteIdToOpportunity.get(quoteLine.SBQQ__Quote__c);
                productsToInsert.add(new Service_Site_Product__c(
                    Quote_Line__c = quoteLine.Id,
                    Product_Code__c = quoteLine.SBQQ__ProductCode__c,
                    Product_Name__c = quoteLine.SBQQ__ProductName__c,
                    MRC_Initial__c = quoteLine.MRC_Rev__c,
                    NRC_Upfront__c = quoteLine.NRC_Rev__c,
                    qlName__c = quoteLine.Name,
                    ql_Quantity__c = quoteLine.SBQQ__Quantity__c,
                    Quote_Line_Amount__c = quoteLine.SBQQ__ListPrice__c,
                    Service_Site_RecordID__c = locationIdToServiceSite.get(quoteLine.Location360__c).Id,
                    Service_Site__c = locationIdToServiceSite.get(quoteLine.Location360__c).Id,
                    Reporting_Vertical__c = opp?.RecordTypeId,
                    Contract_Signed__c = opp?.CloseDate,
                    Account__c = opp?.AccountId,
                    Opportunity__c = opp?.Id
                ));
                serviceSitesToUpdate.add(new Service_Sites__c(
                    Id = locationIdToServiceSite.get(quoteLine.Location360__c).Id,
                    On_Net__c = true
                ));
            }
        }

        if (!productsToInsert.isEmpty()) {
            try {
                insert productsToInsert;
                update serviceSitesToUpdate;
            } catch (Exception ex) {
                System.debug('Exception svcSiteTracker4');
                System.debug(ex.getMessage());
                System.debug('getStackTraceString');
                System.debug(ex.getStackTraceString());
                System.debug('getTypeName');
                System.debug(ex.getTypeName());
                System.debug('getLineNumber');
                System.debug(ex.getLineNumber());
                System.debug('getCause');
                System.debug(ex.getCause());
                for (Opportunity opp : Trigger.new) {
                    opp.addError(ex.getMessage());
                }
            }
        }
    }
    
    public static void svcSiteTracker5(Set<Id> opportunityIds, Set<Id> quoteIds, List<Service_Sites__c> coll_ServiceSites) {
        try {
            Integer iLoopVar = 0;
            List<Service_Site_Accounts__c> coll_SSAcounts = new List<Service_Site_Accounts__c>();
            List<Service_Site_Opportunities__c> coll_SSOpportunities = new List<Service_Site_Opportunities__c>();
            
            for (Service_Sites__c loopRec_ServiceSite : coll_ServiceSites) {
                iLoopVar ++;
                Service_Site_Accounts__c loopRec_SSAccounts = new Service_Site_Accounts__c();
                loopRec_SSAccounts.Account__c = loopRec_ServiceSite.Account__c;
                loopRec_SSAccounts.OwnerId = loopRec_ServiceSite.OwnerId;
                loopRec_SSAccounts.Service_Site__c = loopRec_ServiceSite.Id;
                loopRec_SSAccounts.Opportunity__c = loopRec_ServiceSite.Opportunity__c;
                coll_SSAcounts.add(loopRec_SSAccounts);
    
                Service_Site_Opportunities__c loopRec_SSOpportunities = new Service_Site_Opportunities__c();
                loopRec_SSOpportunities.Opportunity__c = loopRec_ServiceSite.Opportunity__c;
                loopRec_SSOpportunities.OwnerId = loopRec_ServiceSite.OwnerId;
                loopRec_SSOpportunities.Service_Site__c = loopRec_ServiceSite.Id;
                coll_SSOpportunities.add(loopRec_SSOpportunities);
            }
    
            if ( iLoopVar > 0 ) {
                insert coll_SSAcounts;
                insert coll_SSOpportunities;
            }
    
        } catch (Exception ex) {
            System.debug('Exception svcSiteTracker5');
            System.debug(ex.getMessage());
            System.debug('getStackTraceString');
            System.debug(ex.getStackTraceString());
            System.debug('getTypeName');
            System.debug(ex.getTypeName());
            System.debug('getLineNumber');
            System.debug(ex.getLineNumber());
            System.debug('getCause');
            System.debug(ex.getCause());
            for (Opportunity opp : Trigger.new) {
                opp.addError(ex.getMessage());
            }
        }
    }

    public static void svcSiteTracker6(Set<Id> opportunityIds, Map<Id, SBQQ__Quote__c> mapQuotes, List<Program__c> programs, List<Service_Sites__c> coll_NEW_ServiceSites, Integer iCountNewSrvSites, Integer iCountTotalSrvSite) {
        System.debug('OpportunityTrigger.svcSiteTracker6');
        try {

            if ( iCountTotalSrvSite > 0 ) {
                Map<Id, Program__c> mapPrograms = new Map<Id, Program__c>();
                Set<Id> programsIds = new Set<Id>();
                for (Program__c prog : programs) {
                    mapPrograms.put(prog.Opportunity__c, prog);
                    programsIds.add(prog.Id);
                }

                Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([
                    SELECT Id, Name, SBQQ__PrimaryQuote__c, OwnerId
                    FROM Opportunity
                    WHERE Id IN :opportunityIds
                ]);

                System.debug('programs');
                System.debug(programs);

                List<sitetracker__Project__c> coll_ExistingSTProjects = [
                    SELECT Id, sitetracker__ProjectTemplate__c, sitetracker__Site__c, OwnerId, Program__c, sitetracker__Project_Type__c,
                        Segment__c, Segment__r.sitetracker__Z_Location__c, Segment__r.sitetracker__Z_Location__r.Service_Site__c,
                        Segment__r.sitetracker__Z_Location__r.Service_Site__r.M4RGL__c, Segment__r.sitetracker__Z_Location__r.Service_Site__r.Total_MRC__c,
                        Segment__r.sitetracker__Z_Location__r.Service_Site__r.Total_NRC__c, Segment__r.sitetracker__Z_Location__r.Service_Site__r.Location360__c
                    FROM sitetracker__Project__c
                    WHERE Program__c IN :programsIds
                ];

                System.debug('coll_ExistingSTProjects');
                System.debug(coll_ExistingSTProjects);

                List<String> mpl_Existing_SrvSite_RecordIDs = new List<String>{'*****$$$$$9QQqq&&&'};
                List<String> mpl_Existing_STProject_RecordIDs = new List<String>{'*****$$$$$9QQqq&&&'};
                List<String> mpl_Existing_STSegment_RecordIDs = new List<String>{'*****$$$$$9QQqq&&&'};
                List<String> mpl_Existing_STSITE_RecordIDs = new List<String>{'*****$$$$$9QQqq&&&'};
                Integer iLoopVar_UPDATEs = 0;
                String strConcat_ServiceSite_RecordIDs = '';
                String strConcat_STProject_RecordIDs = '';
                String strConcat_STSegment_RecordIDs = '';
                String strConcat_STSite_RecordIDs = '';
                List<Service_Sites__c> tmpColl_ServiceSites = new List<Service_Sites__c>();

                for (sitetracker__Project__c rec_STProject : coll_ExistingSTProjects) {
                    System.debug('rec_STProject');
                    System.debug(rec_STProject);
                    System.debug('rec_STProject.Segment__r');
                    System.debug(rec_STProject.Segment__r);
                    System.debug('rec_STProject.Segment__r.sitetracker__Z_Location__r');
                    System.debug(rec_STProject.Segment__r?.sitetracker__Z_Location__r);
                    System.debug('rec_STProject.Segment__r.sitetracker__Z_Location__r.Service_Site__c');
                    System.debug(rec_STProject.Segment__r?.sitetracker__Z_Location__r?.Service_Site__c);
                    strConcat_STProject_RecordIDs += rec_STProject.Id;
                    strConcat_STSegment_RecordIDs += rec_STProject.Segment__c;
                    strConcat_STSite_RecordIDs += rec_STProject.Segment__r.sitetracker__Z_Location__c;
                    strConcat_ServiceSite_RecordIDs += rec_STProject.Segment__r.sitetracker__Z_Location__r.Service_Site__c;
                    mpl_Existing_SrvSite_RecordIDs.add(rec_STProject.Segment__r.sitetracker__Z_Location__r.Service_Site__c);
                    mpl_Existing_STSITE_RecordIDs.add(rec_STProject.Segment__r.sitetracker__Z_Location__c);
                    mpl_Existing_STSegment_RecordIDs.add(rec_STProject.Segment__c);
                    mpl_Existing_STProject_RecordIDs.add(rec_STProject.Id);
                    iLoopVar_UPDATEs ++;
                    
                    tmpColl_ServiceSites.add(new Service_Sites__c(
                        Id = rec_STProject.Segment__r.sitetracker__Z_Location__r.Service_Site__c,
                        Location360__c  = rec_STProject.Segment__r.sitetracker__Z_Location__r.Service_Site__r.Location360__c
                        //Total_MRC__c = rec_STProject.Segment__r.sitetracker__Z_Location__r.Service_Site__r.Total_MRC__c,
                        //Total_NRC__c = rec_STProject.Segment__r.sitetracker__Z_Location__r.Service_Site__r.Total_NRC__c
                    ));
                }

                if ( iCountNewSrvSites > 0 ) {                  
                    tmpColl_ServiceSites.addAll(coll_NEW_ServiceSites);
                }

                List<sitetracker__Site__c> coll_STSitesUPDATE = new List<sitetracker__Site__c>();
                List<sitetracker__Site__c> coll_STSitesINSERT = new List<sitetracker__Site__c>();
                List<sitetracker__Segment__c> coll_STSegmentsUPDATE = new List<sitetracker__Segment__c>();
                List<sitetracker__Segment__c> coll_STSegmentsINSERT = new List<sitetracker__Segment__c>();
                List<sitetracker__Project__c> coll_STProjectsUPDATE = new List<sitetracker__Project__c>();
                List<sitetracker__Project__c> coll_STProjectINSERT = new List<sitetracker__Project__c>();

                Set<Id> serviceSites = new Set<Id>();
                for (Service_Sites__c serviceSite : coll_NEW_ServiceSites) {
                    serviceSites.add(serviceSite.Id);
                }

                for (Service_Sites__c serviceSite : [SELECT Total_MRC__c, Total_NRC__c, Location360__r.Name, Location360__r.HouseNumber__c, Location360__r.Street_Name__c, 
                    Location360__r.Street_Suffix__c, Location360__r.UnitNumber__c, Location360__r.City__c, Location360__r.State_Text__c, Location360__r.Zip_Postal__c, Opportunity__r.SBQQ__PrimaryQuote__c,
                    Opportunity__r.Name, Opportunity__r.Id, Opportunity__r.SBQQ__PrimaryQuote__r.Name, Opportunity__c, Opportunity__r.OwnerId
                    FROM Service_Sites__c WHERE Id IN :serviceSites]) 
                {                
                    String locName = serviceSite.Location360__r?.Name == null ? '' : serviceSite.Location360__r.Name;
                    sitetracker__Site__c rec_STSite = new sitetracker__Site__c(
                        Name = locName + ' [' + serviceSite.Id + ']',
                        sitetracker__Site_Description__c = 'Loc '+ locName + ' ::  Opp ' + serviceSite.Opportunity__r.Name + ' :: Quo ' + serviceSite.Opportunity__r.SBQQ__PrimaryQuote__r.Name,
                        sitetracker__Street_Address__c = serviceSite.Location360__r.HouseNumber__c + ' ' + serviceSite.Location360__r.Street_Name__c + ' ' + serviceSite.Location360__r.Street_Suffix__c,
                        sitetracker__Street_Address_2__c = 'Unit ' + serviceSite.Location360__r.UnitNumber__c,
                        sitetracker__City__c = serviceSite.Location360__r.City__c,
                        sitetracker__State__c = serviceSite.Location360__r.State_Text__c,
                        sitetracker__Zip_Code__c = serviceSite.Location360__r.Zip_Postal__c,
                        sitetracker__Site_Type__c = 'Customer',
                        sitetracker__Site_Status__c = 'In Construction',
                        Service_Site__c = serviceSite.Id,
                        OwnerId = serviceSite.Opportunity__r.OwnerId
                        // OwnerId = '0051C000008amm0QAA'
                    );

                    System.debug('mpl_Existing_SrvSite_RecordIDs');
                    System.debug(mpl_Existing_SrvSite_RecordIDs);
                    System.debug('serviceSite.Id');
                    System.debug(serviceSite.Id);
                    System.debug('iLoopVar_UPDATEs');
                    System.debug(iLoopVar_UPDATEs);

                    if ( iLoopVar_UPDATEs > 0 && mpl_Existing_SrvSite_RecordIDs.contains(serviceSite.Id) ) {
                        rec_STSite.Id = strConcat_STSite_RecordIDs.trim().left(18);
                        coll_STSegmentsUPDATE.add(new sitetracker__Segment__c(
                            sitetracker__Z_Location__c = strConcat_STSite_RecordIDs.trim().left(18),
                            OwnerId = rec_STSite.OwnerId,
                            Id = strConcat_STSegment_RecordIDs.trim().left(18)
                        ));
                        coll_STProjectsUPDATE.add(new sitetracker__Project__c(
                            OwnerId = serviceSite.Opportunity__r.OwnerId,
                            Program__c = mapPrograms.get(serviceSite.Opportunity__c) != null ? mapPrograms.get(serviceSite.Opportunity__c).Id : '',
                            sitetracker__Project_Type__c = 'Customer - New Build',
                            Segment__c = strConcat_STSegment_RecordIDs.trim().left(18),
                            Id = strConcat_STProject_RecordIDs.trim().left(18),
                            Total_MRC__c = serviceSite.Total_MRC__c,
                            Total_NRC__c = serviceSite.Total_NRC__c
                            // sitetracker__ProjectTemplate__c = 'a3i1C00000022e7QAA'
                        ));
                        coll_STSitesUPDATE.add(rec_STSite);
                        
                        strConcat_STSite_RecordIDs = strConcat_STSite_RecordIDs.trim().right(strConcat_STSite_RecordIDs.trim().length() - 18);
                        strConcat_STSegment_RecordIDs = strConcat_STSegment_RecordIDs.trim().right(strConcat_STSegment_RecordIDs.trim().length() - 18);
                        strConcat_STProject_RecordIDs = strConcat_STProject_RecordIDs.trim().right(strConcat_STProject_RecordIDs.trim().length() - 18);
                    } else {
                        coll_STSitesINSERT.add(rec_STSite);
                    }
                }

                String str_STSite_UPDATE_ID = 'INS:' + coll_STSitesINSERT.size() + ' UPD:' + iLoopVar_UPDATEs + ' TOT:' + (coll_STSitesUPDATE.size() + coll_STSitesINSERT.size());

                if ( !coll_STSitesINSERT.isEmpty() ) {

                    insert coll_STSitesINSERT;

                    for (sitetracker__Site__c rec_STSite : coll_STSitesINSERT) {
                        coll_STSegmentsINSERT.add(new sitetracker__Segment__c(
                            sitetracker__Z_Location__c = rec_STSite.Id,
                            OwnerId = rec_STSite.OwnerId
                        ));
                    }

                    insert coll_STSegmentsINSERT;

                    for (sitetracker__Segment__c rec_STSegment : coll_STSegmentsINSERT) {
                        String ownerId = UserInfo.getUserId();
                        if (mapOpportunities.containsKey(rec_STSegment.sitetracker__Z_Location__r.Service_Site__r.Opportunity__c))
                            ownerId = mapOpportunities.get(rec_STSegment.sitetracker__Z_Location__r.Service_Site__r.Opportunity__c).OwnerId;

                        coll_STProjectINSERT.add(new sitetracker__Project__c(
                            OwnerId = ownerId,
                            Program__c = mapPrograms.get(rec_STSegment.sitetracker__Z_Location__r.Service_Site__r.Opportunity__c)?.Id,
                            sitetracker__Project_Type__c = 'Customer - New Build',
                            Segment__c = rec_STSegment.Id,
                            Total_MRC__c = rec_STSegment.sitetracker__Z_Location__r.Service_Site__r.Total_MRC__c,
                            Total_NRC__c = rec_STSegment.sitetracker__Z_Location__r.Service_Site__r.Total_NRC__c,
                            sitetracker__ProjectTemplate__c = Test.isRunningTest() ? OpportunityTriggerTest.testTemplate.Id : 'a3ie0000001J1QAAA0'
                        ));
                    }

                    insert coll_STProjectINSERT;
                } 

                if ( iLoopVar_UPDATEs > 0 ) {
                    update coll_STSitesUPDATE;
                    update coll_STSegmentsUPDATE;
                    update coll_STProjectsUPDATE;
                }
                 
            }

        } catch (Exception ex) {
            System.debug('Exception svcSiteTracker6');
            System.debug(ex.getMessage());
            System.debug('getStackTraceString');
            System.debug(ex.getStackTraceString());
            System.debug('getTypeName');
            System.debug(ex.getTypeName());
            System.debug('getLineNumber');
            System.debug(ex.getLineNumber());
            System.debug('getCause');
            System.debug(ex.getCause());
            for (Opportunity opp : Trigger.new) {
                opp.addError(ex.getMessage());
            }
        }
    }
}
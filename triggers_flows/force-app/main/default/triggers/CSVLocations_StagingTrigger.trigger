trigger CSVLocations_StagingTrigger on CSVLocations_Staging__c (before insert) {

    if ( Trigger.isInsert && Trigger.isBefore) {
        System.debug('CSVLocations_StagingTrigger.Trigger.isBefore && Trigger.isInsert');
        aaCSVLocationsStaging(Trigger.new);
    }

    public static void aaCSVLocationsStaging(List<CSVLocations_Staging__c> csvLocationsStaging) {
        try {
            List<String> fullAddresses = new List<String>();
            List<String> opportunityIds = new List<String>();

            for (CSVLocations_Staging__c csvLocation : csvLocationsStaging) {
                if ( !String.isBlank(csvLocation.FullAddress__c) ) {
                    fullAddresses.add(csvLocation.FullAddress__c);
                } 
                
                if ( csvLocation.OpportunityID__c != null ) {
                    opportunityIds.add(csvLocation.OpportunityID__c);
                } 

                csvLocation.txtStatus__c = '';
            }

            Map<String, Location__c> mapLocations = new Map<String, Location__c>();
            for (Location__c loc : [SELECT Id, Name FROM Location__c WHERE Name IN :fullAddresses]) {
                mapLocations.put(loc.Name, loc);
            }

            Map<String, Opportunity> mapLOpportunities = new Map<String, Opportunity>();
            Set<Id> oppIds = new Set<Id>();
            for (Opportunity opp : [SELECT Id, Name, OpportunityID__c FROM Opportunity WHERE OpportunityID__c IN :opportunityIds]) {
                mapLOpportunities.put(opp.OpportunityID__c, opp);
                oppIds.add(opp.Id);
            }

            Map<String, Location__c> mapRec_Location = new Map<String, Location__c>();
            for (CSVLocations_Staging__c csvLocation : csvLocationsStaging) {
                Location__c rec_Location = new Location__c();
                rec_Location.HouseNumber__c = csvLocation.HouseNumber__c;
                rec_Location.StreetName__c = csvLocation.StreetName__c;
                rec_Location.StreetSuffix__c = csvLocation.StreetSuffix__c;
                rec_Location.City__c = csvLocation.City__c;
                rec_Location.State__c = csvLocation.State__c;
                rec_Location.Zip_Code__c = csvLocation.Zip_Code__c;
                rec_Location.Name = csvLocation.FullAddress__c;

                if (mapLocations?.get(csvLocation.FullAddress__c) != null) {
                    rec_Location.Id = mapLocations.get(csvLocation.FullAddress__c).Id;
                }

                if ( mapLOpportunities?.get(csvLocation.OpportunityID__c) == null ) {
                    csvLocation.txtStatus__c = 'FAIL: Opportunity doesn\'t exist';
                } else {
                    if ( mapLocations?.get(csvLocation.FullAddress__c) == null ) {
                        mapRec_Location.put(csvLocation.Id, rec_Location);
                        csvLocation.txtStatus__c += '|Location Created';
                    } else {
                        csvLocation.txtStatus__c += '|Location EXISTs';
                    }
                }
            }

            if ( !mapRec_Location.values().isEmpty() ) {
                System.debug(mapRec_Location.values().isEmpty());
                insert mapRec_Location.values();
            }            

            Set<Id> locationsId = new Set<Id>();
            for (Location__c loc : mapRec_Location.values()) {
                locationsId.add(loc.Id);
            }
            for (Location__c loc : mapLocations.values()) {
                locationsId.add(loc.Id);
            }

            System.debug(locationsId);

            Map<String, OppLineItem__c> mapM4RGLoc = new Map<String, OppLineItem__c>();
            for (OppLineItem__c recM4loc : [SELECT Id, Name, Location__c
                                            FROM OppLineItem__c
                                            WHERE Opportunity__c IN :oppIds
                                            AND Name IN :fullAddresses
                                            AND Location__c IN :locationsId]) {
                mapM4RGLoc.put(recM4loc.Name, recM4loc);
            }

            System.debug(mapM4RGLoc);

            List<OppLineItem__c> listRecM4Locs = new List<OppLineItem__c>();
            for (CSVLocations_Staging__c csvLocation : csvLocationsStaging) {
                if ( mapLOpportunities?.get(csvLocation.OpportunityID__c) != null ) {
                    OppLineItem__c rec_M4RGLoc = new OppLineItem__c();
                    rec_M4RGLoc.Opportunity__c = mapLOpportunities.get(csvLocation.OpportunityID__c).Id;
                    rec_M4RGLoc.Location__c = mapRec_Location?.get(csvLocation.Id) != null ? mapRec_Location.get(csvLocation.Id).Id : mapLocations.get(csvLocation.FullAddress__c).Id;
                    rec_M4RGLoc.Name = csvLocation.FullAddress__c;

                    if (mapM4RGLoc?.get(csvLocation.FullAddress__c) != null) {
                        csvLocation.txtStatus__c += '|M4RevGenLoc EXISTs';
                    } else {
                        listRecM4Locs.add(rec_M4RGLoc);
                        csvLocation.txtStatus__c += '|M4RevGenLoc Created';
                    }
                }
            }

            if ( !listRecM4Locs.isEmpty() ) {
                insert listRecM4Locs;
            }  

        } catch (Exception ex) {
            System.debug('Exception aaCSVLocationsStaging');
            System.debug(ex);
        }
    }
}
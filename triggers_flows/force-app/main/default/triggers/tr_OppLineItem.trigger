trigger tr_OppLineItem on OppLineItem__c (before insert, before update) {
    for(OppLineItem__c oli: Trigger.New)
    {
        // get full address, if there is location360
        oli.Name = [SELECT Full_Address__c FROM Location360__c WHERE Id = :oli.Location360__c]?.Full_Address__c;
    }

    if ( Trigger.isInsert && Trigger.isBefore) {
        System.debug('tr_OppLineItem.Trigger.isBefore && Trigger.isInsert');
        revGenLocationActions(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }

    if ( Trigger.isUpdate && Trigger.isBefore) {
        System.debug('tr_OppLineItem.Trigger.isBefore && Trigger.isUpdate');
        revGenLocationActions(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }

    public static void revGenLocationActions(List<OppLineItem__c> revGenLocations, Map<Id, OppLineItem__c> oldMapOppLines, Map<Id, OppLineItem__c> newMapOppLines) {
        try {
            List<String> namesServiceableZipCodes = new List<String>();
            for (OppLineItem__c oppLine : revGenLocations) {
                if ( !String.isBlank(oppLine.Zip_Code__c ) &&
                     ( oldMapOppLines?.get(oppLine.Id).Zip_Code__c != newMapOppLines?.get(oppLine.Id).Zip_Code__c || String.isBlank(oppLine.Serviceable__c) ) ) {
                        namesServiceableZipCodes.add(oppLine.Zip_Code__c);
                } 
            }

            List<Serviceable_Zip_Codes__c> zipCodes = [
                SELECT Id, ICB__c, Name, Serviceability_Lookup__c
                FROM Serviceable_Zip_Codes__c
                WHERE Name IN :namesServiceableZipCodes
            ];

            for (OppLineItem__c oppLine : revGenLocations) {
                if ( !zipCodes.isEmpty() ) {
                    for ( Serviceable_Zip_Codes__c zipCode : zipCodes ) {
                        if ( oppLine.Zip_Code__c.equals(zipCode.Name) && zipCode.ICB__c.equals('ICB') && !String.isBlank(zipCode.Id) ) {
                            oppLine.Serviceable__c = 'ICB';
                        } else if ( oppLine.Zip_Code__c.equals(zipCode.Name) && !zipCode.ICB__c.equals('ICB') && !String.isBlank(zipCode.Id) ) {
                            oppLine.Serviceable__c = 'Serviceable';
                        }
                    }
                } else {
                    oppLine.Serviceable__c = 'Not Serviceable';
                }
            }
            
        } catch (Exception ex) {
            System.debug('Exception revGenLocationActions');
            System.debug(ex.getMessage());
        }
    }
}
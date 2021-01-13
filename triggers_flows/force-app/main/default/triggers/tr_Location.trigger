trigger tr_Location on Location__c (before insert) {
    for(Location__c loc: Trigger.new)
    {
        loc.Name = loc.FullAddress__c;
    }
}
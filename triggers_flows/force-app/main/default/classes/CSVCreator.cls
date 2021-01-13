public class CSVCreator {

    private static List<String> separateCommas(String input){
        List<String> results = input.split(',');
        for(String result : results) {
            result = result.trim();
        }
        return results;
    }

    @AuraEnabled(cacheable=true)
    public static CSVObject getCSVObject(String csvStr) {
        List<String> linesRaw = csvStr.split('\n');
        List<String> headersRaw = separateCommas(linesRaw[0]);
        List<List<String>> lines = new List<List<String>>();
        List<CSVHeader> headers = new List<CSVHeader>();
        linesRaw.remove(0);

        //Handling fields with commas
        for(String line : linesRaw) {
            List<String> lineSep = separateCommas(line);
            List<String> fields = new List<String>();
            Boolean makeCompositeField = false;
            String compositeField;
            for(String field : lineSep) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    fields.add(field.trim());
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    fields.add(compositeField.trim());
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                compositeField += ',' + field;
                } else {
                    fields.add(field.trim());
                }
            }
            lines.add(fields);
        }

        for(String header : headersRaw) {
            headers.add(new CSVHeader(header));
        }

        return new CSVObject(headers, lines);
    }

    @AuraEnabled
    public static void updateLocation360(String jsonData){
        List<Object> data = (List<Object>) JSON.deserializeUntyped(jsonData);
        List<Location360__c> loc360s = new List<Location360__c>();

        for(Object obj : data){
            Map<String,Object> objFields = (Map<String,Object> )obj;
            Location360__c newLoc360 = new Location360__c();
            newLoc360.Atlas__c = (String)objFields.get('Atlas__c');
            newLoc360.City__c = (String)objFields.get('City__c');
            //newLoc360.Full_Address__c= objFields.get('Full_Address__c');
            newLoc360.House_Number__c = (String)objFields.get('House_Number__c');
            //newLoc360.Lat_Long__c = objFields.get('Lat_Long__c');
            newLoc360.Name = (String)objFields.get('Name');
            newLoc360.MapcomStructureId__c = (Decimal)objFields.get('MapcomStructureId__c');
            newLoc360.PostDirectional__c = (String)objFields.get('PostDirectional__c');
            newLoc360.PreDirectional__c = (String)objFields.get('PreDirectional__c');
            newLoc360.Id = (Id)objFields.get('Loc360Id');
        }

        upsert loc360s;
    }
}
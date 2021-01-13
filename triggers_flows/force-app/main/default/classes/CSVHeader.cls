public class CSVHeader {
    @AuraEnabled
    public String columnName {get; set;}
   
    @AuraEnabled
    public String columnType {get; set;}
   
    public CSVHeader(String columnName, String columnType) {
        this.columnName = columnName;
        this.columnType = columnType;
    }

    public CSVHeader(String columnName) {
        this(columnName, '');
    }
}
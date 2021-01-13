public class CSVObject {
    
    @AuraEnabled
    public List<CSVHeader> headers {get; set;}
   
    @AuraEnabled
    public List<List<String>> lines {get; set;}

    @AuraEnabled
    public List<List<String>> linesOnPage {get; set;}
   
    @AuraEnabled
    public Integer lineCount {get; set;}
   
    public CSVObject(List<CSVHeader> headers, List<List<String>> lines) {
        this.headers = headers;
        this.lines = lines;
        this.lineCount = lines.size();
    }
}
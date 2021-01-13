@isTest
private class importDataFromCSVControllerTestClass {
    static testMethod void validatefunction1() {
    importDataFromCSVController testClass = new importDataFromCSVController();
    testClass.bRunTest=TRUE;
    testClass.readContactsFromFile();
    testClass.readContactsCSVFile();
    testClass.saveContactData();
    testClass.readCSVLocationsFromFile();
    testClass.readCSVLocationsCSVFile();
    testClass.saveCSVLocationsData();
    return;
    }
}
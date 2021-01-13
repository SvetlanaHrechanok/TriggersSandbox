@isTest
public class CSVCreatorTest {

    @isTest
    static void getCSVObjectTest(){
        String testString = '';
        testString += 'Series_reference,Period,Data_value,Suppressed,STATUS,UNITS,Magnitude,Subject,Group,Series_title_1,,,,Series_title_5' + '\n';
        testString += 'BDCQ.SF1AA2CA,2016.06,1116.386,,F,Dollars,6,Business Data Collection - BDC,Industry by financial variable,Sales (operating income),,,,' + '\n';
        testString += 'BDCQ.SF1AA2CA,2016.09,1070.874,,F,Dollars,6,Business Data Collection - BDC,Industry by financial variable,Sales (operating income),,,,';

        CSVObject obj = CSVCreator.getCSVObject(testString);

        System.assertNotEquals(obj.headers.get(0), null);
        System.assertNotEquals(obj.headers.get(0).columnName, '');
        System.assertEquals(obj.headers.get(0).columnType, '');

        System.assertEquals(obj.lineCount, 2);
    }
}
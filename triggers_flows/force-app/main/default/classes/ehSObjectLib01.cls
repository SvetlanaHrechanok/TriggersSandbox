public class ehSObjectLib01 {

    public static String strCommaFieldList(String apiName) {
        SObjectType objType = ((SObject) (Type.forName('Schema.' + apiName).newInstance())).getSObjectType();
        Map<String, SObjectField> fieldsByName = objType.getDescribe().fields.getMap();
    
        String customFields = '';
        String newField = '';
        String strComma = '';
        
        for (SObjectField field : fieldsByName.values()) {
            newField='';
            strComma='';
            if(field.getDescribe().isAccessible()){
                if(customFields.Length() > 0)
                    strComma = ', ';

                newField = field.getDescribe().getName();
                
                if( ( newField != 'LastViewedDate' ) && ( newField != 'LastReferencedDate' ) && ( newField != 'xxxxxxxxxxxxxx' ) )
                {
                    
                    customFields = customFields + strComma + newField;
                }
                    
            }
        }
        
        return customFields;
    }

    public static List<SObject> soObjectFromQueryFixed(string strSObject, string strWHERE, string strORDERBY, string strLIMIT) {
        string strFieldList = strCommaFieldList(strSObject);
    
        string strQuery = 'SELECT ' + strFieldList + ' FROM '+strSObject;
        if( strWHERE.Length() > 0 )
            strQuery = strQuery + ' WHERE ' + strWHERE;
        if( strORDERBY.Length() > 0 )
            strQuery = strQuery + ' ORDER BY ' + strORDERBY;
        if( strLIMIT.Length() > 0 )
            strQuery = strQuery + ' LIMIT ' + strLIMIT;
        
        List<SObject> listQueryResult = Database.query(strQuery);
            return listQueryResult;
    }
    
    public static List<SObject> soObjectFromQueryCustom(string strSObject, string strWHERE, string strORDERBY, string strLIMIT, string strColumns) {
        string strFieldList = strColumns;
    
        string strQuery = 'SELECT ' + strFieldList + ' FROM '+strSObject;
        if( strWHERE.Length() > 0 )
            strQuery = strQuery + ' WHERE ' + strWHERE;
        if( strORDERBY.Length() > 0 )
            strQuery = strQuery + ' ORDER BY ' + strORDERBY;
        if( strLIMIT.Length() > 0 )
            strQuery = strQuery + ' LIMIT ' + strLIMIT;
        
        List<SObject> listQueryResult = Database.query(strQuery);
            return listQueryResult;
    }
    
    public static List<Id> fnListIDs(List<SObject> lstQueryResults, string strGetField) {
        if( String.IsBlank(strGetField))
            strGetField = 'Id';
        List<Id> lstReturnIds = new List<Id>();
        
        for(integer i = 0; i < lstQueryResults.size(); i++)
        {
            lstReturnIds.add((Id)lstQueryResults[i].get(strGetField));
            //System.debug(lstQueryResults[i].get(strGetField));
        }
            return lstReturnIds ;
    }
}
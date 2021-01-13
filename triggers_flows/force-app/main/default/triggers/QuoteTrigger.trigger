trigger QuoteTrigger on SBQQ__Quote__c (after insert, before insert, before update) {

    if ( Trigger.isInsert && Trigger.isBefore) {
        System.debug('QuoteTrigger.Trigger.isBefore && Trigger.isInsert');
        approvalMatrix(Trigger.new);
        includeDocuments(Trigger.new);
        setApprovers(Trigger.new);
        setTerms(Trigger.new, Trigger.oldMap, Trigger.newMap);
        updateDraftRecordTypeOnClonedQuote(Trigger.new);
    }

    if ( Trigger.isInsert && Trigger.isAfter) {
        System.debug('QuoteTrigger.Trigger.isAfter && Trigger.isInsert');
        quoteLineGroupCreate(Trigger.new);
    }

    if ( Trigger.isUpdate && Trigger.isBefore) {
        System.debug('QuoteTrigger.Trigger.isBefore && Trigger.isUpdate');
        approvalMatrix(Trigger.new);
        includeDocuments(Trigger.new);
        setApprovers(Trigger.new);
        setTerms(Trigger.new, Trigger.oldMap, Trigger.newMap);
        updateDraftRecordTypeOnClonedQuote(Trigger.new);
    }

    public static void approvalMatrix(List<SBQQ__Quote__c> quotes) {
        try {
            for (SBQQ__Quote__c quote : quotes) {
                
                Decimal whichisHigher = ( quote?.GP_Payback_AE_Approval__c == null ? 0 : quote.GP_Payback_AE_Approval__c ) +
                                        ( quote?.GP_Payback_ASM_Approval__c == null ? 0 : quote.GP_Payback_ASM_Approval__c ) + 
                                        ( quote?.GP_Payback_VP_Approval__c == null ? 0 : quote.GP_Payback_VP_Approval__c ) + 
                                        ( quote?.GP_Payback_Exec_Approval__c == null ? 0 : quote.GP_Payback_Exec_Approval__c );
                Decimal var_GPApprovalLevel = whichisHigher;

                if ( quote.Gross_Profit_Approval__c == var_GPApprovalLevel ) {
                    //Same Level
                    if ( quote.Gross_Profit_Approval__c == 1 && quote.GP_Payback_AE_Approval__c == 1 ) {
                        //AE Approval
                        quote.Approval_Level__c = 'AE Approval';
                    } else if ( quote.Gross_Profit_Approval__c == 2 && quote.GP_Payback_ASM_Approval__c == 2 ) {
                        //ASM Approval
                        quote.Approval_Level__c = 'ASM Approval';
                    } else if ( quote.Gross_Profit_Approval__c == 3 && quote.GP_Payback_VP_Approval__c == 3 ) {
                        //VP Approval
                        quote.Approval_Level__c = 'VP Approval';
                    } else if ( quote.Gross_Profit_Approval__c == 4 && quote.GP_Payback_Exec_Approval__c == 4 ) {
                        //Exec Approval
                        quote.Approval_Level__c = 'Joel Weinbach';
                    } else {
                        //Default Outcome 
                        quote.Approval_Level__c = 'N/A';
                    }
                } else {
                    //Default Outcome 
                    if ( var_GPApprovalLevel > quote.Gross_Profit_Approval__c ) {
                        //Payback Greater
                        if ( var_GPApprovalLevel == 1 ) {
                            //AE Approval
                            quote.Approval_Level__c = 'AE Approval';
                        } else if ( var_GPApprovalLevel == 2 ) {
                            //ASM Approval
                            quote.Approval_Level__c = 'ASM Approval';
                        } else if ( var_GPApprovalLevel == 3 ) {
                            //VP Approval
                            quote.Approval_Level__c = 'VP Approval';
                        } else if ( var_GPApprovalLevel == 4 ) {
                            //Exec Approval
                            quote.Approval_Level__c = 'Joel Weinbach';
                        } else {
                            //Default Outcome 
                            quote.Approval_Level__c = 'VP Approval';
                        }
                    } else if ( quote.Gross_Profit_Approval__c > var_GPApprovalLevel ) {
                        //Gross Profit Greater
                        if ( quote.Gross_Profit_Approval__c == 1 ) {
                            //AE Approval
                            quote.Approval_Level__c = 'AE Approval';
                        } else if ( quote.Gross_Profit_Approval__c == 2 ) {
                            //ASM Approval
                            quote.Approval_Level__c = 'ASM Approval';
                        } else if ( quote.Gross_Profit_Approval__c == 3 ) {
                            //VP Approval
                            quote.Approval_Level__c = 'VP Approval';
                        } else if ( quote.Gross_Profit_Approval__c == 4 ) {
                            //Exec Approval
                            quote.Approval_Level__c = 'Joel Weinbach';
                        } else {
                            //Default Outcome 
                            quote.Approval_Level__c = 'N/A';
                        }
                    } else {
                        //Default Outcome 
                        quote.Approval_Level__c = 'VP Approval';
                    }
                }
            }
        } catch (Exception ex) {
            System.debug('approvalMatrix');
            System.debug(ex.getMessage());
        }
    }

    public static void includeDocuments(List<SBQQ__Quote__c> quotes) {
        try {
            for (SBQQ__Quote__c quote : quotes) {
                //LOA
                if ( quote.Exclude_Enterprise_Cust_LOA__c == false && quote.Transfer_Number_Service_Count__c == 0 && quote.Voice_Services_Count__c == 0 ) {
                    quote.Include_LOA_Document__c = true;
                }
                //Enterprise Cust 911
                if ( quote.Exclude_Enterprise_Cust_911_Acknowledgem__c == false && quote.Voice_Services_Count__c == 0 ) {
                    quote.Exclude_Enterprise_Cust_911_Acknowledgem__c = true;
                }
                //Enterprise-Cust-IP Justification
                if ( quote.Exclude_Enterprise_Cust_IP_Justification__c == false && quote.Static_IPs_Over_5_Count__c == 0 ) {
                    quote.Exclude_Enterprise_Cust_IP_Justification__c = true;
                }
                //Enterprise-Cust-T&amp;Cs Attachment
                if ( quote.Exclude_Enterprise_Cust_T_Cs_Attachment__c == false && quote.Voice_Services_Count__c == 0 ) {
                    quote.Exclude_Enterprise_Cust_T_Cs_Attachment__c = true;
                }
                //RespOrg Document
                if ( quote.Transfer_Toll_Free_Count__c == 0 ) {
                    quote.Include_RespOrg_Document__c = true;
                }
            }
        } catch (Exception ex) {
            System.debug('Exception includeDocuments');
            System.debug(ex.getMessage());
        }
    }

    public static void setApprovers(List<SBQQ__Quote__c> quotes) {
        try {
            for (SBQQ__Quote__c quote : quotes) {
                quote.ASM_Approver__c = !String.isBlank(quote.SBQQ__SalesRep__r.ASM_Approver__c) ? quote.SBQQ__SalesRep__r.ASM_Approver__c : quote.SBQQ__SalesRep__c;
                quote.VP_Approver__c = !String.isBlank(quote.SBQQ__SalesRep__r.VP_Approver__c) ? quote.SBQQ__SalesRep__r.VP_Approver__c : quote.SBQQ__SalesRep__c;
            }
        } catch (Exception ex) {
            System.debug('Exception setApprovers');
            System.debug(ex.getMessage());
        }
    }

    public static void setTerms(List<SBQQ__Quote__c> quotes, Map<Id, SBQQ__Quote__c> oldMapQuotes, Map<Id, SBQQ__Quote__c> newMapQuotes) {
        try {
            for (SBQQ__Quote__c quote : quotes) {
                if ( oldMapQuotes?.get(quote.Id).Term_Length__c != newMapQuotes?.get(quote.Id).Term_Length__c || String.isBlank(String.valueOf(quote.SBQQ__SubscriptionTerm__c)) ) {
                    quote.SBQQ__SubscriptionTerm__c = Decimal.valueOf(quote.Term_Length__c) * 12;
                }
            }
        } catch (Exception ex) {
            System.debug('Exception setTerms');
            System.debug(ex.getMessage());
        }
    }

    public static void updateDraftRecordTypeOnClonedQuote(List<SBQQ__Quote__c> quotes) {
        try {
            for (SBQQ__Quote__c quote : quotes) {
                String recordTypeName = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosById().get(quote.RecordTypeId).getName();
                if ( quote.SBQQ__Status__c == 'Draft' && recordTypeName == 'Approved' ) {
                    quote.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
                }
            }
        } catch (Exception ex) {
            System.debug('Exception updateDraftRecordTypeOnClonedQuote');
            System.debug(ex.getMessage());
        }
    }

    public static void quoteLineGroupCreate(List<SBQQ__Quote__c> quotes) {
        try {
            Set<Id> opportunityIds = new Set<Id>();
            for (SBQQ__Quote__c quote : quotes) {
                if ( quote.SBQQ__Opportunity2__c != null ) opportunityIds.add(quote.SBQQ__Opportunity2__c);
            }

            if ( !opportunityIds.isEmpty() ) {
                List<OppLineItem__c> revGenLocations = [
                    SELECT Id, Opportunity__c, Name, Location__c
                    FROM OppLineItem__c
                    WHERE Opportunity__c IN :opportunityIds
                ];

                List<SBQQ__QuoteLineGroup__c> lineGroups = new List<SBQQ__QuoteLineGroup__c>();

                for (SBQQ__Quote__c quote : quotes) {
                    for (OppLineItem__c revGenLocation : revGenLocations) {
                        if ( quote.SBQQ__Opportunity2__c == revGenLocation.Opportunity__c ) {
                            SBQQ__QuoteLineGroup__c lineGroup = new SBQQ__QuoteLineGroup__c(
                                M4_RevGen_Location__c = revGenLocation.Id,
                                Name = revGenLocation.Name,
                                SBQQ__Quote__c = quote.Id,
                                SBQQ__Number__c = 10,
                                SBQQ__ListTotal__c = 0,
                                SBQQ__CustomerTotal__c = 0,
                                SBQQ__NetTotal__c = 0
                            );
                            lineGroups.add(lineGroup);
                        }
                    }
                }

                insert lineGroups;
            }
            
        } catch (Exception ex) {
            System.debug('Exception quoteLineGroupCreate');
            System.debug(ex.getMessage());
        }
    }
}
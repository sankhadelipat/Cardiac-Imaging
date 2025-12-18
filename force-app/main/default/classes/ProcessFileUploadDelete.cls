public class ProcessFileUploadDelete {
    
    public static void handleDeletedContentDocuments(List<ContentDocument> deletedDocuments) {
        System.debug('### Handling deleted ContentDocument records');

        // Define the mapping of Title Prefixes to Opportunity Fields
        Map<String, String> titleToFieldMap = new Map<String, String>{
            'CMS Approval Letter' => 'CMS_Approval_Letter__c',
            'State Approval Letter' => 'State_Approval_Letter__c',
            'Medical Supervision' => 'Medical_Supervision_Status__c',
            'Parking Acknowledgement (PA)' => 'Parking_Acknowledgement_PA__c',
            'ABIM Screenshot' => 'ABIM_Screenshot__c',
            'CMS 855b form' => 'CMS_855b_form__c',
            'ACLS' => 'ACLS__c',
            'Medical License' => 'Medical_License__c',
            'Board Certifications' => 'Board_Certifications__c',
            'Certification Board of Nuclear Cardiology' => 'Certification_Board_of_Nuclear_Cardiolog__c',
            'Current Radioactive Materials License' => 'Current_Radioactive_Materials_License__c',
            'Vetting Report Completed and Approval to Interpret' => 'Vetting_Report_Completed_and_Approval_to__c',
            'Parking Drawing' => 'Parking_Drawing__c',
            'Parking Verification Form' => 'Parking_Verification_Form__c',
            'Due diligence' => 'Due_diligence__c',
            'W9' => 'W9__c',
            'Direct Deposit Form (ACH)' => 'Direct_Deposit_Form_ACH__c',
            'CRM License' => 'CRM_License__c',
            'Physician Availability' => 'Physician_Availability__c',
            'Physician Cv' => 'Physician_Cv__c',
            'SPECT EHR Export' => 'SPECT_EHR_Export__c',
            'Parking Agreement' => 'Parking_Agreement_status__c',
            'W92 optional' => 'W92_optional__c',
            'ACH optional' => 'ACH_optional__c'
        };

        

        Set<Id> contentDocumentIds = new Set<Id>();
        Map<Id, String> contentDocToFieldMap = new Map<Id, String>(); // Maps ContentDocId to the field name to update

        for (ContentDocument cd : deletedDocuments) {
            System.debug('### Checking Deleted File: ' + cd.Title);

            for (String prefix : titleToFieldMap.keySet()) {
                if (cd.Title.startsWith(prefix)) {
                    contentDocumentIds.add(cd.Id);
                    contentDocToFieldMap.put(cd.Id, titleToFieldMap.get(prefix));
                    break; // No need to check other prefixes once matched
                }
            }
        }

       
        System.debug('### Collected ContentDocumentIds: ' + contentDocumentIds);

        // Get related Opportunity IDs before the files are deleted
        Map<Id, Id> contentDocToOppMap = new Map<Id, Id>();
        for (ContentDocumentLink cdl : [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :contentDocumentIds
        ]) {
            System.debug('### Found ContentDocumentLink: ' + cdl);
        
                contentDocToOppMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
           
        }

       

        // Prepare Opportunity updates
        Map<Id, Opportunity> oppUpdates = new Map<Id, Opportunity>();
        for (Id contentDocId : contentDocToOppMap.keySet()) {
            Id oppId = contentDocToOppMap.get(contentDocId);
            String oppFieldName = contentDocToFieldMap.get(contentDocId);

           
                Opportunity opp = oppUpdates.containsKey(oppId) ? oppUpdates.get(oppId) : new Opportunity(Id = oppId);
                opp.put(oppFieldName, 'NO FILE');
                oppUpdates.put(oppId, opp);
            
        }

        System.debug('### Opportunities to be updated: ' + oppUpdates);

        
            try {
                update oppUpdates.values();
                System.debug('### Successfully updated Opportunities.');
            } catch (Exception e) {
                System.debug('### Error updating Opportunities: ' + e.getMessage());
            }
       
    }
}
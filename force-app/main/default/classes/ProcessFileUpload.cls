public without sharing class ProcessFileUpload implements Queueable {
    private Set<Id> contentDocumentIds;

    // Constructor to accept ContentDocument IDs
    public ProcessFileUpload(Set<Id> contentDocumentIds) {
        this.contentDocumentIds = contentDocumentIds;
    }

    // Execute method for Queueable processing
    public void execute(QueueableContext context) {
        System.debug('### Executing ProcessFileUpload');

        if (contentDocumentIds == null || contentDocumentIds.isEmpty()) {
            System.debug('### No ContentDocumentIds found. Exiting.');
            return;
        }

        // Step 1: Get related Opportunity Ids from ContentDocumentLink
        Map<Id, Id> contentDocToOppMap = new Map<Id, Id>();
        for (ContentDocumentLink cdl : [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :contentDocumentIds
        ]) {
            if (String.valueOf(cdl.LinkedEntityId).startsWith('006')) { // Opportunity IDs start with '006'
                contentDocToOppMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
            }
        }

        System.debug('### ContentDocument to Opportunity Map: ' + contentDocToOppMap);

        if (contentDocToOppMap.isEmpty()) {
            System.debug('### No Opportunities found. Exiting.');
            return;
        }

        // Step 2: Fetch ContentVersion details
        List<ContentVersion> contentVersions = [
            SELECT ContentDocumentId, Title, Document_Status__c
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
            AND IsLatest = true
        ];

        // Step 3: Prepare Opportunity updates
        Map<Id, Opportunity> oppUpdates = new Map<Id, Opportunity>();
        Map<String, String> titleToFieldMap = new Map<String, String>{
            
            // Aprovals
            'CMS Approval Letter' => 'CMS_Approval_Letter__c',
            'State Approval Letter' => 'State_Approval_Letter__c',
                
                // Required  
                
                'Medical Supervision' => 'Medical_Supervision_Status__c',
                'Parking Acknowledgement (PA)' => 'Parking_Acknowledgement_PA__c',
                'ABIM Screenshot' => 'ABIM_Screenshot__c',
                'CMS 855b form' => 'CMS_855b_form__c',
                'ACLS' => 'ACLS__c',
                'Medical License' => 'Medical_License__c',
                'Board Certifications' =>  'Board_Certifications__c',
                'Certification Board of Nuclear Cardiology' => 'Certification_Board_of_Nuclear_Cardiolog__c',
                'Current Radioactive Materials License' => 'Current_Radioactive_Materials_License__c' ,
                'Vetting Report Completed and Approval to Interpret' => 'Vetting_Report_Completed_and_Approval_to__c',
                'Parking Drawing' => 'Parking_Drawing__c',
                'Parking Verification Form' => 'Parking_Verification_Form__c' ,
                'Due diligence' => 'Due_diligence__c',
                'W9' => 'W9__c' ,
                'Direct Deposit Form (ACH)' => 'Direct_Deposit_Form_ACH__c',
                
                // Optional
                
                'CRM License' =>  'CRM_License__c',
                'Physician Availability' => 'Physician_Availability__c',
                'Physician Cv' => 'Physician_Cv__c' ,
                'SPECT EHR Export' => 'SPECT_EHR_Export__c' ,
                
                // Parking Agreement
               
                'Parking Agreement' => 'Parking_Agreement_status__c' ,
                'W92 optional'  =>  'W92_optional__c' ,
                'ACH optional' => 'ACH_optional__c'
                
               
                
                
        };

        for (ContentVersion cv : contentVersions) {
            String normalizedTitle = cv.Title.replaceAll('\\.[^.]+$', ''); // Removes file extension

            for (String key : titleToFieldMap.keySet()) {
                if (normalizedTitle.toLowerCase().startsWith(key.toLowerCase())) {
                    Id oppId = contentDocToOppMap.get(cv.ContentDocumentId);
                    if (oppId != null) {
                        Opportunity opp = oppUpdates.containsKey(oppId) ? oppUpdates.get(oppId) : new Opportunity(Id = oppId);

                        String oppFieldName = titleToFieldMap.get(key);
                        opp.put(oppFieldName, cv.Document_Status__c);
                        oppUpdates.put(oppId, opp);

                        break;  // Only update the first matching field
                    }
                }
            }

            // if (titleToFieldMap.containsKey(normalizedTitle)) {
            //     Id oppId = contentDocToOppMap.get(cv.ContentDocumentId);
            //     if (oppId != null) {
            //         Opportunity opp = oppUpdates.containsKey(oppId) ? oppUpdates.get(oppId) : new Opportunity(Id = oppId);
            //         String oppFieldName = titleToFieldMap.get(normalizedTitle);
                    
            //         opp.put(oppFieldName, cv.Document_Status__c);
            //         oppUpdates.put(oppId, opp);
            //     }
            // }
        }

        System.debug('### Opportunity Updates: ' + oppUpdates);

        if (!oppUpdates.isEmpty()) {
            try {
                update oppUpdates.values();
            } catch (Exception e) {
                System.debug('### Error updating Opportunities: ' + e.getMessage());
            }
        } else {
            System.debug('### No Opportunities to Update.');
        }
    }
}
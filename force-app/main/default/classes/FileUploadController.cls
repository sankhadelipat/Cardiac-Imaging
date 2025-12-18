public without sharing class FileUploadController {
    
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> fetchDocuments(Id opportunityId) {
        List<ContentDocumentLink> documentLinks = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :opportunityId
        ];
        
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink link : documentLinks) {
            contentDocumentIds.add(link.ContentDocumentId);
        }
        
        if (contentDocumentIds.isEmpty()) {
            return new List<ContentVersion>();
        }
        
        return [
            SELECT Id, Title, Document_Status__c, ContentDocumentId 
            FROM ContentVersion 
            WHERE ContentDocumentId IN :contentDocumentIds 
            AND IsLatest = true AND IsDeleted = false
            ORDER BY CreatedDate DESC
        ];
    }
    
    @AuraEnabled
    public static Id uploadFile(String opportunityId, String fileName, String base64Data) {
        Id operationsProfileId = [SELECT Id FROM Profile WHERE Name = 'Contract Review Team' LIMIT 1].Id;
        
        List<User> opsUsers = [
            SELECT Id 
            FROM User 
            WHERE ProfileId = :operationsProfileId AND IsActive = true
        ];
        system.debug('opsUsers---'+opsUsers);
        Blob fileBlob = EncodingUtil.base64Decode(base64Data);
        
        String fileExtension = fileName.contains('.')
            ? fileName.substring(fileName.lastIndexOf('.'))
            : '.pdf';
        
        String fullFileName = fileName.endsWith(fileExtension) ? fileName : fileName + fileExtension;
        
        List<String> titlePrefixes = new List<String>{
            'Medical Supervision',
            'Parking Acknowledgement (PA)',
            'Parking Drawing',
            'Parking Verification Form',
            'W9',
            'Direct Deposit Form (ACH)'
        };
        
        String matchedPrefix = null;
        for (String prefix : titlePrefixes) {
            if (fileName.toLowerCase().startsWith(prefix.toLowerCase())) {
                matchedPrefix = prefix;
                break;
            }
        }
        
        List<ContentDocumentLink> docLinks = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :opportunityId
        ];
        
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink link : docLinks) {
            contentDocumentIds.add(link.ContentDocumentId);
        }
        
        if (!contentDocumentIds.isEmpty() && matchedPrefix != null) {
            List<ContentVersion> existingVersions = [
                SELECT Id, ContentDocumentId, Title
                FROM ContentVersion
                WHERE ContentDocumentId IN :contentDocumentIds
            ];
            
            for (ContentVersion existing : existingVersions) {
                if (existing.Title != null &&
                existing.Title.toLowerCase().startsWith(matchedPrefix.toLowerCase())) {
                    
                    ContentVersion newVersion = new ContentVersion();
                    newVersion.ContentDocumentId = existing.ContentDocumentId;
                    newVersion.Title = fullFileName;
                    newVersion.PathOnClient = fullFileName;
                    newVersion.VersionData = fileBlob;
                    newVersion.Document_Status__c = 'PENDING';
                    insert newVersion;
                    system.debug('existing.ContentDocumentId---'+existing.ContentDocumentId);
                    system.debug('ContentDocumentId,--'+newVersion.ContentDocumentId);
                    shareWithContractReviewTeam(existing.ContentDocumentId, opsUsers);
                    shareWithContractReviewTeam(newVersion.ContentDocumentId, opsUsers);
                    return newVersion.Id;
                    
                }
            }
        }
        
        // If no existing match, create new file from scratch
        ContentVersion cv = new ContentVersion();
        cv.Title = fullFileName;
        cv.PathOnClient = fullFileName;
        cv.VersionData = fileBlob;
        cv.Document_Status__c = 'PENDING';
        insert cv;
        
        // Retrieve ContentDocumentId from the inserted ContentVersion
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        //  shareWithContractReviewTeam(cv.ContentDocumentId, opsUsers);
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = cv.ContentDocumentId;
        link.LinkedEntityId = opportunityId;
      //  link.ShareType = 'V';
      //  link.Visibility = 'AllUsers';
        insert link;
        
        
        return cv.Id;
    }
    
    @AuraEnabled
    public static void saveNewVersion(Id contentVersionId, String newTitle, Id opportunityId) {
        ContentVersion newCv = [SELECT Id, Title, PathOnClient, ContentDocumentId, VersionData FROM ContentVersion WHERE Id = :contentVersionId];
        
        // Preserve the file extension
        String oldFileName = newCv.PathOnClient;
        String fileExtension = oldFileName.substringAfterLast('.');
        String newFileName = newTitle.endsWith(fileExtension) ? newTitle : newTitle + '.' + fileExtension;
        
        // For single file types, check if a document with this prefix already exists
        List<ContentDocumentLink> existingLinks = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :opportunityId
        ];
        
        Set<Id> existingDocIds = new Set<Id>();
        for (ContentDocumentLink link : existingLinks) {
            existingDocIds.add(link.ContentDocumentId);
        }
        
        if (!existingDocIds.isEmpty()) {
            List<ContentVersion> existingVersions = [
                SELECT Id, ContentDocumentId, Title
                FROM ContentVersion
                WHERE ContentDocumentId IN :existingDocIds
                AND Title LIKE :newTitle + '%'
                AND IsLatest = true
            ];
            
            if (!existingVersions.isEmpty()) {
                // Create new version of existing document
                ContentVersion versionToUpdate = new ContentVersion();
                versionToUpdate.ContentDocumentId = existingVersions[0].ContentDocumentId;
                versionToUpdate.Title = newFileName;
                versionToUpdate.PathOnClient = newFileName;
                versionToUpdate.VersionData = newCv.VersionData;
                versionToUpdate.Document_Status__c = 'PENDING';
                insert versionToUpdate;
                
                // Delete the content document of the newly created version
                delete [SELECT Id FROM ContentDocument WHERE Id = :newCv.ContentDocumentId];
            } else {
                renameContentVersion(contentVersionId, newTitle);
            }
        }
    }
    
    @AuraEnabled
    public static void updateDocumentStatus(Id contentVersionId, String status) {
        Id operationsProfileId = [SELECT Id FROM Profile WHERE Name = 'Contract Review Team' LIMIT 1].Id;
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        
        List<User> opsUsers = [
            SELECT Id 
            FROM User 
            WHERE ProfileId = :operationsProfileId AND IsActive = true
        ];
        
        List<ContentVersion> cv = [
            SELECT Id, Document_Status__c, contentDocumentId
            FROM ContentVersion 
            WHERE Id = :contentVersionId 
            AND IsLatest = true AND IsDeleted = false 
            ORDER BY CreatedDate DESC
        ];
        
        if(cv.isEmpty()) {
            return;
        }
        
        cv[0].Document_Status__c = status;
        update cv;
        
        if(profileName != 'Contract Review Team') {
            shareWithContractReviewTeam(cv[0].contentDocumentId, opsUsers);
        }
    }
    
    @AuraEnabled
    public static Boolean getParkingAgreementStatus(Id opportunityId) {
        Opportunity opp = [
            SELECT Parking_Agreement_Required__c 
            FROM Opportunity 
            WHERE Id = :opportunityId 
            LIMIT 1
        ];
        return opp.Parking_Agreement_Required__c;
    }
    
    @AuraEnabled
    public static void renameContentVersion(Id contentVersionId, String newTitle) {
        ContentVersion cv = [SELECT Id, Title, PathOnClient FROM ContentVersion WHERE Id = :contentVersionId];
        
        // Preserve the file extension
        String oldFileName = cv.PathOnClient;
        String fileExtension = oldFileName.substringAfterLast('.');
        String newFileName = newTitle + '.' + fileExtension;
        
        cv.Title = newTitle;
        update cv;
    }
    
    // Helper method to give Collaborator access
    @testvisible
    private static void shareWithContractReviewTeam(Id contentDocId, List<User> opsUsers) {
        List<ContentDocumentLink> userLinks = new List<ContentDocumentLink>();
        for (User u : opsUsers) {
            userLinks.add(new ContentDocumentLink(
                ContentDocumentId = contentDocId,
            LinkedEntityId = u.Id,
            ShareType = 'C', // Collaborator
            Visibility = 'AllUsers'
                ));
        }
        if (!userLinks.isEmpty()) {
            insert userLinks;
            system.debug('userLinks-----'+userLinks);
        }
    }
}
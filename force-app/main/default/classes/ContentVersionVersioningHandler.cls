public class ContentVersionVersioningHandler {

    public static final List<String> VERSIONED_TITLE_PREFIXES = new List<String>{
        'Medical Supervision',
        'Parking Acknowledgement (PA)',
        'Parking Drawing',
        'Parking Verification Form',
        'W9',
        'Direct Deposit Form (ACH)'
    };

    public static void handleVersioning(List<ContentVersion> newVersions) {
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id, ContentVersion> cvIdToVersion = new Map<Id, ContentVersion>();

        for (ContentVersion cv : newVersions) {
            if (cv.FirstPublishLocationId != null && cv.Title != null) {
                opportunityIds.add(cv.FirstPublishLocationId);
                cvIdToVersion.put(cv.Id, cv);
            }
        }

        if (opportunityIds.isEmpty()) {
            System.debug('### No Opportunity IDs found.');
            return;
        }

        // Query existing documents linked to these Opportunities
        List<ContentDocumentLink> docLinks = [
            SELECT ContentDocumentId,
                   LinkedEntityId,
                   ContentDocument.LatestPublishedVersion.Title
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :opportunityIds
        ];

        Map<String, Id> keyToDocIdMap = new Map<String, Id>();

        for (ContentDocumentLink link : docLinks) {
            String title = link.ContentDocument.LatestPublishedVersion.Title;
            if (title == null) continue;

            for (String prefix : VERSIONED_TITLE_PREFIXES) {
                if (title.toLowerCase().startsWith(prefix.toLowerCase())) {
                    String key = link.LinkedEntityId + '::' + prefix.toLowerCase();
                    keyToDocIdMap.put(key, link.ContentDocumentId);
                    System.debug('### Found existing document for key: ' + key);
                }
            }
        }

        // Assign ContentDocumentId to new ContentVersions
       /* for (ContentVersion cv : newVersions) {
            if (cv.Title == null || cv.FirstPublishLocationId == null) continue;

            for (String prefix : VERSIONED_TITLE_PREFIXES) {
                if (cv.Title.toLowerCase().startsWith(prefix.toLowerCase())) {
                    String key = cv.FirstPublishLocationId + '::' + prefix.toLowerCase();
                    if (keyToDocIdMap.containsKey(key)) {
                        Id matchedDocId = keyToDocIdMap.get(key);
                        cv.ContentDocumentId = matchedDocId;
                        System.debug('### Setting ContentDocumentId for: ' + cv.Title + ' => ' + matchedDocId);
                        break; // Stop once one match is found
                    }
                }
            }
        }*/
    }
}
public class ContentVersionHandler {
    private static Boolean hasRun = false;

    public static void handleAfterInsert(List<ContentVersion> newVersions) {
        if (hasRun) {
            System.debug('### Skipping versioning logic to avoid recursion');
            return;
        }
        hasRun = true;

        List<String> predefinedTitles = new List<String>{
            'Medical Supervision',
            'Parking Acknowledgement (PA)',
            'Parking Drawing',
            'Parking Verification Form',
            'W9',
            'Direct Deposit Form (ACH)'
        };

        Map<String, ContentVersion> titleToVersionMap = new Map<String, ContentVersion>();

        for (ContentVersion cv : newVersions) {
            for (String baseTitle : predefinedTitles) {
                if (cv.Title != null && cv.Title.startsWith(baseTitle)) {
                    titleToVersionMap.put(cv.Title, cv);
                }
            }
        }

        if (!titleToVersionMap.isEmpty()) {
            List<ContentVersion> newVersionsToInsert = new List<ContentVersion>();

            for (ContentVersion cv : titleToVersionMap.values()) {
                if (cv.ContentDocumentId != null) {
                    ContentVersion newVersion = new ContentVersion();
                    newVersion.ContentDocumentId = cv.ContentDocumentId;
                    newVersion.Title = cv.Title;
                    newVersion.PathOnClient = cv.PathOnClient;
                    newVersion.VersionData = cv.VersionData;

                    newVersionsToInsert.add(newVersion);
                }
            }

            if (!newVersionsToInsert.isEmpty()) {
                insert newVersionsToInsert;
                System.debug('### New content versions inserted: ' + newVersionsToInsert.size());
            }
        }
    }
}
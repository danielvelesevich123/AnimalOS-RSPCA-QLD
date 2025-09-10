public class ContentDocumentLinkHandler {
    public static void updateContentDocumentVisibility(List<ContentDocumentLink> cdlList) {
        for (ContentDocumentLink cdl : cdlList) {
            cdl.Visibility = 'AllUsers';
        }
    }
}
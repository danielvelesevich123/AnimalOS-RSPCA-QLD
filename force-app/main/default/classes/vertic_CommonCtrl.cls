global virtual class vertic_CommonCtrl {

    public static vertic_Response process(String processor, String requestJSON) {

        Savepoint savepoint;

        try {
            vertic_AbstractProcessor processorVar = vertic_ProcessorFactory.getInstance(processor);
            vertic_Request requestVar = processorVar.getRequestInstance(requestJSON);

            if (processorVar instanceof vertic_Structs.IRollbackable) {
                savepoint = Database.setSavepoint();
            }

            return processorVar.process(requestVar);
        } catch (Exception ex) {
            if (savepoint != null) {
                Database.rollback(savepoint);
            } else {
                if (Limits.getDmlStatements() > 0) {
                }
            }
            throw ex;
        }
    }

    @AuraEnabled
    global static String execute(String processor, String requestJSON) {

        try {
            vertic_Response responseVar = vertic_CommonCtrl.process(processor, requestJSON);
            return JSON.serialize(responseVar);
        } catch (vertic_Structs.ValidationException ex) {
            return new vertic_Response(ex).getJSON();
        } catch (Exception ex) {
            return new vertic_Response(ex).getJSON();
        } finally {
        }
    }

    @RemoteAction
    global static String execute(String requestJSON) {
        try {
            Map<String, Object> request = (Map<String, Object>) JSON.deserializeUntyped(requestJSON);

            if (request.containsKey('processor') && request.containsKey('dto')) {
                return execute((String) request.get('processor'), JSON.serialize(request.get('dto')));
            }

            return new vertic_Response('Invalid request attributes.').getJSON();
        } catch (Exception ex) {
            return new vertic_Response(ex).getJSON();
        } finally {
        }
    }

}
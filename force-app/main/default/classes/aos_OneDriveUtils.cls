public class aos_OneDriveUtils {

    public static Map<String, String> getDrives() {
        Map<String, String> drives = new Map<String, String>();

        aos_Response response = new aos_HttpRequestProc().process(new aos_Request(new Map<String, Object>{
                'endpoint' => 'callout:OneDrive/sites/rspcaqld.sharepoint.com:/sites/AnimalOSSharePointIntegration:/drives',
                'method' => 'GET',
                'headers' => new Map<String, Object>{
                        'Content-Type' => 'application/json',
                        'Accept' => 'application/json'
                }
        }));

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped((String) response.dto.get('response'));

        if(responseMap != null && !responseMap.isEmpty() && responseMap.get('value') != null) {
            for (Object value : (List<Object>) responseMap.get('value')) {
                Map<String, Object> objectMap = (Map<String, Object>) value;
                drives.put((String) objectMap.get('name'), (String) objectMap.get('id'));
            }
        }

        return drives;
    }

    public static List<Object> getItems(String drive, String folderName) {
        Map<String, String> responseDrives = new Map<String, String>();

        aos_Response response = new aos_HttpRequestProc().process(new aos_Request(new Map<String, Object>{
                'endpoint' => 'callout:OneDrive/drives/' + drive + '/root:/' + folderName + ':/children?$expand=thumbnails',
                'method' => 'GET',
                'headers' => new Map<String, Object>{
                        'Content-Type' => 'application/json',
                        'Accept' => 'application/json'
                }
        }));

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped((String) response.dto.get('response'));

        if (responseMap.get('error') != null) {
            return null;
        } else {
            return (List<Object>) responseMap.get('value');
        }
    }

    public static String checkIsExistFolder(String drive, String folderName) {
        aos_Response response = new aos_HttpRequestProc().process(new aos_Request(new Map<String, Object>{
                'endpoint' => 'callout:OneDrive/drives/' + drive + '/root:/' + folderName,
                'method' => 'GET',
                'headers' => new Map<String, Object>{
                        'Content-Type' => 'application/json',
                        'Accept' => 'application/json'
                }
        }));

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped((String) response.dto.get('response'));

        if (responseMap.get('error') != null) {
            return null;
        } else {
            return (String) responseMap.get('id');
        }
    }

    public static String createFolder(String drive, String folderName) {
        aos_Response response = new aos_HttpRequestProc().process(new aos_Request(new Map<String, Object>{
                'endpoint' => 'callout:OneDrive/drives/' + drive + '/root/children/',
                'method' => 'POST',
                'headers' => new Map<String, Object>{
                        'Content-Type' => 'application/json',
                        'Accept' => 'application/json'
                },
                'body' => JSON.serialize(
                        new Map<String, Object>{
                                'name' => folderName,
                                'folder' => new Map<String, Object>{
                                },
                                'description' => 'testDescription',
                                '@microsoft.graph.conflictBehavior' => 'rename'
                        }
                )
        }));

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped((String) response.dto.get('response'));

        if (responseMap.get('id') == null) {
            throw new aos_Structs.ProcessException('Folder was not created');
        } else {
            return (String) responseMap.get('id');
        }
    }

    public static void moveFileToFolder(String drive, String itemId, String newFolderId, String fileName) {
        aos_Response response = new aos_HttpRequestProc().process(new aos_Request(new Map<String, Object>{
                'endpoint' => 'callout:OneDrive/drives/' + drive + '/items/' + itemId,
                'method' => 'PATCH',
                'headers' => new Map<String, Object>{
                        'Content-Type' => 'application/json',
                        'Accept' => 'application/json'
                },
                'body' => JSON.serialize(
                        new Map<String, Object>{
                                'parentReference' => new Map<String, Object>{
                                        'id' => newFolderId
                                },
                                'name' => fileName
                        }
                )
        }));
    }

    public static aos_Response copyFile(String oldDriveId, String itemId, String newDriveId, String newFolderId, String fileName) {

        List<String> nameParts = fileName.split('\\.');
        fileName = fileName.replace('.' + nameParts[nameParts.size() - 1], ' (Copy).' + nameParts[nameParts.size() - 1]);

        aos_Response response = new aos_HttpRequestProc().process(new aos_Request(new Map<String, Object>{
                'endpoint' => 'callout:OneDrive/drives/' + oldDriveId + '/items/' + itemId + '/copy',
                'method' => 'POST',
                'headers' => new Map<String, Object>{
                        'Content-Type' => 'application/json',
                        'Accept' => 'application/json'
                },
                'body' => JSON.serialize(
                        new Map<String, Object>{
                                'parentReference' => new Map<String, Object>{
                                        'driveId' => newDriveId,
                                        'id' => newFolderId
                                },
                                'name' => fileName
                        }
                )
        }));

        return response;
    }

    public static String getPublicLink(String drive, String itemId) {
        aos_Response response = new aos_HttpRequestProc().process(new aos_Request(new Map<String, Object>{
                'endpoint' => 'callout:OneDrive/drives/' + drive + '/items/' + itemId + '/preview',
                'method' => 'POST',
                'headers' => new Map<String, Object>{
                        'Content-Type' => 'application/json',
                        'Accept' => 'application/json'
                },
                'body' => JSON.serialize(
                        new Map<String, Object>{
//                    'type' => 'view',
//                    'scope' => 'anonymous'
                        }
                )
        }));
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped((String) response.dto.get('response'));
        return (String) responseMap.get('getUrl');
    }

    public static String getFileThumbnail(String drive, String itemId) {
        aos_Response response = new aos_HttpRequestProc().process(new aos_Request(new Map<String, Object>{
                'endpoint' => 'callout:OneDrive/drives/' + drive + '/items/' + itemId + '/thumbnails',
                'method' => 'GET',
                'headers' => new Map<String, Object>{
                        'Content-Type' => 'application/json',
                        'Accept' => 'application/json'
                }
        }));
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped((String) response.dto.get('response'));

        List<Object> value = (List<Object>) responseMap.get('value');
        if (value != null && !value.isEmpty()) {
            Map<String, Object> images = (Map<String, Object>) value[0];
            Map<String, Object> large = (Map<String, Object>) images.get('large');
            if (large != null) {
                return (String) large.get('url');
            }
        }

        return null;
    }


    public static String uploadSmallFile(String drive, String folderId, String fileName, String file, Boolean returnId) { // up to 4mb
        fileName = fileName.replace(' ', '%20');
        aos_Request request = new aos_Request(new Map<String, Object>{
                'endpoint' => 'callout:OneDrive/drives/' + drive + '/items/' + folderId + ':/' + fileName + ':/content',
                'method' => 'PUT',
                'headers' => new Map<String, Object>{
                        'Content-Type' => 'text/plain',
                        'Accept' => 'application/json'
                },
                'base64Encoded' => file
        });
        aos_Response response = new aos_HttpRequestProc().process(request);

        if (returnId) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped((String) response.dto.get('response'));
            return (String) responseMap.get('id');
        } else {
            return String.valueOf(response.dto.get('response'));
        }
    }

    public static String uploadSmallFile(String drive, String folderId, String fileName, String file) {
        return uploadSmallFile(drive, folderId, fileName, file, true);
    }

    public static String createUploadSession(String drive, String folderName, String fileName) {
        fileName = fileName.replace(' ', '_');
        aos_Response response = new aos_HttpRequestProc().process(new aos_Request(new Map<String, Object>{
                'endpoint' => 'callout:OneDrive/drives/' + drive + '/root:/' + folderName + '/' + fileName + ':/createUploadSession',
                'method' => 'POST',
                'headers' => new Map<String, Object>{
                        'Content-Type' => 'application/json',
                        'Accept' => 'application/json'
                },
                'body' => JSON.serialize(new Map<String, Object>{
                        'item' => new Map<String, Object>{
                                '@microsoft.graph.conflictBehavior' => 'replace'
                        }
                })
        }));

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped((String) response.dto.get('response'));
        return (String) responseMap.get('uploadUrl');
    }

    public static String uploadLargeFile(String drive, String folderId, String fileName, Blob file, String sessionUrl, Double fileSize, Double chunkSize) {
        List<Map<String, Object>> chunks = aos_OneDriveUtils.getChunks(file, fileSize, chunkSize);
        aos_Response response;
        for (Map<String, Object> chunk : chunks) {
            aos_Request request = new aos_Request(new Map<String, Object>{
                    'endpoint' => sessionUrl,
                    'method' => 'PUT',
                    'headers' => new Map<String, Object>{
                            'Content-Type' => 'application/octet-stream',
                            'Accept' => 'application/json',
                            'Content-Length' => ((Integer) chunk.get('end') - (Integer) chunk.get('start')),
                            'Content-Range' => 'bytes ' + (Integer) chunk.get('start') + '-' + (Integer) chunk.get('end') + '/' + fileSize
                    },
                    'base64Encoded' => chunk.get('content')
            });
            response = new aos_HttpRequestProc().process(request);
        }

        System.debug(response);

        return (String) response.get('Id');
    }

    private static List<Map<String, Object>> getChunks(Blob file, Double fileSize, Double chunkSize) {
        List<Map<String, Object>> chunks = new List<Map<String, Object>>();

        System.debug('sizes ' + fileSize + ' ' + chunkSize);
        Decimal countOfChunksDecimal = fileSize / chunkSize;
        Long countOfChunks = countOfChunksDecimal.round(RoundingMode.UP);

//        System.debug(countOfChunks);
//        System.debug(EncodingUtil.base64Encode(file).length());


        for (Integer i = 0; i < countOfChunks; i++) {
            Integer chunkStart = (i * chunkSize).intValue();
            Integer chunkEnd = (Integer) Math.min(chunkStart + chunkSize, fileSize);
            System.debug(chunkStart + ' ' + chunkEnd);

            chunks.add(new Map<String, Object>{
                    'start' => chunkStart,
                    'end' => chunkEnd,
                    'content' => EncodingUtil.base64Encode(file).substring(chunkStart, chunkEnd)
            });
//            System.debug(EncodingUtil.base64Encode(file).substring(chunkStart, chunkEnd));
        }
        return chunks;
    }

    public static void copyFolder(String drive, String folderId, String newFolderName) {
        aos_Response response = new aos_HttpRequestProc().process(new aos_Request(new Map<String, Object>{
                'endpoint' => 'callout:OneDrive/drives/' + drive + '/items/' + folderId + '/copy',
                'method' => 'POST',
                'headers' => new Map<String, Object>{
                        'Content-Type' => 'application/json',
                        'Accept' => 'application/json'
                },
                'body' => JSON.serialize(
                        new Map<String, Object>{
                                'name' => newFolderName
                        }
                )
        }));
    }

}
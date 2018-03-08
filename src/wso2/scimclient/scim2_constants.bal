package src.wso2.scimclient;

public const string SCIM_AUTHORIZATION = "Authorization";
public const string SCIM_CONTENT_TYPE = "Content-Type";
public const string SCIM_JSON = "application/json";
public const string SCIM_USER_END_POINT = "/Users";
public const string SCIM_GROUP_END_POINT = "/Groups";
public const string SCIM_PAYLOAD_DETAIL = "detail";
public const string SCIM_FILTER_GROUP_BY_NAME = "filter=displayName+Eq+";
public const string SCIM_FAIL_MESSAGE = "failed";
public const string SCIM_CREATE_MESSAGE = "created";
public const string SCIM_DELETE_MESSEGE = "deleted";
public const string SCIM_FILTER_USER_BY_USERNAME = "filter=userName+Eq+";
public const string SCIM_API_ERROR_MESSAGE = "urn:ietf:params:scim:api:messages:2.0:Error";
public const string SCIM_TOTAL_RESULTS = "totalResults";
public const string SCIM_CREATE_USER_BODY = "{" +
                                          "                                              \"schemas\": [\"urn:ietf:params:scim:api:messages:2.0:PatchOp\"]," +
                                          "                                              \"Operations\": [{" +
                                          "                                                                 \"op\": \"add\"," +
                                          "                                                                 \"value\": {" +
                                          "                                                                              \"members\": [{" +
                                          "                                                                                              \"display\": \"\"," +
                                          "                                                                                              \"$ref\": \"\"," +
                                          "                                                                                              \"value\": \"\"" +
                                          "                                                                                          }]" +
                                          "                                                                          }" +
                                          "                                                             }]" +
                                          "                                          }";
public const string SCIM_REMOVE_USER_BODY = "{" +
                                            "                        \"schemas\": [\"urn:ietf:params:scim:api:messages:2.0:PatchOp\"]," +
                                            "                        \"Operations\": [{" +
                                            "                                           \"op\": \"remove\"," +
                                            "                                           \"path\": \"\"" +
                                            "                                       }]" +
                                            "                    }";

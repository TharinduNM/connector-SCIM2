package src.wso2.scimclient;

//These are the constants that are used
//Constants are arranged in alphabetical order

//String constants
public const string SCIM_AUTHORIZATION = "Authorization";
public const string SCIM_CONTENT_TYPE = "Content-Type";
public const string SCIM_GROUP_PATCH_ADD_BODY = "{" +
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

public const string SCIM_DELETE_MESSEGE = "deleted";
public const string SCIM_FILTER_GROUP_BY_NAME = "filter=displayName+Eq+";
public const string SCIM_FILTER_USER_BY_USERNAME = "filter=userName+Eq+";
public const string SCIM_GROUP_END_POINT = "/Groups";
public const string SCIM_JSON = "application/json";
public const string SCIM_GROUP_PATCH_REMOVE_BODY = "{" +
                                            "                        \"schemas\": [\"urn:ietf:params:scim:api:messages:2.0:PatchOp\"]," +
                                            "                        \"Operations\": [{" +
                                            "                                           \"op\": \"remove\"," +
                                            "                                           \"path\": \"\"" +
                                            "                                       }]" +
                                            "                    }";

public const string SCIM_TOTAL_RESULTS = "totalResults";
public const string SCIM_USER_END_POINT = "/Users";


public const string SCIM_PATCH_ADD_BODY = "{" +
                                          "                                              \"schemas\": [\"urn:ietf:params:scim:api:messages:2.0:PatchOp\"]," +
                                          "                                              \"Operations\": [{" +
                                          "                                                                 \"op\": \"add\"," +
                                          "                                                                 \"value\": {}" +
                                          "                                                             }]" +
                                          "                                          }";

//Integer constants
public const int SCIM_UNAUTHORIZED = 401;
public const int SCIM_CREATED = 201;
public const int SCIM_FOUND = 200;
public const int SCIM_NOT_FOUND = 404;
public const int SCIM_DELETED = 204;
public const int SCIM_BAD_REQUEST = 400;




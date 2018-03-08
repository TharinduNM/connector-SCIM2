package src.wso2.scimclient;

import ballerina.net.http;

http:HttpClient scimHTTPClient =  create http:HttpClient(getURL(),getConnectionConfigs());

public struct Group{
    string displayName;
    string id;
    Member[] members;
    Meta meta;
}

public struct Member{
    string display;
    string value;
}

public struct User {
    string userName;
    string id;
    string password;
    Group[] groups;
    Name name;
    json details;
}

public struct Name{
    string formatted;
    string givenName;
    string familyName;
    string middleName;
    string honorificPrefix;
    string honorificSuffix;
}

public struct Meta{
    string created;
    string location;
    string lastModified;
}

@Description {value: "Add the user to the group specified by its name"}
@Param {value: "groupName: Name of the group"}
@Param {value: "Group: Group struct"}
@Param {value: "error: Error"}
public function <User user> addToGroup (string groupName) (Group, error){
    endpoint <http:HttpClient> scimClient{
        scimHTTPClient;
    }
    error connectorError;

    if(user == null || groupName == ""){
        connectorError = {message:"User ang group name should be valid"};
        return null,connectorError;
    }

    http:OutRequest requestGroup = {};
    http:InResponse responseGroup = {};
    http:OutRequest request = {};
    http:InResponse response = {};
    http:HttpConnectorError httpError;
    error groupError;
    Group group = {};
    error Error;

    requestGroup.addHeader(SCIM_AUTHORIZATION,"Basic "+getAuthentication());
    responseGroup, httpError = scimClient.get(SCIM_GROUP_END_POINT + "?attributes=displayName,id,members&" + SCIM_FILTER_GROUP_BY_NAME + groupName, requestGroup);
    group, groupError = resolveGroup(groupName, responseGroup, httpError);
    if (group ==null){
        return null,groupError;
    }

    string value = user.id;
    string ref = getURL()+SCIM_USER_END_POINT+"/" + value;
    string url = SCIM_GROUP_END_POINT+"/"+group.id;
    json body;
    body, _ = <json>SCIM_CREATE_USER_BODY;
    body.Operations[0].value.members[0].display = user.userName;
    body.Operations[0].value.members[0]["$ref"] = ref;
    body.Operations[0].value.members[0].value = value;

    request.addHeader(SCIM_AUTHORIZATION,"Basic "+getAuthentication());
    request.addHeader(SCIM_CONTENT_TYPE, SCIM_JSON);
    request.setJsonPayload(body);

    response, httpError = scimClient.patch(url,request);
    var stringPayload = response.getBinaryPayload().toString("UTF-8");
    var payload, e = <json>stringPayload;
    group, Error = <Group>payload;
    return group, Error;

}

@Description {value: "Remove the user from the group specified by its name"}
@Param {value: "groupName: Name of the group"}
@Param {value: "Group: Group struct"}
@Param {value: "error: Error"}
public function <User user> removeFromGroup(string groupName) (Group, error){
    endpoint <http:HttpClient> scimClient{
        scimHTTPClient;
    }
    error connectorError;

    if(user == null || groupName == ""){
        connectorError = {message:"User ang group name should be valid"};
        return null,connectorError;
    }

    http:OutRequest groupRequest = {};
    http:InResponse groupResponse = {};
    http:OutRequest request = {};
    http:InResponse response = {};
    error groupError;
    Group group = {};
    error Error;
    http:HttpConnectorError httpError;

    groupRequest.addHeader(SCIM_AUTHORIZATION,"Basic "+getAuthentication());
    groupResponse, httpError = scimClient.get(SCIM_GROUP_END_POINT+"?attributes=displayName,id,members&"+SCIM_FILTER_GROUP_BY_NAME+groupName, groupRequest);
    group, groupError = resolveGroup(groupName, groupResponse, httpError);
    if (group ==null){
        return null,groupError;
    }

    json body;
    body, _= <json>SCIM_REMOVE_USER_BODY;
    string path = "members[display eq "+user.userName+"]";
    body.Operations[0].path = path;
    string url = SCIM_GROUP_END_POINT+"/"+group.id;

    request.addHeader(SCIM_AUTHORIZATION,"Basic "+getAuthentication());
    request.addHeader(SCIM_CONTENT_TYPE, SCIM_JSON);
    request.setJsonPayload(body);

    response, httpError = scimClient.patch(url,request);

    if(httpError != null){
        Error = {message:httpError.message,cause:httpError.cause};
        return null,Error;
    }
    try{
        var stringPayload = response.getBinaryPayload().toString("UTF-8");
        var payload, e = <json>stringPayload;
        if(payload.schemas.toString().equalsIgnoreCase(SCIM_API_ERROR_MESSAGE)){
            var det = payload[SCIM_PAYLOAD_DETAIL];
            Error = {message:det.toString(),cause:null};
            return null,Error;
        }
        string[] groupKeyList = payload.getKeys();
        if(lengthof groupKeyList <5){
            var tempGroup = <Group,convertGroupInRemoveResponse()>payload;
            return tempGroup,Error;
        }else{
            group, Error = <Group>payload;
            return group, Error;
        }
    }catch (error e){
        Error = {message:e.message,cause:e.cause};
        return null, Error;
    }

    return group,Error;
}
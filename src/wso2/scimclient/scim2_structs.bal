package src.wso2.scimclient;

import ballerina.net.http;

//All the Struct objects that are used

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
    string externalId;
    string displayName;
    string nickName;
    string profileUrl;
    string userType;
    string title;
    string preferredLanguage;
    string timezone;
    string active;
    string locale;
    json[] schemas;
    Name name;
    Meta meta;
    X509Certificate[] x509Certificates;
    Group[] groups;
    Address [] addresses;
    Email[] emails;
    PhonePhotoIms [] phoneNumbers;
    PhonePhotoIms [] ims;
    PhonePhotoIms [] photos;
    EnterpriseExtension |urn:scim:schemas:extension:enterprise:1.0|;
}

public struct Address{
    string streetAddress;
    string locality;
    string postalCode;
    string country;
    string formatted;
    string primary;
    string region;
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

public struct PhonePhotoIms{
    string value;
    string |type|;
}

public struct Email{
    string value;
    string |type|;
    string primary;
}

public struct X509Certificate{
    string value;
}

public struct EnterpriseExtension {
    string employeeNumber;
    string costCenter;
    string organization;
    string division;
    string department;
    Manager manager;
}

public struct Manager{
    string managerId;
    string displayName;
}

@Description {value: "Add the user to the group specified by its name"}
@Param {value: "groupName: Name of the group"}
@Param {value: "Group: Group struct"}
@Param {value: "error: Error"}
public function <User user> addToGroup (string groupName) (Group, error){
    endpoint <http:HttpClient> scimClient{
        scimHTTPClient;
    }
    error Error;
    error connectorError;
    http:OutRequest request = {};
    http:InResponse response = {};
    http:HttpConnectorError httpError;

    if(user == null || groupName == ""){
        connectorError = {message:"User and group name should be valid"};
        return null,connectorError;
    }

    http:OutRequest requestGroup = {};
    http:InResponse responseGroup = {};
    error groupError;
    Group group = {};
    requestGroup.addHeader(SCIM_AUTHORIZATION,"Basic "+getAuthentication());
    responseGroup, httpError = scimClient.get(SCIM_GROUP_END_POINT + "?" + SCIM_FILTER_GROUP_BY_NAME + groupName, requestGroup);
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
    if (httpError != null){
        Error = {message:httpError.message,cause:httpError.cause};
        return null, Error;
    }
    if (response.statusCode==SCIM_FOUND){
        try{
            var receivedBinaryPayload, _ = response.getBinaryPayload();
            string receivedPayload = receivedBinaryPayload.toString("UTF-8");
            var payload, _ = <json>receivedPayload;
            group = <Group,convertJsonToGroup()>payload;
            return group, Error;
        }catch (error e) {
            Error = {message:e.message, cause:e.cause};
            return null, Error;
        }
    }

    Error = {message:response.reasonPhrase};
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
    groupResponse, httpError = scimClient.get(SCIM_GROUP_END_POINT+"?"+SCIM_FILTER_GROUP_BY_NAME+groupName, groupRequest);
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
    if (httpError != null){
        Error = {message:httpError.message,cause:httpError.cause};
        return null, Error;
    }
    if (response.statusCode==SCIM_FOUND){
        try{
            var receivedBinaryPayload, _ = response.getBinaryPayload();
            string receivedPayload = receivedBinaryPayload.toString("UTF-8");
            var payload, _ = <json>receivedPayload;
            group = <Group,convertJsonToGroup()>payload;
            return group, Error;
        }catch (error e) {
            Error = {message:e.message, cause:e.cause};
            return null, Error;
        }
    }

    Error = {message:response.reasonPhrase};
    return group, Error;

}
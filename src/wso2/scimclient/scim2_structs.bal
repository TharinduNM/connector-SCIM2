//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

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
    EnterpriseUserExtension EnterpriseUser;
}

public struct Address{
    string streetAddress;
    string locality;
    string postalCode;
    string country;
    string formatted;
    string primary;
    string region;
    string |type|;
}

public struct Name{
    string formatted;
    string givenName;
    string familyName;
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

public struct EnterpriseUserExtension {
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
    responseGroup, httpError = scimClient.get(SCIM_GROUP_END_POINT + "?" + SCIM_FILTER_GROUP_BY_NAME +
                                              groupName, requestGroup);
    group, groupError = resolveGroup(groupName, responseGroup, httpError);
    if (group ==null){
        return null,groupError;
    }

    string value = user.id;
    string ref = getURL()+SCIM_USER_END_POINT+"/" + value;
    string url = SCIM_GROUP_END_POINT+"/"+group.id;
    json body;
    body, _ = <json>SCIM_GROUP_PATCH_ADD_BODY;
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
        connectorError = {message:"User and nick name should be valid"};
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
    groupResponse, httpError = scimClient.get(SCIM_GROUP_END_POINT+"?"+SCIM_FILTER_GROUP_BY_NAME+groupName,
                                              groupRequest);
    group, groupError = resolveGroup(groupName, groupResponse, httpError);
    if (group ==null){
        return null,groupError;
    }

    json body;
    body, _= <json>SCIM_GROUP_PATCH_REMOVE_BODY;
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


@Description {value: "Update the nick name of the user"}
@Param {value: "nickName: New nick name"}
@Param {value: "error: Error"}
public function <User user> updateNickname(string nickName) (error){
    endpoint <http:HttpClient> scimClient{
        scimHTTPClient;
    }
    error Error;

    if(user == null || nickName == ""){
        Error = {message:"User and group name should be valid"};
        return Error;
    }

    http:OutRequest request = {};
    http:InResponse response = {};
    http:HttpConnectorError httpError;

    json body;
    body, _ = <json>SCIM_PATCH_ADD_BODY;
    body.Operations[0].value = {"nickName":nickName};

    request = createRequest(body);

    string url = SCIM_USER_END_POINT+"/"+user.id;
    response, httpError = scimClient.patch(url,request);

    if(response.statusCode==SCIM_FOUND){
        Error = {message:"Nick name updated"};
        return Error;
    }

    Error = {message:response.reasonPhrase};
    return Error;
}

@Description {value: "Update the title of the user"}
@Param {value: "title: New title"}
@Param {value: "error: Error"}
public function <User user> updateTitle(string title) (error){
    endpoint <http:HttpClient> scimClient{
        scimHTTPClient;
    }
    error Error;

    if(user == null || title == ""){
        Error = {message:"User and title name should be valid"};
        return Error;
    }

    http:OutRequest request = {};
    http:InResponse response = {};
    http:HttpConnectorError httpError;

    json body;
    body, _ = <json>SCIM_PATCH_ADD_BODY;
    body.Operations[0].value = {"title":title};

    string url = SCIM_USER_END_POINT+"/"+user.id;
    request = createRequest(body);
    response, httpError = scimClient.patch(url,request);
    if(response.statusCode==SCIM_FOUND){
        Error = {message:"title updated"};
        return Error;
    }

    Error = {message:response.reasonPhrase};
    return Error;
}

@Description {value: "Update the password of the user"}
@Param {value: "password: New password"}
@Param {value: "error: Error"}
public function <User user> updatePassword(string password) (error){
    endpoint <http:HttpClient> scimClient{
        scimHTTPClient;
    }
    error Error;

    if(user == null || password == ""){
        Error = {message:"User and password should be valid"};
        return Error;
    }

    http:OutRequest request = {};
    http:InResponse response = {};
    http:HttpConnectorError httpError;

    json body;
    body, _ = <json>SCIM_PATCH_ADD_BODY;
    body.Operations[0].value = {"password":password};

    request = createRequest(body);

    string url = SCIM_USER_END_POINT+"/"+user.id;
    response, httpError = scimClient.patch(url,request);

    if(response.statusCode==SCIM_FOUND){
        Error = {message:"password updated"};
        return Error;
    }

    Error = {message:response.reasonPhrase};
    return Error;
}

@Description {value: "Update the profile URL of the user"}
@Param {value: "profileUrl: New profile URL"}
@Param {value: "error: Error"}
public function <User user> updateProfileUrl(string profileUrl) (error){
    endpoint <http:HttpClient> scimClient{
        scimHTTPClient;
    }
    error Error;

    if(user == null || profileUrl == ""){
        Error = {message:"User and profile url should be valid"};
        return Error;
    }

    http:OutRequest request = {};
    http:InResponse response = {};
    http:HttpConnectorError httpError;

    json body;
    body, _ = <json>SCIM_PATCH_ADD_BODY;
    body.Operations[0].value = {"profileUrl":profileUrl};

    request = createRequest(body);

    string url = SCIM_USER_END_POINT+"/"+user.id;
    response, httpError = scimClient.patch(url,request);

    if(response.statusCode==SCIM_FOUND){
        Error = {message:"Profile URL updated"};
        return Error;
    }

    Error = {message:response.reasonPhrase};
    return Error;
}

@Description {value: "Update the locale of the user"}
@Param {value: "locale: New locale"}
@Param {value: "error: Error"}
public function <User user> updateLocale(string locale) (error){
    endpoint <http:HttpClient> scimClient{
        scimHTTPClient;
    }
    error Error;

    if(user == null || locale == ""){
        Error = {message:"User and profile url should be valid"};
        return Error;
    }

    http:OutRequest request = {};
    http:InResponse response = {};
    http:HttpConnectorError httpError;

    json body;
    body, _ = <json>SCIM_PATCH_ADD_BODY;
    body.Operations[0].value = {"locale":locale};

    request = createRequest(body);

    string url = SCIM_USER_END_POINT+"/"+user.id;
    response, httpError = scimClient.patch(url,request);

    if(response.statusCode==SCIM_FOUND){
        Error = {message:"Locale updated"};
        return Error;
    }

    Error = {message:response.reasonPhrase};
    return Error;
}

@Description {value: "Update the time zone of the user"}
@Param {value: "timezone: New time zone"}
@Param {value: "error: Error"}
public function <User user> updateTimezone(string timezone) (error){
    endpoint <http:HttpClient> scimClient{
        scimHTTPClient;
    }
    error Error;

    if(user == null || timezone == ""){
        Error = {message:"User and time zone should be valid"};
        return Error;
    }

    http:OutRequest request = {};
    http:InResponse response = {};
    http:HttpConnectorError httpError;

    json body;
    body, _ = <json>SCIM_PATCH_ADD_BODY;
    body.Operations[0].value = {"timezone":timezone};

    request = createRequest(body);

    string url = SCIM_USER_END_POINT+"/"+user.id;
    response, httpError = scimClient.patch(url,request);

    if(response.statusCode==SCIM_FOUND){
        Error = {message:"timezone updated"};
        return Error;
    }

    Error = {message:response.reasonPhrase};
    return Error;
}

@Description {value: "Update the active of the user"}
@Param {value: "active: New active"}
@Param {value: "error: Error"}
public function <User user> updateActive(boolean active) (error){
    endpoint <http:HttpClient> scimClient{
        scimHTTPClient;
    }
    error Error;

    if(user == null ){
        Error = {message:"User should be valid"};
        return Error;
    }

    string isActive;
    if(active){
        isActive = "true";
    }else {
        isActive = "false";
    }

    http:OutRequest request = {};
    http:InResponse response = {};
    http:HttpConnectorError httpError;

    json body;
    body, _ = <json>SCIM_PATCH_ADD_BODY;
    body.Operations[0].value = {"active":active};

    request = createRequest(body);

    string url = SCIM_USER_END_POINT+"/"+user.id;
    response, httpError = scimClient.patch(url,request);

    if(response.statusCode==SCIM_FOUND){
        Error = {message:"active updated"};
        return Error;
    }

    Error = {message:response.reasonPhrase};
    return Error;
}

@Description {value: "Update the preferred language of the user"}
@Param {value: "preferredLanguage: New preferred language"}
@Param {value: "error: Error"}
public function <User user> updatePreferredLanguage(string preferredLanguage) (error){
    endpoint <http:HttpClient> scimClient{
        scimHTTPClient;
    }
    error Error;

    if(user == null || preferredLanguage == ""){
        Error = {message:"User and profile url should be valid"};
        return Error;
    }

    http:OutRequest request = {};
    http:InResponse response = {};
    http:HttpConnectorError httpError;

    json body;
    body, _ = <json>SCIM_PATCH_ADD_BODY;
    body.Operations[0].value = {"preferredLanguage":preferredLanguage};

    request = createRequest(body);

    string url = SCIM_USER_END_POINT+"/"+user.id;
    response, httpError = scimClient.patch(url,request);

    if(response.statusCode==SCIM_FOUND){
        Error = {message:"Preferred language updated"};
        return Error;
    }

    Error = {message:response.reasonPhrase};
    return Error;
}


//The functionality of the following functions are questionable. gives weird results time to time
//All these attributes are mapped to enterprise user claims?????????
//if these fields are present in the user already, this crashes


//This works fine when replacing emails of users created without initial emails.
//crashes and remove all existing emails when try to update email address of user created with emails
@Description {value: "Update the email addresses of the user"}
@Param {value: "emails: List of new email address structs"}
@Param {value: "error: Error"}
public function <User user> updateEmails(Email[] emails) (error){
    endpoint <http:HttpClient> scimClient{
        scimHTTPClient;
    }
    error Error;

    if(user == null){
        Error = {message:"User should be valid"};
        return Error;
    }

    http:OutRequest request = {};
    http:InResponse response = {};
    http:HttpConnectorError httpError;

    json[] emailList = [];
    json email;
    int i;
    foreach emailAddress in emails{
        if (!emailAddress.|type|.equalsIgnoreCase("work") && !emailAddress.|type|.equalsIgnoreCase("home")){
            Error = {message: "Email type should be defiend as either home or work"};
            return Error;
        }
        email = <json,convertEmailToJson()>emailAddress;
        emailList[i] = email;
        i = i+1;
    }
    json body;
    body, _ = <json>SCIM_PATCH_ADD_BODY;
    body.Operations[0].value = {"emails":emailList};

    request = createRequest(body);

    string url = SCIM_USER_END_POINT+"/"+user.id;
    response, httpError = scimClient.patch(url,request);

    if(response.statusCode==SCIM_FOUND){
        Error = {message:"Emails updated"};
        return Error;
    }

    Error = {message:response.reasonPhrase};
    return Error;
}
//========================================================================================

//all these 3 functions update the specified field only if the field is non existing and only if some
//                                                                                        other fields are non existing
//if the specified attribute or some other attributes are present, then this will remove all those fields
@Description {value: "Update the user type of the user"}
@Param {value: "userType: New user type"}
@Param {value: "error: Error"}
public function <User user> updateUserType(string userType) (error){
    endpoint <http:HttpClient> scimClient{
        scimHTTPClient;
    }
    error Error;

    if(user == null || userType == ""){
        Error = {message:"User and user type should be valid"};
        return Error;
    }

    http:OutRequest request = {};
    http:InResponse response = {};
    http:HttpConnectorError httpError;

    json body;
    body, _ = <json>SCIM_PATCH_ADD_BODY;
    body.Operations[0].value = {"userType":userType};

    request = createRequest(body);

    string url = SCIM_USER_END_POINT+"/"+user.id;
    response, httpError = scimClient.patch(url,request);

    if(response.statusCode==SCIM_FOUND){
        Error = {message:"User type updated"};
        return Error;
    }

    Error = {message:response.reasonPhrase};
    return Error;
}

@Description {value: "Update the display name of the user"}
@Param {value: "displayName: New display name"}
@Param {value: "error: Error"}
public function <User user> updateDisplayName(string displayName) (error){
    endpoint <http:HttpClient> scimClient{
        scimHTTPClient;
    }
    error Error;

    if(user == null || displayName == ""){
        Error = {message:"User and profile url should be valid"};
        return Error;
    }

    http:OutRequest request = {};
    http:InResponse response = {};
    http:HttpConnectorError httpError;

    json body;
    body, _ = <json>SCIM_PATCH_ADD_BODY;
    body.Operations[0].value = {"displayName":displayName};

    request = createRequest(body);

    string url = SCIM_USER_END_POINT+"/"+user.id;
    response, httpError = scimClient.patch(url,request);

    if(response.statusCode==SCIM_FOUND){
        Error = {message:"Display name updated"};
        return Error;
    }

    Error = {message:response.reasonPhrase};
    return Error;
}

@Description {value: "Update the external ID of the user"}
@Param {value: "externald: New external ID"}
@Param {value: "error: Error"}
public function <User user> updateExternalId(string externalId) (error){
    endpoint <http:HttpClient> scimClient{
        scimHTTPClient;
    }
    error Error;

    if(user == null || externalId == ""){
        Error = {message:"User and external ID should be valid"};
        return Error;
    }

    http:OutRequest request = {};
    http:InResponse response = {};
    http:HttpConnectorError httpError;

    json body;
    body, _ = <json>SCIM_PATCH_ADD_BODY;
    body.Operations[0].value = {"externalId":externalId};

    request = createRequest(body);

    string url = SCIM_USER_END_POINT+"/"+user.id;
    response, httpError = scimClient.patch(url,request);

    if(response.statusCode==SCIM_FOUND){
        Error = {message:"externalId updated"};
        return Error;
    }

    Error = {message:response.reasonPhrase};
    return Error;
}
//======================================================================================================================
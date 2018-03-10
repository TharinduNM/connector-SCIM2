package src.wso2.scimclient;

import ballerina.net.http;
import ballerina.io;
import ballerina.log;

@Description { value : "User Administration client connector for wso2 Identity Server"}
@Param { value : "base64UserNamePassword : The base 64 encoded string in the format username:password"}
@Param { value : "ipAndPort: The string containing IP and the Port of the service in the format IP:Port"}
@Param { value : "option: The http option object with the location and password of the Identity Server trust store file"}
public connector ScimConnector (string base64UserNamePasswword) {

    endpoint<http:HttpClient> scim2EP{
        create http:HttpClient(getURL(),getConnectionConfigs());
    }

    @Description {value: "Create a group in the user store"}
    @Param {value: "group: Group struct with group details"}
    @Param {value: "Group: Group struct"}
    @Param {value: "error: Error"}
    action createGroup(Group group)(error){
        http:OutRequest request = {};
        http:InResponse response = {};
        error Error;
        http:HttpConnectorError httpError;

        request.addHeader(SCIM_AUTHORIZATION,"Basic "+base64UserNamePasswword);
        request.addHeader(SCIM_CONTENT_TYPE, SCIM_JSON);

        json jsonPayload = <json, convertGroupToJson()>group;
        request.setJsonPayload(jsonPayload);
        response , httpError = scim2EP.post(SCIM_GROUP_END_POINT,request);
        if (httpError != null){
            Error = {message:httpError.message, cause:httpError.cause};
            return Error;
        }
        else if (response.statusCode==SCIM_UNAUTHORIZED){
            return {message:response.reasonPhrase};
        }
        try{
            if(response.statusCode==SCIM_CREATED){
                return {message:response.reasonPhrase};
            }
            else{
                var receivedBinaryPayload, _ = response.getBinaryPayload();
                string receivedPayload = receivedBinaryPayload.toString("UTF-8");
                var payload, _ = <json>receivedPayload;
                return {message:payload.detail.toString()};
            }
        }catch (error e) {
            Error = {message:e.message, cause:e.cause};
            return Error;
        }
        return Error;
    }

    @Description {value: "Get a group in the user store by name"}
    @Param {value: "groupName: The display Name of the group"}
    @Param {value: "Group: Group struct"}
    @Param {value: "error: Error"}
    action getGroupByName (string groupName) (Group, error) {
        http:OutRequest request = {};
        http:InResponse response = {};
        error Error;
        http:HttpConnectorError httpError;
        Group receivedGroup = {};

        request.addHeader(SCIM_AUTHORIZATION,"Basic "+base64UserNamePasswword);

        string s = SCIM_GROUP_END_POINT+"?"+SCIM_FILTER_GROUP_BY_NAME+groupName;
        response, httpError = scim2EP.get(s,request);

        receivedGroup,Error = resolveGroup(groupName, response, httpError);
        return receivedGroup, Error;
    }

    @Description {value: "Create a user in the user store"}
    @Param {value: "user: user struct with user details"}
    @Param {value: "string: string indicating whether user creation was successful or failed"}
    @Param {value: "error: Error"}
    action createUser(User user)(error){
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;

        json jsonPayload;
        try{
            jsonPayload = <json,convertUserToJson()>user;
        }catch (error e){
            Error = {message:e.message,cause:e.cause};
            return Error;
        }

        request.addHeader(SCIM_AUTHORIZATION,"Basic "+base64UserNamePasswword);
        request.addHeader(SCIM_CONTENT_TYPE, SCIM_JSON);
        request.setJsonPayload(jsonPayload);
        response, httpError = scim2EP.post(SCIM_USER_END_POINT,request);
        if (httpError != null){
            Error = {message:httpError.message, cause:httpError.cause};
            return Error;
        }
        if (response.statusCode==201){
            Error = {message:response.reasonPhrase};
            return Error;
        }
        Error = {message:response.reasonPhrase,cause:null};
        return Error;
    }

    @Description {value: "Get a user in the user store by his user name"}
    @Param {value: "userName: User name of the user"}
    @Param {value: "User: User struct"}
    @Param {value: "error: Error"}
    action getUserByUsername (string userName) (User, error) {
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;
        User user = {};

        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);

        response, httpError = scim2EP.get(SCIM_USER_END_POINT+"?"+SCIM_FILTER_USER_BY_USERNAME + userName, request);

        user, Error = resolveUser(userName, response, httpError);
        return user, Error;

    }

    @Description {value: "Add an user in the user store to a existing group"}
    @Param {value: "userName: User name of the user"}
    @Param {value: "groupName: Display name of the group"}
    @Param {value: "Group: Group struct"}
    @Param {value: "error: Error"}
    action addUserToGroup(string userName, string groupName) (Group, error){
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error groupError;
        //check if user valid
        http:OutRequest requestUser = {};
        http:InResponse responseUser = {};
        error userError;
        User user = {};
        requestUser.addHeader(SCIM_AUTHORIZATION,"Basic "+base64UserNamePasswword);
        responseUser, httpError = scim2EP.get(SCIM_USER_END_POINT + "?" + SCIM_FILTER_USER_BY_USERNAME + userName, requestUser);
        user, userError = resolveUser(userName, responseUser, httpError);
        if (user == null){
            return null,userError;
        }
        //check if group valid
        http:OutRequest requestGroup = {};
        http:InResponse responseGroup = {};
        error Error;
        Group group = {};
        requestGroup.addHeader(SCIM_AUTHORIZATION,"Basic "+base64UserNamePasswword);
        responseGroup, httpError = scim2EP.get(SCIM_GROUP_END_POINT + "?" + SCIM_FILTER_GROUP_BY_NAME + groupName, requestGroup);
        group, groupError = resolveGroup(groupName, responseGroup, httpError);
        if (group ==null){
            return null,groupError;
        }
        //create request body
        string value = user.id;
        string ref = getURL()+SCIM_USER_END_POINT+"/" + value;
        string url = SCIM_GROUP_END_POINT+"/"+group.id;
        json body;
        body, _ = <json>SCIM_CREATE_USER_BODY;
        body.Operations[0].value.members[0].display = userName;
        body.Operations[0].value.members[0]["$ref"] = ref;
        body.Operations[0].value.members[0].value = value;

        request.addHeader(SCIM_AUTHORIZATION,"Basic "+base64UserNamePasswword);
        request.addHeader(SCIM_CONTENT_TYPE, SCIM_JSON);
        request.setJsonPayload(body);
        response, httpError = scim2EP.patch(url,request);
        if (httpError != null){
            Error = {message:httpError.message,cause:httpError.cause};
            return null, Error;
        }
        if (response.statusCode==SCIM_UNAUTHORIZED){
            return null, {message:response.reasonPhrase};
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
                log:printError(Error.message);
                return null, Error;
            }
        }
        if (response.statusCode==SCIM_BAD_REQUEST){
            Error = {message:response.reasonPhrase};
            return null, Error;
        }
        Error = {message:response.reasonPhrase};
        return group, Error;
    }

    @Description {value: "Remove an user from a group"}
    @Param {value: "userName: User name of the user"}
    @Param {value: "groupName: Display name of the group"}
    @Param {value: "Group: Group struct"}
    @Param {value: "error: Error"}
    action removeUserFromGroup(string userName, string groupName) (Group, error){
        http:OutRequest request = {};
        http:InResponse response = {};
        error Error;
        http:HttpConnectorError httpError;
        //check if group valid
        Group group = {};
        error groupError;
        http:OutRequest groupRequest = {};
        http:InResponse groupResponse = {};
        groupRequest.addHeader(SCIM_AUTHORIZATION,"Basic "+base64UserNamePasswword);
        groupResponse, httpError = scim2EP.get(SCIM_GROUP_END_POINT+"?"+SCIM_FILTER_GROUP_BY_NAME+groupName, groupRequest);
        group, groupError = resolveGroup(groupName, groupResponse, httpError);
        if (group ==null){
            return null,groupError;
        }
        //create request body
        json body;
        body, _= <json>SCIM_REMOVE_USER_BODY;
        string path = "members[display eq "+userName+"]";
        body.Operations[0].path = path;
        string url = SCIM_GROUP_END_POINT+"/"+group.id;

        request.addHeader(SCIM_AUTHORIZATION,"Basic "+base64UserNamePasswword);
        request.addHeader(SCIM_CONTENT_TYPE, SCIM_JSON);
        request.setJsonPayload(body);
        response, httpError = scim2EP.patch(url,request);
        if(httpError != null){
            Error = {message:httpError.message,cause:httpError.cause};
            return null,Error;
        }
        if (response.statusCode==SCIM_UNAUTHORIZED){
            return null, {message:response.reasonPhrase};
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
                log:printError(Error.message);
                return null, Error;
            }
        }
        if (response.statusCode==SCIM_BAD_REQUEST){
            Error = {message:response.reasonPhrase};
            return null, Error;
        }
        Error = {message:response.reasonPhrase};
        return group, Error;
    }

    @Description {value: "Check whether an user is in a certain group"}
    @Param {value: "userName: User name of the user"}
    @Param {value: "groupName: Display name of the group"}
    @Param {value: "boolean: true/false"}
    @Param {value: "error: Error"}
    action isUserInGroup(string userName, string groupName) (boolean, error){
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;
        User user = {};
        error userE;

        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        response, httpError = scim2EP.get(SCIM_USER_END_POINT+"?"+SCIM_FILTER_USER_BY_USERNAME + userName, request);
        user, userE = resolveUser(userName, response, httpError);
        if(user == null){
            Error = {message:userE.message,cause:userE.cause};
            return false,Error;
        }else{
            if(user.groups == null){
                return false, null;
            }else{
                foreach group in user.groups{
                    if(group.displayName.equalsIgnoreCase(groupName)){
                        return true, null;
                    }
                }

            }
            return false, null;
        }
    }

    @Description {value: "Delete an user from user store using his user name"}
    @Param {value: "userName: User name of the user"}
    @Param {value: "string: string literal"}
    @Param {value: "error: Error"}
    action deleteUserByUsername(string userName) (error){
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;
        //get user
        http:OutRequest userRequest = {};
        http:InResponse userResponse = {};
        http:HttpConnectorError userError;
        User user = {};
        error userE;
        userRequest.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        userResponse, userError = scim2EP.get(SCIM_USER_END_POINT+"?"+SCIM_FILTER_USER_BY_USERNAME + userName, userRequest);
        user, userE = resolveUser(userName, userResponse, userError);
        if(user == null){
            Error = {message:userE.message,cause:userE.cause};
            return Error;
        }

        string userId = user.id;
        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        response,httpError = scim2EP.delete(SCIM_USER_END_POINT+"/"+userId, request);
        if (httpError != null){
            Error = {message:httpError.message,cause:httpError.cause};
            return Error;
        }
        if (response.statusCode==SCIM_DELETED){
            Error = {message:SCIM_DELETE_MESSEGE};
            return Error;
        }
        Error = {message:response.reasonPhrase};
        return Error;
    }

    @Description {value: "Delete group using its name"}
    @Param {value: "groupName: Display name of the group"}
    @Param {value: "string: string literal"}
    @Param {value: "error: Error"}
    action deleteGroupByName(string groupName) (error){
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;
        //get the group
        http:OutRequest groupRequest = {};
        http:InResponse groupResponse = {};
        error groupE;
        http:HttpConnectorError groupError;
        Group group = {};
        groupRequest.addHeader(SCIM_AUTHORIZATION,"Basic "+base64UserNamePasswword);
        string s = SCIM_GROUP_END_POINT+"?"+SCIM_FILTER_GROUP_BY_NAME+groupName;
        groupResponse, groupError = scim2EP.get(s,groupRequest);
        group,groupE = resolveGroup(groupName, groupResponse, groupError);
        if(group == null){
            Error = {message:groupE.message,cause:groupE.cause};
            return Error;
        }

        string groupId = group.id;
        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        response,httpError = scim2EP.delete(SCIM_GROUP_END_POINT+"/"+groupId, request);
        if (httpError != null){
            Error = {message:httpError.message,cause:httpError.cause};
            return Error;
        }
        if (response.statusCode==SCIM_DELETED){
            Error = {message:SCIM_DELETE_MESSEGE};
            return Error;
        }
        Error = {message:response.reasonPhrase};
        return Error;

    }

    @Description {value: "Get the whole list of users in the user store"}
    @Param {value: "User[]: Array of User structs"}
    @Param {value: "error: Error"}
    action getListOfUsers() (User[], error) {
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;
        User[] userList = [];

        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        response, httpError = scim2EP.get(SCIM_USER_END_POINT, request);

        if (httpError != null) {
            Error = {message:httpError.message, cause:httpError.cause};
            return userList, Error;
        }
        if (response.statusCode==SCIM_UNAUTHORIZED){
            return null, {message:response.reasonPhrase};
        }
        if (response.statusCode==SCIM_FOUND){
            try {
                var receivedBinaryPayload, _ = response.getBinaryPayload();
                string receivedPayload = receivedBinaryPayload.toString("UTF-8");
                var payload, _ = <json>receivedPayload;
                var noOfResults = payload[SCIM_TOTAL_RESULTS].toString();
                if (noOfResults.equalsIgnoreCase("0")) {
                    Error = {message:"There are no users", cause:null};
                    return null, Error;
                } else {
                    payload = payload["Resources"];
                    int k = 0;
                    foreach element in payload{
                        User user = {};
                        user = <User,convertJsonToUser()>element;
                        userList[k] = user;
                        k = k+1;
                    }
                }
            } catch (error e) {
                Error = {message:e.message, cause:e.cause};
                return userList, Error;
            }
        }
        if (response.statusCode == SCIM_BAD_REQUEST) {
            Error = {message:response.reasonPhrase, cause:null};
            return userList, Error;
        }
        if (response.statusCode == SCIM_NOT_FOUND) {
            Error = {message:"Valid users are not found", cause:null};
            return userList, Error;
        }

        return userList, Error;
    }

    @Description {value: "Get the whole list of groups"}
    @Param {value: "Group[]: Array of Group structs"}
    @Param {value: "error: Error"}
    action getListOfGroups() (Group[], error){
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;
        Group[] groupList = [];

        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        response, httpError = scim2EP.get(SCIM_GROUP_END_POINT, request);
        if (httpError != null) {
            Error = {message:httpError.message, cause:httpError.cause};
            return groupList, Error;
        }
        if (response.statusCode==SCIM_UNAUTHORIZED){
            return null, {message:response.reasonPhrase};
        }
        if (response.statusCode==SCIM_FOUND){
            try{

                var receivedBinaryPayload, _ = response.getBinaryPayload();
                string receivedPayload = receivedBinaryPayload.toString("UTF-8");
                var payload, _ = <json>receivedPayload;
                var noOfResults = payload[SCIM_TOTAL_RESULTS].toString();
                if (noOfResults.equalsIgnoreCase("0")) {
                    Error = {message:"There are no groups", cause:null};
                    return groupList, Error;
                }else {
                    payload = payload["Resources"];
                    int k = 0;
                    foreach element in payload{
                        Group group = {};
                        group = <Group, convertJsonToGroup()>element;
                        groupList[k]=group;
                        k = k+1;
                    }
                }
            }catch (error e){
                Error = {message:e.message,cause:e.cause};
                return groupList,Error;
            }
        }

        if (response.statusCode == SCIM_BAD_REQUEST) {
            Error = {message:response.reasonPhrase, cause:null};
            return groupList, Error;
        }
        if (response.statusCode == SCIM_NOT_FOUND) {
            Error = {message:"Valid groups are not found", cause:null};
            return groupList, Error;
        }
        return groupList,Error;
    }
}


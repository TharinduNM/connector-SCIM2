package src.wso2.scimclient;

import ballerina.net.http;
import ballerina.io;
import ballerina.log;

@Description { value : "User Administration client connector for wso2 Identity Server"}
@Param { value : "base64UserNamePassword : The base 64 encoded string in the format username:password"}
@Param { value : "ipAndPort: The string containing IP and the Port of the service in the format IP:Port"}
@Param { value : "option: The http option object with the location and password of the Identity Server trust store file"}
public connector ScimConnector (string base64UserNamePasswword, string ipAndPort, http:Options option) {

    endpoint<http:HttpClient> scim2EP{
        create http:HttpClient("https://"+ipAndPort+"/scim2",option);
    }

    @Description {value: "Create a group in the user store"}
    @Param {value: "group: Group struct with group details"}
    @Param {value: "Group: Group struct"}
    @Param {value: "error: Error"}
    action createGroup(Group group)(Group, error){
        http:OutRequest request = {};
        http:InResponse response = {};
        error Error;
        http:HttpConnectorError httpError;
        Group receivedGroup = {};

        request.addHeader(SCIM_AUTHORIZATION,"Basic "+base64UserNamePasswword);
        request.addHeader(SCIM_CONTENT_TYPE, SCIM_JSON);
        //validate the data fields in the incoming group struct
        group.id="";
        if (group.members==null){
            group.members=[];
        }

        var jsonPayload, _ = <json>group;
        request.setJsonPayload(jsonPayload);

        response , httpError = scim2EP.post(SCIM_GROUP_END_POINT,request);
        if (httpError != null){
            Error = {message:httpError.message, cause:httpError.cause};
            return receivedGroup, Error;
        }
        try{
            string receivedPayload = response.getBinaryPayload().toString("UTF-8");
            var payload, _ = <json>receivedPayload;
            var receivedResponse, conversionError = <Group>payload;
            receivedGroup = receivedResponse;
            if(conversionError != null){
                if(payload == null) {
                    log:printError(conversionError.message);
                }
                Error = {message:payload[SCIM_PAYLOAD_DETAIL].toString(),cause:null};
            }
        }catch (error e) {
            Error = {message:e.message, cause:e.cause};
            log:printError(Error.message);
            return receivedGroup, Error;
        }
        return receivedGroup, Error;

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

        string s = SCIM_GROUP_END_POINT+"?attributes=displayName,id,members&"+SCIM_FILTER_GROUP_BY_NAME+groupName;
        response, httpError = scim2EP.get(s,request);

        receivedGroup,Error = resolveGroup(groupName, response, httpError);
        return receivedGroup, Error;
    }

    @Description {value: "Create a user in the user store"}
    @Param {value: "user: user struct with user details"}
    @Param {value: "string: string indicating whether user creation was successful or failed"}
    @Param {value: "error: Error"}
    action createUser(User user)(string, error){
        http:OutRequest request = {};
        http:InResponse response = {};
        error Error;
        http:HttpConnectorError httpError;

        request.addHeader(SCIM_AUTHORIZATION,"Basic "+base64UserNamePasswword);
        request.addHeader(SCIM_CONTENT_TYPE, SCIM_JSON);

        if(user.groups == null){
            user.groups = [];
        }
        if(user.name == null){
            user.name = {};
        }
        //remove details field if it is null
        json payload;
        if(user.details == null){
            user.details = "null";
            try{
                var payload, e = <json>user;
                payload.remove("details");
            }catch (error e){
                Error = {message:"userName,password and id should be strings",cause:e.cause};
                log:printError(e.message);
                return SCIM_FAIL_MESSAGE,Error;
            }

        }
            //////////

        else{
            try{
                var payload, e = <json>user;
                json details = payload["details"];
                payload.remove("details");
                string realPayload;
                string detailsLoad;
                realPayload = payload.toString();
                realPayload = realPayload.subString(0,realPayload.length()-1);
                detailsLoad = details.toString();
                detailsLoad = detailsLoad.subString(1,detailsLoad.length());
                realPayload = realPayload + "," + detailsLoad;
                payload, e = <json>realPayload;
            }catch (error e){
                Error = {message:e.message,cause:e.cause};
                log:printError(Error.message);
                return SCIM_FAIL_MESSAGE,Error;
            }

        }

        request.setJsonPayload(payload);

        response, httpError = scim2EP.post(SCIM_USER_END_POINT,request);

        if (httpError != null){
            Error = {message:httpError.message, cause:httpError.cause};
            return SCIM_FAIL_MESSAGE, Error;
        }
        if (response.statusCode==201){
            return SCIM_CREATE_MESSAGE,Error;
        }
        Error = {message:response.reasonPhrase,cause:null};
        return SCIM_FAIL_MESSAGE,Error;

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
        http:OutRequest requestUser = {};
        http:OutRequest requestGroup = {};
        http:InResponse responseUser = {};
        http:InResponse responseGroup = {};
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error userError;
        User user = {};
        error groupError;
        Group group = {};
        error Error;

        requestUser.addHeader(SCIM_AUTHORIZATION,"Basic "+base64UserNamePasswword);
        requestGroup.addHeader(SCIM_AUTHORIZATION,"Basic "+base64UserNamePasswword);

        responseUser, httpError = scim2EP.get(SCIM_USER_END_POINT + "?" + SCIM_FILTER_USER_BY_USERNAME + userName, requestUser);
        user, userError = resolveUser(userName, responseUser, httpError);
        if (user == null){
            return null,userError;
        }

        responseGroup, httpError = scim2EP.get(SCIM_GROUP_END_POINT + "?attributes=displayName,id,members&" + SCIM_FILTER_GROUP_BY_NAME + groupName, requestGroup);
        group, groupError = resolveGroup(groupName, responseGroup, httpError);
        if (group ==null){
            return null,groupError;
        }

        string value = user.id;
        string ref = "https://"+ipAndPort+"/scim2"+SCIM_USER_END_POINT+"/" + value;
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
        var stringPayload = response.getBinaryPayload().toString("UTF-8");
        var payload, e = <json>stringPayload;
        group, Error = <Group>payload;
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
        http:OutRequest groupRequest = {};
        http:InResponse groupResponse = {};
        error Error;
        http:HttpConnectorError httpError;
        Group group = {};
        error groupError;

        groupRequest.addHeader(SCIM_AUTHORIZATION,"Basic "+base64UserNamePasswword);
        groupResponse, httpError = scim2EP.get(SCIM_GROUP_END_POINT+"?attributes=displayName,id,members&"+SCIM_FILTER_GROUP_BY_NAME+groupName, groupRequest);
        group, groupError = resolveGroup(groupName, groupResponse, httpError);
        if (group ==null){
            return null,groupError;
        }

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

    @Description {value: "Check whether an user is in a certain group"}
    @Param {value: "userName: User name of the user"}
    @Param {value: "groupName: Display name of the group"}
    @Param {value: "boolean: true/false"}
    @Param {value: "error: Error"}
    action isUserInGroup(string userName, string groupName) (boolean, error){
        /////////////////////////////////////////////////////////////////////////////////////////////////
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;
        User user = {};
        error userE;

        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);

        response, httpError = scim2EP.get(SCIM_USER_END_POINT+"?"+SCIM_FILTER_USER_BY_USERNAME + userName, request);

        user, userE = resolveUser(userName, response, httpError);
        //////////////////////////////////////////////////////////////////////////////////////////////////
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
    action deleteUserByUsername(string userName) (string, error){
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;

        /////////////
        http:OutRequest userRequest = {};
        http:InResponse userResponse = {};
        http:HttpConnectorError userError;
        User user = {};
        error userE;

        userRequest.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);

        userResponse, userError = scim2EP.get(SCIM_USER_END_POINT+"?"+SCIM_FILTER_USER_BY_USERNAME + userName, userRequest);

        user, userE = resolveUser(userName, userResponse, userError);
        ////////////////////
        if(user == null){
            Error = {message:userE.message,cause:userE.cause};
            return SCIM_FAIL_MESSAGE,Error;
        }
        try{
            string userId = user.id;
            request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
            response,httpError = scim2EP.delete(SCIM_USER_END_POINT+"/"+userId, request);
            return SCIM_DELETE_MESSEGE,Error;
        }catch (error e){
            Error = {message:e.message,cause:e.cause};
            return SCIM_FAIL_MESSAGE,Error;
        }
        return SCIM_DELETE_MESSEGE,Error;
    }

    @Description {value: "Delete group using its name"}
    @Param {value: "groupName: Display name of the group"}
    @Param {value: "string: string literal"}
    @Param {value: "error: Error"}
    action deleteGroupByName(string groupName) (string, error){
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;
        /////////////////////////////////
        http:OutRequest groupRequest = {};
        http:InResponse groupResponse = {};
        error groupE;
        http:HttpConnectorError groupError;
        Group group = {};

        groupRequest.addHeader(SCIM_AUTHORIZATION,"Basic "+base64UserNamePasswword);

        string s = SCIM_GROUP_END_POINT+"?attributes=displayName,id,members&"+SCIM_FILTER_GROUP_BY_NAME+groupName;
        groupResponse, groupError = scim2EP.get(s,groupRequest);

        group,groupE = resolveGroup(groupName, groupResponse, groupError);
        /////////////////////////////////////////////

        if(group == null){
            Error = {message:groupE.message,cause:groupE.cause};
            return SCIM_FAIL_MESSAGE,Error;
        }
        try{
            string groupId = group.id;

            request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
            response,httpError = scim2EP.delete(SCIM_GROUP_END_POINT+"/"+groupId, request);
            return SCIM_DELETE_MESSEGE,Error;
        }catch (error e){
            Error = {message:e.message,cause:e.cause};
            return SCIM_FAIL_MESSAGE,Error;
        }
        return SCIM_DELETE_MESSEGE,Error;
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
        try {
            if (response.statusCode == 400) {
                Error = {message:response.reasonPhrase, cause:null};
                return userList, Error;
            }
            if (response.statusCode == 404) {
                Error = {message:"Valid users are not found", cause:null};
                return userList, Error;
            }

            string receivedPayload = response.getBinaryPayload().toString("UTF-8");
            var payload, _ = <json>receivedPayload;
            var noOfResults = payload[SCIM_TOTAL_RESULTS].toString();
            if (noOfResults.equalsIgnoreCase("1")) {
                Error = {message:"There are no users other than Admin", cause:null};
                return null, Error;
            } else {
                payload = payload["Resources"];
                int k = 0;
                foreach element in payload{
                    string[] userKeyList = element.getKeys();
                    User user = {};
                    foreach key in userKeyList{
                        if (key.equalsIgnoreCase("userName")){
                            user.userName = element["userName"].toString();
                            element.remove("userName");
                        }
                        if (key.equalsIgnoreCase("id")){
                            user.id = element["id"].toString();
                            element.remove("id");
                        }
                        if (key.equalsIgnoreCase("name")){
                            user.name = <Name,convertName()>element["name"];
                            element.remove("name");
                        }
                        if (key.equalsIgnoreCase("groups")){
                            int i = 0;
                            user.groups = [];
                            foreach group in element[key]{
                                var tempGroup = <Group,convertGroupInUser()>group;
                                user.groups[i]=tempGroup;
                                i=i+1;
                            }
                            element.remove(key);
                        }
                    }
                    user.details = element;
                    userList[k] = user;
                    k = k+1;
                }

            }
        } catch (error e) {
            Error = {message:e.message, cause:e.cause};
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
        try{
            if (response.statusCode == 400) {
                Error = {message:response.reasonPhrase, cause:null};
                return groupList, Error;
            }
            if (response.statusCode == 404) {
                Error = {message:"Valid groups are not found", cause:null};
                return groupList, Error;
            }

            string receivedPayload = response.getBinaryPayload().toString("UTF-8");
            var payload, _ = <json>receivedPayload;
            var noOfResults = payload[SCIM_TOTAL_RESULTS].toString();
            if (noOfResults.equalsIgnoreCase("0")) {
                Error = {message:"There are no groups", cause:null};
                return groupList, Error;
            }else {
                payload = payload["Resources"];
                int i = 0;
                foreach element in payload{
                    Group group = {};
                    error er;
                    if(isMembersPresent(element)){
                        group, er = <Group>element;
                    }
                    else{
                        group = <Group,convertGroupInRemoveResponse()>element;
                    }

                    if(er != null){
                        Error = {message:er.message,cause:er.cause};
                    }
                    groupList[i]=group;
                    i = i+1;
                }
            }
        }catch (error e){
            Error = {message:e.message,cause:e.cause};
            return groupList,Error;
        }

        return groupList,Error;
    }
}


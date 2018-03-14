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

http:HttpClient scimHTTPClient =  create http:HttpClient(getURL(),getConnectionConfigs());

@Description {value:"SCIM 2.0 client connector"}
@Param {value:"base64UserNamePassword : The base 64 encoded string in the format username:password"}
public connector ScimConnector (string base64UserNamePasswword) {

    endpoint<http:HttpClient> scim2EP {
        scimHTTPClient;
    }

    @Description {value:"Create a group in the user store"}
    @Param {value:"group: Group struct with group details"}
    @Param {value:"Group: Group struct"}
    @Param {value:"error: Error"}
    action createGroup (Group group) (error) {
        http:OutRequest request = {};
        http:InResponse response = {};
        error Error;
        http:HttpConnectorError connectorError;

        string failedMessage;
        failedMessage = "Creating group:" + group.displayName + " failed. ";

        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        request.addHeader(SCIM_CONTENT_TYPE, SCIM_JSON);

        json jsonPayload = <json, convertGroupToJson()>group;
        request.setJsonPayload(jsonPayload);
        response, connectorError = scim2EP.post(SCIM_GROUP_END_POINT, request);
        if (connectorError != null) {
            Error = {message:failedMessage + connectorError.message, cause:connectorError.cause};
            return Error;
        }
        int statusCode = response.statusCode;
        if (statusCode == HTTP_UNAUTHORIZED) {
            Error = {message:failedMessage + response.reasonPhrase};
            return Error;
        } else if (statusCode == HTTP_CREATED) {
            Error = {message:response.reasonPhrase};
            return Error;
        } else {
            try {
                var receivedBinaryPayload, _ = response.getBinaryPayload();
                string receivedPayload = receivedBinaryPayload.toString("UTF-8");
                var payload, _ = <json>receivedPayload;
                Error = {message:failedMessage + payload.detail.toString()};
                return Error;
            } catch (error e) {
                Error = {message:failedMessage + e.message, cause:e.cause};
                return Error;
            }
        }
        return Error;
    }

    @Description {value:"Get a group in the user store by name"}
    @Param {value:"groupName: The display Name of the group"}
    @Param {value:"Group: Group struct"}
    @Param {value:"error: Error"}
    action getGroupByName (string groupName) (Group, error) {
        http:OutRequest request = {};
        http:InResponse response = {};
        error Error;
        http:HttpConnectorError httpError;
        Group receivedGroup = {};

        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);

        string s = SCIM_GROUP_END_POINT + "?" + SCIM_FILTER_GROUP_BY_NAME + groupName;
        response, httpError = scim2EP.get(s, request);

        receivedGroup, Error = resolveGroup(groupName, response, httpError);
        return receivedGroup, Error;
    }

    @Description {value:"Create a user in the user store"}
    @Param {value:"user: user struct with user details"}
    @Param {value:"string: string indicating whether user creation was successful or failed"}
    @Param {value:"error: Error"}
    action createUser (User user) (error) {
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;

        string failedMessage;
        failedMessage = "Creating user:" + user.userName + " failed. ";

        if (user.emails != null) {
            foreach email in user.emails {
                if (!email.|type|.equalsIgnoreCase("work") && !email.|type|.equalsIgnoreCase("home")
                                                               && !email.|type|.equalsIgnoreCase("other")) {
                    Error = {message:failedMessage + "Email should either be home or work"};
                    return Error;
                }
            }
        }
        if (user.addresses != null) {
            foreach address in user.addresses {
                if (!address.|type|.equalsIgnoreCase("work") && !address.|type|.equalsIgnoreCase("home")
                                                                 && !address.|type|.equalsIgnoreCase("other")) {
                    Error = {message:failedMessage + "Address type should either be work or home"};
                    return Error;
                }
            }
        }
        if (user.phoneNumbers != null) {
            foreach phone in user.phoneNumbers {
                if (!phone.|type|.equalsIgnoreCase("work") && !phone.|type|.equalsIgnoreCase("home")
                                                               && !phone.|type|.equalsIgnoreCase("mobile")
                                                                   && !phone.|type|.equalsIgnoreCase("fax")
                                                                       && !phone.|type|.equalsIgnoreCase("pager")
                                                                           && !phone.|type|.equalsIgnoreCase("other")) {
                    Error = {message:failedMessage + "Phone number type should be work,mobile,fax,pager,home or other"};
                    return Error;
                }
            }
        }
        if (user.photos != null) {
            foreach photo in user.photos {
                if (!photo.|type|.equalsIgnoreCase("photo") && !photo.|type|.equalsIgnoreCase("thumbnail")) {
                    Error = {message:failedMessage + "Photo type should either be photo or thumbnail"};
                    return Error;
                }
            }
        }

        json jsonPayload;
        try {
            jsonPayload = <json, convertUserToJson()>user;
        } catch (error e) {
            Error = {message:failedMessage + e.message, cause:e.cause};
            return Error;
        }

        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        request.addHeader(SCIM_CONTENT_TYPE, SCIM_JSON);
        request.setJsonPayload(jsonPayload);
        response, httpError = scim2EP.post(SCIM_USER_END_POINT, request);
        if (httpError != null) {
            Error = {message:failedMessage + httpError.message, cause:httpError.cause};
            return Error;
        }
        if (response.statusCode == HTTP_CREATED) {
            Error = {message:response.reasonPhrase};
            return Error;
        }
        Error = {message:failedMessage + response.reasonPhrase, cause:null};
        return Error;
    }

    @Description {value:"Get a user in the user store by his user name"}
    @Param {value:"userName: User name of the user"}
    @Param {value:"User: User struct"}
    @Param {value:"error: Error"}
    action getUserByUsername (string userName) (User, error) {
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;
        User user = {};

        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);

        response, httpError = scim2EP.get(SCIM_USER_END_POINT + "?" + SCIM_FILTER_USER_BY_USERNAME + userName, request);

        user, Error = resolveUser(userName, response, httpError);
        return user, Error;

    }

    @Description {value:"Add an user in the user store to a existing group"}
    @Param {value:"userName: User name of the user"}
    @Param {value:"groupName: Display name of the group"}
    @Param {value:"Group: Group struct"}
    @Param {value:"error: Error"}
    action addUserToGroup (string userName, string groupName) (Group, error) {
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;

        string failedMessage;
        failedMessage = "Adding user:" + userName + " to group:" + groupName + " failed.";

        //check if user valid
        http:OutRequest requestUser = {};
        http:InResponse responseUser = {};
        error userError;
        User user;
        requestUser.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        responseUser, httpError = scim2EP.get(SCIM_USER_END_POINT + "?" + SCIM_FILTER_USER_BY_USERNAME +
                                              userName, requestUser);
        user, userError = resolveUser(userName, responseUser, httpError);
        if (user == null) {
            Error = {message:failedMessage + userError.message};
            return null, Error;
        }
        //check if group valid
        http:OutRequest requestGroup = {};
        http:InResponse responseGroup = {};
        Group group;
        error groupError;
        requestGroup.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        responseGroup, httpError = scim2EP.get(SCIM_GROUP_END_POINT + "?" + SCIM_FILTER_GROUP_BY_NAME +
                                               groupName, requestGroup);
        group, groupError = resolveGroup(groupName, responseGroup, httpError);
        if (group == null) {
            Error = {message:failedMessage + groupError.message};
            return group, Error;
        }
        //create request body
        string value = user.id;
        string ref = getURL() + SCIM_USER_END_POINT + "/" + value;
        string url = SCIM_GROUP_END_POINT + "/" + group.id;
        json body;
        body, _ = <json>SCIM_GROUP_PATCH_ADD_BODY;
        body.Operations[0].value.members[0].display = userName;
        body.Operations[0].value.members[0]["$ref"] = ref;
        body.Operations[0].value.members[0].value = value;

        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        request.addHeader(SCIM_CONTENT_TYPE, SCIM_JSON);
        request.setJsonPayload(body);
        response, httpError = scim2EP.patch(url, request);
        if (httpError != null) {
            Error = {message:failedMessage + httpError.message, cause:httpError.cause};
            return null, Error;
        }
        if (response.statusCode == HTTP_OK) {
            try {
                var receivedBinaryPayload, _ = response.getBinaryPayload();
                string receivedPayload = receivedBinaryPayload.toString("UTF-8");
                var payload, _ = <json>receivedPayload;
                group = <Group, convertJsonToGroup()>payload;
                return group, Error;
            } catch (error e) {
                Error = {message:failedMessage + e.message, cause:e.cause};
                return null, Error;
            }
        }
        Error = {message:failedMessage + response.reasonPhrase};
        return group, Error;
    }

    @Description {value:"Remove an user from a group"}
    @Param {value:"userName: User name of the user"}
    @Param {value:"groupName: Display name of the group"}
    @Param {value:"Group: Group struct"}
    @Param {value:"error: Error"}
    action removeUserFromGroup (string userName, string groupName) (Group, error) {
        http:OutRequest request = {};
        http:InResponse response = {};
        error Error;
        http:HttpConnectorError httpError;

        string failedMessage;
        failedMessage = "Removing user:" + userName + " from group:" + groupName + " failed.";

        //check if user valid
        http:OutRequest requestUser = {};
        http:InResponse responseUser = {};
        error userError;
        User user;
        requestUser.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        responseUser, httpError = scim2EP.get(SCIM_USER_END_POINT + "?" + SCIM_FILTER_USER_BY_USERNAME +
                                              userName, requestUser);
        user, userError = resolveUser(userName, responseUser, httpError);
        if (user == null) {
            Error = {message:failedMessage + userError.message};
            return null, Error;
        }
        //check if group valid
        Group group;
        error groupError;
        http:OutRequest groupRequest = {};
        http:InResponse groupResponse = {};
        groupRequest.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        groupResponse, httpError = scim2EP.get(SCIM_GROUP_END_POINT + "?" + SCIM_FILTER_GROUP_BY_NAME +
                                               groupName, groupRequest);
        group, groupError = resolveGroup(groupName, groupResponse, httpError);
        if (group == null) {
            Error = {message:failedMessage + groupError.message};
            return null, Error;
        }
        //create request body
        json body;
        body, _ = <json>SCIM_GROUP_PATCH_REMOVE_BODY;
        string path = "members[display eq " + userName + "]";
        body.Operations[0].path = path;
        string url = SCIM_GROUP_END_POINT + "/" + group.id;

        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        request.addHeader(SCIM_CONTENT_TYPE, SCIM_JSON);
        request.setJsonPayload(body);
        response, httpError = scim2EP.patch(url, request);
        if (httpError != null) {
            Error = {message:failedMessage + httpError.message, cause:httpError.cause};
            return null, Error;
        }
        if (response.statusCode == HTTP_OK) {
            try {
                var receivedBinaryPayload, _ = response.getBinaryPayload();
                string receivedPayload = receivedBinaryPayload.toString("UTF-8");
                var payload, _ = <json>receivedPayload;
                group = <Group, convertJsonToGroup()>payload;
                return group, Error;
            } catch (error e) {
                Error = {message:failedMessage + e.message, cause:e.cause};
                return null, Error;
            }
        }
        Error = {message:failedMessage + response.reasonPhrase};
        return group, Error;
    }

    @Description {value:"Check whether an user is in a certain group"}
    @Param {value:"userName: User name of the user"}
    @Param {value:"groupName: Display name of the group"}
    @Param {value:"boolean: true/false"}
    @Param {value:"error: Error"}
    action isUserInGroup (string userName, string groupName) (boolean, error) {
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;
        User user = {};
        error userE;

        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        response, httpError = scim2EP.get(SCIM_USER_END_POINT + "?" + SCIM_FILTER_USER_BY_USERNAME + userName, request);
        user, userE = resolveUser(userName, response, httpError);
        if (user == null) {
            Error = {message:"failed to check" + userE.message, cause:userE.cause};
            return false, Error;
        } else {
            if (user.groups == null) {
                return false, null;
            } else {
                foreach group in user.groups {
                    if (group.displayName.equalsIgnoreCase(groupName)) {
                        return true, null;
                    }
                }
            }
            return false, null;
        }
    }

    @Description {value:"Delete an user from user store using his user name"}
    @Param {value:"userName: User name of the user"}
    @Param {value:"string: string literal"}
    @Param {value:"error: Error"}
    action deleteUserByUsername (string userName) (error) {
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;

        string failedMessage;
        failedMessage = "Deleting user:" + userName + " failed. ";

        //get user
        http:OutRequest userRequest = {};
        http:InResponse userResponse = {};
        http:HttpConnectorError userError;
        User user;
        error userE;
        userRequest.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        userResponse, userError = scim2EP.get(SCIM_USER_END_POINT + "?" + SCIM_FILTER_USER_BY_USERNAME +
                                              userName, userRequest);
        user, userE = resolveUser(userName, userResponse, userError);
        if (user == null) {
            Error = {message:failedMessage + userE.message, cause:userE.cause};
            return Error;
        }

        string userId = user.id;
        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        response, httpError = scim2EP.delete(SCIM_USER_END_POINT + "/" + userId, request);
        if (httpError != null) {
            Error = {message:failedMessage + httpError.message, cause:httpError.cause};
            return Error;
        }
        if (response.statusCode == HTTP_NO_CONTENT) {
            Error = {message:"deleted"};
            return Error;
        }
        Error = {message:failedMessage + response.reasonPhrase};
        return Error;
    }

    @Description {value:"Delete group using its name"}
    @Param {value:"groupName: Display name of the group"}
    @Param {value:"string: string literal"}
    @Param {value:"error: Error"}
    action deleteGroupByName (string groupName) (error) {
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;

        string failedMessage;
        failedMessage = "Deleting group:" + groupName + " failed. ";

        //get the group
        http:OutRequest groupRequest = {};
        http:InResponse groupResponse = {};
        error groupE;
        http:HttpConnectorError groupError;
        Group group;
        groupRequest.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        string s = SCIM_GROUP_END_POINT + "?" + SCIM_FILTER_GROUP_BY_NAME + groupName;
        groupResponse, groupError = scim2EP.get(s, groupRequest);
        group, groupE = resolveGroup(groupName, groupResponse, groupError);
        if (group == null) {
            Error = {message:failedMessage + groupE.message, cause:groupE.cause};
            return Error;
        }

        string groupId = group.id;
        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        response, httpError = scim2EP.delete(SCIM_GROUP_END_POINT + "/" + groupId, request);
        if (httpError != null) {
            Error = {message:failedMessage + httpError.message, cause:httpError.cause};
            return Error;
        }
        if (response.statusCode == HTTP_NO_CONTENT) {
            Error = {message:"deleted"};
            return Error;
        }
        Error = {message:failedMessage + response.reasonPhrase};
        return Error;

    }

    @Description {value:"Get the whole list of users in the user store"}
    @Param {value:"User[]: Array of User structs"}
    @Param {value:"error: Error"}
    action getListOfUsers () (User[], error) {
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;

        string failedMessage;
        failedMessage = "Listing users failed. ";

        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        response, httpError = scim2EP.get(SCIM_USER_END_POINT, request);

        if (httpError != null) {
            Error = {message:failedMessage + httpError.message, cause:httpError.cause};
            return null, Error;
        }
        if (response.statusCode == HTTP_OK) {
            try {
                var receivedBinaryPayload, _ = response.getBinaryPayload();
                string receivedPayload = receivedBinaryPayload.toString("UTF-8");
                var payload, _ = <json>receivedPayload;
                var noOfResults = payload[SCIM_TOTAL_RESULTS].toString();
                if (noOfResults.equalsIgnoreCase("0")) {
                    Error = {message:"There are no users", cause:null};
                    return null, Error;
                } else {
                    User[] userList = [];
                    payload = payload["Resources"];
                    int k = 0;
                    foreach element in payload {
                        User user = {};
                        user = <User, convertJsonToUser()>element;
                        userList[k] = user;
                        k = k + 1;
                    }
                    return userList, Error;
                }
            } catch (error e) {
                Error = {message:failedMessage + e.message, cause:e.cause};
                return null, Error;
            }
        }
        Error = {message:failedMessage + response.reasonPhrase, cause:null};
        return null, Error;
    }

    @Description {value:"Get the whole list of groups"}
    @Param {value:"Group[]: Array of Group structs"}
    @Param {value:"error: Error"}
    action getListOfGroups () (Group[], error) {
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;

        string failedMessage;
        failedMessage = "Listing groups failed. ";

        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        response, httpError = scim2EP.get(SCIM_GROUP_END_POINT, request);
        if (httpError != null) {
            Error = {message:failedMessage + httpError.message, cause:httpError.cause};
            return null, Error;
        }
        if (response.statusCode == HTTP_OK) {
            try {
                var receivedBinaryPayload, _ = response.getBinaryPayload();
                string receivedPayload = receivedBinaryPayload.toString("UTF-8");
                var payload, _ = <json>receivedPayload;
                var noOfResults = payload[SCIM_TOTAL_RESULTS].toString();
                if (noOfResults.equalsIgnoreCase("0")) {
                    Error = {message:"There are no groups", cause:null};
                    return null, Error;
                } else {
                    Group[] groupList = [];
                    payload = payload["Resources"];
                    int k = 0;
                    foreach element in payload {
                        Group group = {};
                        group = <Group, convertJsonToGroup()>element;
                        groupList[k] = group;
                        k = k + 1;
                    }
                    return groupList, Error;
                }
            } catch (error e) {
                Error = {message:failedMessage + e.message, cause:e.cause};
                return null, Error;
            }
        }
        Error = {message:failedMessage + response.reasonPhrase};
        return null, Error;
    }

    @Description {value:"Get the user that is currently authenticated"}
    @Param {value:"User: User struct"}
    @Param {value:"error: Error"}
    action getMe () (User, error) {
        http:OutRequest request = {};
        http:InResponse response = {};
        http:HttpConnectorError httpError;
        error Error;
        User user;

        string failedMessage = "Getting currently authenticated user failed. ";

        request.addHeader(SCIM_AUTHORIZATION, "Basic " + base64UserNamePasswword);
        response, httpError = scim2EP.get("/Me", request);
        if (httpError != null) {
            Error = {message:failedMessage + httpError.message, cause:httpError.cause};
            return null, Error;
        }
        if (response.statusCode == HTTP_OK) {
            try {

                var receivedBinaryPayload, _ = response.getBinaryPayload();
                string receivedPayload = receivedBinaryPayload.toString("UTF-8");
                var payload, _ = <json>receivedPayload;
                user = <User, convertJsonToUser()>payload;
                return user, Error;
            } catch (error e) {
                Error = {message:failedMessage + e.message, cause:e.cause};
                return user, Error;
            }
        }
        Error = {message:failedMessage + response.reasonPhrase};
        return user, Error;
    }
}


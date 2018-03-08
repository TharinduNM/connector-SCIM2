package src.wso2.scimclient;

import ballerina.net.http;
import ballerina.log;

@Description {value: "Obtain User from the received http response"}
@Param {value: "userName: User name of the user"}
@Param {value: "response: The received http response"}
@Param {value: "httpError: Received httpConnectorError object"}
@Param {value: "User: User struct"}
@Param {value: "error: Error"}
function resolveUser (string userName, http:InResponse response, http:HttpConnectorError httpError) (User, error) {
    User user ={};
    error Error;
    if (httpError != null) {
        Error = {message:httpError.message, cause:httpError.cause};
        return null, Error;
    }

    try {
        if(response.statusCode==400){
            Error = {message:response.reasonPhrase,cause:null};
            return null, Error;
        }
        if(response.statusCode==404){
            Error = {message:"Valid users are not found",cause:null};
            return null, Error;
        }
        string receivedPayload = response.getBinaryPayload().toString("UTF-8");
        var payload, _ = <json>receivedPayload;
        var noOfResults= payload[SCIM_TOTAL_RESULTS].toString();
        if (noOfResults.equalsIgnoreCase("0")){
            Error = {message:"No user with user name "+userName,cause:null};
            return null,Error;
        }else{
            payload = payload["Resources"][0];
            string[] userKeyList = payload.getKeys();
            foreach key in userKeyList{
                string k = key;
                if (key.equalsIgnoreCase("userName")){
                    user.userName = payload["userName"].toString();
                    payload.remove("userName");
                }
                if (key.equalsIgnoreCase("id")){
                    user.id = payload["id"].toString();
                    payload.remove("id");
                }
                if (key.equalsIgnoreCase("name")){
                    user.name = <Name,convertName()>payload["name"];
                    payload.remove("name");
                }
                if (key.equalsIgnoreCase("groups")){
                    int i = 0;
                    user.groups = [];
                    foreach group in payload[key]{
                        var tempGroup = <Group,convertGroupInUser()>group;
                        user.groups[i]=tempGroup;
                        i=i+1;
                    }
                    payload.remove(key);
                }
            }
            user.details = payload;
        }

    } catch (error e) {
        Error = {message:e.message, cause:e.cause};
        log:printError(Error.message);
        return null, Error;
    }
    return user, Error;
}

@Description {value: "Obtain Group from the received http response"}
@Param {value: "groupName: Name of the group"}
@Param {value: "response: The received http response"}
@Param {value: "httpError: Received httpConnectorError object"}
@Param {value: "User: Group struct"}
@Param {value: "error: Error"}
function resolveGroup (string groupName, http:InResponse response, http:HttpConnectorError httpError) (Group, error) {
    Group receivedGroup = {};
    error Error;
    if (httpError != null){
        Error = {message:httpError.message,cause:httpError.cause};
        return null, Error;
    }

    try{
        if(response.statusCode==400){
            Error = {message:response.reasonPhrase,cause:null};
            return null, Error;
        }
        if(response.statusCode==404){
            Error = {message:"Valid groups are not found",cause:null};
            return null, Error;
        }
        string receivedPayload = response.getBinaryPayload().toString("UTF-8");
        var payload, _ = <json>receivedPayload;

        var noOfResults= payload[SCIM_TOTAL_RESULTS].toString();
        if (noOfResults.equalsIgnoreCase("0")){
            Error = {message:"No Group named "+groupName,cause:null};
            return null,Error;
        }
            //adding a empty group array to the incoming json payload if there is no members in the group
        else{
            payload = payload["Resources"][0];
            string[] groupKeys = payload.getKeys();
            if (lengthof groupKeys == 2){
                string temporaryString = payload.toString();
                string temporaryPayload = temporaryString.subString(0,temporaryString.length()-1);
                temporaryPayload = temporaryPayload + ",\"members\":[]}";
                payload, _ = <json>temporaryPayload;
            }
            /////////////////////////////////////////////////////////////////////////////////////////////
            var receivedResponse, conversionError = <Group>payload;
            receivedGroup = receivedResponse;
            if(conversionError != null){
                if(payload == null) {
                    log:printError(conversionError.message);
                }
                log:printError(conversionError.message);
                Error = {message:payload["detail"].toString(),cause:null};
            }

        }


    }catch (error e) {
        Error = {message:e.message, cause:e.cause};
        log:printError(Error.message);
        return null, Error;
    }

    return receivedGroup, Error;
}

@Description {value: "Check whether the member field is available in the received group"}
@Param {value: "group: Json object of group"}
@Param {value: "boolean: true/false"}
function isMembersPresent (json group) (boolean){
    string[] groupKeyList = group.getKeys();
    foreach key in groupKeyList{
        if(key.equalsIgnoreCase("members")){
            return true;
        }
    }
    return false;
}

package src.wso2.useradminclient;

import ballerina.net.http;
import ballerina.io;
import ballerina.log;

@Description { value : "User Administration client connector for wso2 Identity Server"}
@Param { value : "base64UserNamePassword : The base 64 encoded string in the format username:password"}
@Param { value : "ipAndPort: The string containing IP and the Port of the service in the format IP:Port"}
@Param { value : "option: The http option object with the location and password of the Identity Server trust store file"}
public connector ClientConnector (string base64UserNamePasswword, string ipAndPort, http:Options option){

    endpoint<http:HttpClient> scim2EP{
        create http:HttpClient("https://"+ipAndPort+"/scim2",option);
    }

    @Description { value : "Create a group in the user store"}
    @Param { value : "group: Group struct with group details"}
    @Param { value : "Group: Group struct"}
    @Param { value : "error: Error"}
    action createGroup(Group group)(Group, error){
        http:OutRequest request = {};
        http:InResponse response = {};
        error Error;
        http:HttpConnectorError httpError;
        Group receivedGroup = {};

        request.addHeader("Authorization","Basic "+base64UserNamePasswword);
        request.addHeader("Content-Type", "application/json");


        //validate the data fields in the incoming group struct
        group.id="";
        if (group.members==null){
            group.members=[];
        }


        var jsonPayload, _ = <json>group;
        request.setJsonPayload(jsonPayload);

        response , httpError = scim2EP.post("/Groups",request);

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
                Error = {message:payload["detail"].toString(),cause:null};
            }

        }catch (error e) {
            Error = {message:e.message, cause:e.cause};
            log:printError(Error.message);
            return receivedGroup, Error;
        }


        return receivedGroup, Error;

    }

    @Description { value : "Get a group in the user store by name"}
    @Param { value : "groupName: The display Name of the group"}
    @Param { value : "Group: Group struct"}
    @Param { value : "error: Error"}
    action getGroupbyName(string groupName)(Group, error){
        http:OutRequest request = {};
        http:InResponse response = {};
        error Error;
        http:HttpConnectorError httpError;
        Group receivedGroup = {};

        request.addHeader("Authorization","Basic "+base64UserNamePasswword);

        string s = "/Groups?attributes=displayName,id,members&filter=displayName+Eq+"+groupName;
        response, httpError = scim2EP.get(s,request);

        if (httpError != null){
            Error = {message:httpError.message,cause:httpError.cause};
            return receivedGroup, Error;
        }

        try{
            string receivedPayload = response.getBinaryPayload().toString("UTF-8");
            var payload, _ = <json>receivedPayload;
            payload = payload["Resources"][0];
            //adding a empty group array to the incoming json payload if there is no members in the group
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


        }catch (error e) {
            Error = {message:e.message, cause:e.cause};
            log:printError(Error.message);
            return receivedGroup, Error;
        }


        return receivedGroup, Error;
    }

    @Description { value : "Create a user in the user store"}
    @Param { value : "user: user struct with user details"}
    @Param { value : "string: string indicating whether user creation was successful or failed"}
    @Param { value : "error: Error"}
    action createUser(User user)(string, error){
        http:OutRequest request = {};
        http:InResponse response = {};
        error Error;
        http:HttpConnectorError httpError;

        request.addHeader("Authorization","Basic "+base64UserNamePasswword);
        request.addHeader("Content-Type", "application/json");

        if(user.groups == null){
            user.groups = [];
        }
        //remove details field if it is null
        json payload;
        if(user.details == null){
            user.details = "null";
            try{
                var payload, e = <json>user;
                payload.remove("details");
            }catch (error e){
                Error = {message:"userName and id should be strings",cause:e.cause};
                log:printError(e.message);
                return "failed",Error;
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
                return "failed",Error;
            }

        }

        request.setJsonPayload(payload);

        response, httpError = scim2EP.post("/Users",request);

        if (httpError != null){
            Error = {message:httpError.message, cause:httpError.cause};
            return "failed", Error;
        }

        return response.reasonPhrase,Error;

    }

    @Description { value : "Get a user in the user store by his user name"}
    @Param { value : "userName: User name of the user"}
    @Param { value : "User: User struct"}
    @Param { value : "error: Error"}
    action getUserbyUserName(string userName)(User, error){

    }
}

public struct Group{
    string displayName;
    string id;
    Member[] members;
}

public struct Member{
    string display;
    string value;
}

public struct User{
    string userName;
    string id;
    json details;
    Group[] groups;
}
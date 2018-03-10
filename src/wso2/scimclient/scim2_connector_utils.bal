package src.wso2.scimclient;

import ballerina.net.http;
import ballerina.log;
import ballerina.io;


@Description {value: "Obtain the url of the server"}
@Param {value: "URL of the server"}
function getURL()(string){
    string url;
    url = "https://localhost:9443/scim2";
    return url;
}

@Description {value: "Get the http:Option with the trust store file location to provide the http connector with the public certificate for ssl"}
function getConnectionConfigs()(http:Options){
    http:Options option = {
                              ssl:{
                                      trustStoreFile:"/home/tharindu/Documents/IS_HOME/repository/resources/security/truststore.p12",
                                      trustStorePassword:"wso2carbon"
                                  //hostNameVerificationEnabled:false
                                  },
                              followRedirects:{}

                          };
    return option;
}

function getAuthentication() (string){
    string base64UserNamePasswword;
    base64UserNamePasswword ="YWRtaW46YWRtaW4=";
    return base64UserNamePasswword;
}


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
    else if (response.statusCode==SCIM_UNAUTHORIZED){
        Error = {message:"Unauthorized"};
        return null, Error;
    }
    else if (response.statusCode==SCIM_FOUND){
        try {
            var receivedBinaryPayload, _ = response.getBinaryPayload();
            string receivedPayload = receivedBinaryPayload.toString("UTF-8");
            var payload, _ = <json>receivedPayload;
            var noOfResults= payload[SCIM_TOTAL_RESULTS].toString();
            if (noOfResults.equalsIgnoreCase("0")){
                Error = {message:"No user with user name "+userName,cause:null};
                return null,Error;
            }else{
                payload = payload["Resources"][0];
                user = <User, convertJsonToUser()>payload;
            }

        } catch (error e) {
            Error = {message:e.message, cause:e.cause};
            return null, Error;
        }
    }
    else if (response.statusCode==SCIM_NOT_FOUND){
        Error = {message:"Valid users are not found"};
        return null, Error;
    }
    else{
        io:println(response);
        Error = {message:response.reasonPhrase};
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
    if (response.statusCode==SCIM_UNAUTHORIZED){
        return null, {message:response.reasonPhrase};
    }
    if (response.statusCode==SCIM_FOUND){
        try{
            var receivedBinaryPayload, _ = response.getBinaryPayload();
            string receivedPayload = receivedBinaryPayload.toString("UTF-8");
            var payload, _ = <json>receivedPayload;

            var noOfResults= payload[SCIM_TOTAL_RESULTS].toString();
            if (noOfResults.equalsIgnoreCase("0")){
                Error = {message:"No Group named "+groupName,cause:null};
                return null,Error;
            }
            else{
                payload = payload["Resources"][0];
                receivedGroup = <Group, convertJsonToGroup()>payload;
                return receivedGroup, Error;
            }
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
    if (response.statusCode==SCIM_NOT_FOUND){
        Error = {message:"Valid groups are not found"};
        return null, Error;
    }
    Error = {message:response.reasonPhrase};
    return receivedGroup, Error;
}

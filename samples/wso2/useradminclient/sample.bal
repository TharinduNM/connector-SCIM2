package samples.wso2.useradminclient;

import ballerina.net.http;
import ballerina.io;
import src.wso2.useradminclient;

public function main(string[] args){
    endpoint<useradminclient:ClientConnector> userAdminConnector{
        create useradminclient:ClientConnector("YWRtaW46YWRtaW4=","localhost:9443",getConnectionConfigs());
    }


    ////Create a Group in the IS user store using createUser action////////////////////////////////
    //useradminclient:Group getRespondingGroup;
    //error e;
    //useradminclient:Group group = {};
    //group.displayName = "Leader";
    //useradminclient:Member mem = {};
    //mem.display = "ashan";
    //mem.value = "55332c36-1717-4e25-ae11-0322a418a20c";
    //group.members = [mem];
    //getRespondingGroup,e = userAdminConnector.createGroup(group);
    //
    //io:println(getRespondingGroup);
    //io:println(e);
    ////////////////////////////////////////////////////////////////////

    ////Get a Group from the IS user store by it's name using getGroupbyName aciton/////////////////////////
    //useradminclient:Group group = {};
    //error e;
    //group,e = userAdminConnector.getGroupbyName("prime");
    //
    //io:println("after received");
    //io:println(group);
    //io:println(e);
    ///////////////////////////////////////////////////////////////////////////

    ///// Create a User in the IS user store using createUser action
    //useradminclient:User user = {};
    //user.details = {
    //                   "password": "killlosfd",
    //                   "displayName": "Tharindu",
    //                   "nickName": "",
    //                   "profileUrl": "",
    //                   "title": "president",
    //                   "userType": "Employee",
    //                   "preferredLanguage": "sinhala",
    //                   "locale": "colombo",
    //                   "timezone": "",
    //                   "active": "",
    //                   "phoneNumbers": [{
    //                                        "type": "home",
    //                                        "value": "345343"
    //                                    },
    //                                    {
    //                                        "type": "work",
    //                                        "value": "0909099999"
    //                                    }
    //                                   ]
    //
    //               };
    //user.userName="donOmar2";
    //error e;
    //string s;
    //s,e= userAdminConnector.createUser(user);
    //io:println(s);
    //io:println(e);

    ///////Get an user in the IS user store using getUserbyUserName action

}



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
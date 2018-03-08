package samples.wso2.scimclient;

import ballerina.net.http;
import ballerina.io;
import src.wso2.scimclient;

public function main(string[] args){
    endpoint<scimclient:ScimConnector> userAdminConnector {
        create scimclient:ScimConnector("YWRtaW46YWRtaW4=", "localhost:9443", getConnectionConfigs());
    }


    ////Create a Group in the IS user store using createUser action
    //scimclient:Group getRespondingGroup;
    //error e;
    //scimclient:Group group = {};
    //group.displayName = "BOSS";
    //scimclient:Member mem = {};
    //mem.display = "ashan";
    //mem.value = "327e5486-fc3b-4f96-b6ed-237befca6fb4";
    //group.members = [mem];
    //getRespondingGroup,e = userAdminConnector.createGroup(group);
    //io:println(getRespondingGroup);
    //io:println(e);
    //////////////////////////////////////////////////////////////////////////////////////

    ////Get a Group from the IS user store by it's name using getGroupByName aciton
    //scimclient:Group group = {};
    //error e;
    //group,e = userAdminConnector.getGroupByName("BOSS");
    //
    //io:println(group);
    //io:println(e);
    //////////////////////////////////////////////////////////////////////////////////////

    /////// Create a User in the IS user store using createUser action
    //scimclient:User user = {};
    //user.details = {
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
    //user.userName="DULL";
    //user.password="killa";
    //user.name = {};
    //user.name.givenName = "Tharindu";
    //error e;
    //string s;
    //s,e= userAdminConnector.createUser(user);
    //io:println(s);
    //io:println(e);
    //////////////////////////////////////////////////////////////////////////////////////////

    ///////Get an user in the IS user store using getUserbyUserName action
    //scimclient:User user = {};
    //string userName = "donOmar";
    //error e;
    //user,e =userAdminConnector.getUserByUsername(userName);
    //
    //io:println(user);
    //io:println(e);
    /////////////////////////////////////////////////////////////////////////////////////////

    //////Add an existing user to a existing group
    // scimclient:Group group = {};
    // scimclient:User user = {};
    // string userName = "ashan";
    // string groupName = "worker";
    // error e;
    // group,e = userAdminConnector.addUserToGroup(userName, groupName);
    // io:println(e);
    // io:println(group.members);
    ///////////////////////////////////////////////////////////////////////////////////////////

    //////Remove an user from a given group
    //scimclient:Group group = {};
    //string userName = "ashan";
    //string groupName = "worker";
    //error e;
    //group,e = userAdminConnector.removeUserFromGroup(userName, groupName);
    //io:println(e);
    //io:println(group);
    ///////////////////////////////////////////////////////////////////////////////////////////

    ///////Check whether a user with certain user name is in a certain group
    //string userName = "ashaN";
    //string groupName = "BOSS";
    //error e;
    //boolean x;
    //x,e = userAdminConnector.isUserInGroup(userName,groupName);
    //io:println(x);
    //io:println(e);
    ////////////////////////////////////////////////////////////////////////////////////////////

    ////////Delete an user from the user store
    //string userName = "donOmar";
    //error e;
    //string indicator;
    //indicator,e = userAdminConnector.deleteUserByUsername(userName);
    //io:println(indicator);
    //io:println(e);
    ////////////////////////////////////////////////////////////////////////////////////////////

    //////Delete a group
    //string groupName = "worker";
    //error e;
    //string indicator;
    //indicator,e = userAdminConnector.deleteGroupByName(groupName);
    //io:println(indicator);
    //io:println(e);
    ////////////////////////////////////////////////////////////////////////////////////////////

    ////////Get the list of users in the user store ////////////////////////////////////////////
    //scimclient:User[] userList;
    //error e;
    //userList,e = userAdminConnector.getListOfUsers();
    //io:println(userList);
    //io:println(e);
    ////////////////////////////////////////////////////////////////////////////////////////////

    //////////Get the list of groups /////////////////////////////////////////////////////////////
    //scimclient:Group[] groupList;
    //error e;
    //groupList,e = userAdminConnector.getListOfGroups();
    //io:println(groupList);
    //io:println(e);
    ////////////////////////////////////////////////////////////////////////////////////////////
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
package samples.wso2.scimclient;

import ballerina.net.http;
import ballerina.io;
import src.wso2.scimclient;

public function main(string[] args){
    endpoint<scimclient:ScimConnector> userAdminConnector {
        create scimclient:ScimConnector("YWRtaW46YWRtaW4=");
    }


    //Create a Group in the IS user store using createUser action=======================================================
    //error e;
    //scimclient:Group group = {};
    //group.displayName = "BOSS";
    //scimclient:Member mem = {};
    //mem.display = "dilhe";
    //mem.value = "06b92260-2238-40a3-9d31-0b2c47031047";
    //group.members = [mem];
    //e = userAdminConnector.createGroup(group);
    //io:println(e);
    //==================================================================================================================

    //Get a Group from the IS user store by it's name using getGroupByName aciton=======================================
    //scimclient:Group group = {};
    //error e;
    //group,e = userAdminConnector.getGroupByName("Leader2");
    //io:println(group);
    //io:println(e);
    //==================================================================================================================


    //create user=======================================================================================================
    //scimclient:User user = {};
    //scimclient:Email e1 = {};
    //scimclient:Email e2 = {};
    //scimclient:EnterpriseUserExtension en = {};
    //scimclient:Manager man = {};
    //man.displayName = "manager";
    //en.organization = "wso2";
    //en.manager = man;
    //user.EnterpriseUser = en;
    //user.userName = "siril";
    //user.password = "fdajfkds";
    //e1.value = "emai.com";
    //e1.|type| = "work";
    //e2.value = "mail.com";
    //e2.|type| = "home";
    //user.emails = [e1,e2];
    //error er;
    //er = userAdminConnector.createUser(user);
    //io:println(er);
    //==================================================================================================================

    //Get an user in the IS user store using getUserbyUserName action===================================================
    //scimclient:User user = {};
    //string userName = "dilh";
    //error e;
    //user,e =userAdminConnector.getUserByUsername(userName);
    //
    //io:println(user);
    //io:println(e);
    //==================================================================================================================

    //Add an existing user to a existing group==========================================================================
    // scimclient:Group group = {};
    // scimclient:User user = {};
    // string userName = "tnm";
    // string groupName = "Leader3";
    // error e;
    // group,e = userAdminConnector.addUserToGroup(userName, groupName);
    // io:println(e);
    // io:println(group.members);
    //==================================================================================================================

    //Remove an user from a given group=================================================================================
    //scimclient:Group group = {};
    //string userName = "tnm";
    //string groupName = "Leader3";
    //error e;
    //group,e = userAdminConnector.removeUserFromGroup(userName, groupName);
    //io:println(e);
    //io:println(group);
    //==================================================================================================================

    //Check whether a user with certain user name is in a certain group=================================================
    //string userName = "kim";
    //string groupName = "BOSS";
    //error e;
    //boolean x;
    //x,e = userAdminConnector.isUserInGroup(userName,groupName);
    //io:println(x);
    //io:println(e);
    //==================================================================================================================

    //Delete an user from the user store================================================================================
    //string userName = "siril";
    //error e;
    //e = userAdminConnector.deleteUserByUsername(userName);
    //io:println(e);
    //==================================================================================================================

    //Delete a group====================================================================================================
    //string groupName = "Leader";
    //error e;
    //e = userAdminConnector.deleteGroupByName(groupName);
    //io:println(e);
    //==================================================================================================================

    //Get the list of users in the user store===========================================================================
    //scimclient:User[] userList;
    //error e;
    //userList,e = userAdminConnector.getListOfUsers();
    //io:println(userList);
    //io:println(e);
    //==================================================================================================================

    //Get the list of groups============================================================================================
    //scimclient:Group[] groupList;
    //error e;
    //groupList,e = userAdminConnector.getListOfGroups();
    //io:println(groupList);
    //io:println(e);
    //==================================================================================================================


    //add user to group using struct bound function=====================================================================
    //scimclient:User user;
    //string userName = "tnm";
    //error e;
    //user , e = userAdminConnector.getUserByUsername(userName);
    //string groupName = "Leader3";
    //scimclient:Group group;
    //group , e = user.addToGroup(groupName);
    //io:println(group);
    //==================================================================================================================

    //remove an user from a group using strut bound function============================================================
    //scimclient:User user;
    //string userName = "tnm";
    //error e;
    //user , e = userAdminConnector.getUserByUsername(userName);
    //string groupName = "Leader3";
    //scimclient:Group group;
    //group , e = user.removeFromGroup(groupName);
    //io:println(group);
    //==================================================================================================================

    scimclient:User user;
    scimclient:Email email = {};
    email.value = "effdsdddddaf.com";
    email.|type| = "work";
    string userName = "siril";
    string sending = "ti";
    error e;
    user , e = userAdminConnector.getUserByUsername(userName);
    e = user.updateEmails([email]);
    io:println(e);
}



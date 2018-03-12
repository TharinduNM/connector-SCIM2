package samples.wso2.scimclient;


import ballerina.io;
import src.wso2.scimclient;

public function main(string[] args){
    endpoint<scimclient:ScimConnector> userAdminConnector {
        create scimclient:ScimConnector("YWRtaW46YWRtaW4=");
    }


    //Create a Group in the IS user store using createUser action=======================================================
    //error Error;
    //scimclient:Group group = {};
    //group.displayName = "BOSS";
    //scimclient:Member member = {};
    //member.display = "dilhe";
    //member.value = "06b92260-2238-40a3-9d31-0b2c47031047";
    //group.members = [member];
    //Error = userAdminConnector.createGroup(group);
    //io:println(Error);
    //==================================================================================================================

    //Get a Group from the IS user store by it's name using getGroupByName aciton=======================================
    //scimclient:Group group = {};
    //error Error;
    //group,Error = userAdminConnector.getGroupByName("Leader2");
    //io:println(group);
    //io:println(Error);
    //==================================================================================================================


    //create user=======================================================================================================
    //scimclient:User user = {};
    //scimclient:Email email1 = {};
    //scimclient:Email email2 = {};
    //scimclient:Address address = {};
    //scimclient:Name name = {};
    //scimclient:PhonePhotoIms phone = {};
    //
    //phone.|type| = "work";
    //phone.value = "08344444";
    //user.phoneNumbers = [phone];
    //
    //name.givenName = "given";
    //name.familyName = "family";
    //name.formatted = "given middle";
    //user.name = name;
    //
    //address.postalCode = "81000";
    //address.streetAddress = "Mahesha Makandura East";
    //address.region = "matara";
    //address.locality = "southern";
    //address.country = "sl";
    //address.formatted = "Mahesha/Makandura East/Matara";
    //address.primary = "true";
    //address.|type| = "work";
    //user.addresses = [address];
    //
    //user.userName = "sirilayya";
    //user.password = "fdajfkds";
    //
    //email1.value = "emai.com";
    //email1.|type| = "work";
    //email2.value = "mail.com";
    //email2.|type| = "home";
    //user.emails = [email1,email2];
    //
    //error Error;
    //Error = userAdminConnector.createUser(user);
    //io:println(Error);
    //==================================================================================================================

    //Get an user in the IS user store using getUserbyUserName action===================================================
    //scimclient:User user = {};
    //string userName = "dilh";
    //error Error;
    //user,Error =userAdminConnector.getUserByUsername(userName);
    //
    //io:println(user);
    //io:println(Error);
    //==================================================================================================================

    //Add an existing user to a existing group==========================================================================
    // scimclient:Group group = {};
    // scimclient:User user = {};
    // string userName = "tnm";
    // string groupName = "Leader3";
    // error Error;
    // group,Error = userAdminConnector.addUserToGroup(userName, groupName);
    // io:println(Error);
    // io:println(group.members);
    //==================================================================================================================

    //Remove an user from a given group=================================================================================
    //scimclient:Group group = {};
    //string userName = "tnm";
    //string groupName = "Leader3";
    //error Error;
    //group,Error = userAdminConnector.removeUserFromGroup(userName, groupName);
    //io:println(Error);
    //io:println(group);
    //==================================================================================================================

    //Check whether a user with certain user name is in a certain group=================================================
    //string userName = "kim";
    //string groupName = "BOSS";
    //error Error;
    //boolean x;
    //x,Error = userAdminConnector.isUserInGroup(userName,groupName);
    //io:println(x);
    //io:println(Error);
    //==================================================================================================================

    //Delete an user from the user store================================================================================
    //string userName = "siril";
    //error Error;
    //Error = userAdminConnector.deleteUserByUsername(userName);
    //io:println(Error);
    //==================================================================================================================

    //Delete a group====================================================================================================
    //string groupName = "Leader";
    //error Error;
    //Error = userAdminConnector.deleteGroupByName(groupName);
    //io:println(Error);
    //==================================================================================================================

    //Get the list of users in the user store===========================================================================
    //scimclient:User[] userList;
    //error Error;
    //userList,Error = userAdminConnector.getListOfUsers();
    //io:println(userList);
    //io:println(Error);
    //==================================================================================================================

    //Get the list of groups============================================================================================
    //scimclient:Group[] groupList;
    //error Error;
    //groupList,Error = userAdminConnector.getListOfGroups();
    //io:println(groupList);
    //io:println(Error);
    //==================================================================================================================


    //add user to group using struct bound function=====================================================================
    //scimclient:User user;
    //string userName = "tnm";
    //error Error;
    //user , Error = userAdminConnector.getUserByUsername(userName);
    //string groupName = "Leader3";
    //scimclient:Group group;
    //group , Error = user.addToGroup(groupName);
    //io:println(group);
    //==================================================================================================================

    //remove an user from a group using strut bound function============================================================
    //scimclient:User user;
    //string userName = "tnm";
    //error Error;
    //user , Error = userAdminConnector.getUserByUsername(userName);
    //string groupName = "Leader3";
    //scimclient:Group group;
    //group , Error = user.removeFromGroup(groupName);
    //io:println(group);
    //==================================================================================================================

    //scimclient:User user;
    //scimclient:Email email = {};
    //email.value = "effdsdddddaf.com";
    //email.|type| = "work";
    //string userName = "siril";
    //string sending = "ti";
    //error Error1;
    //error Error2;
    //user , Error1 = userAdminConnector.getUserByUsername(userName);
    //Error1 = user.updateNickname(sending);
    //Error2 = user.updateTitle("title");
    //io:println(Error1);
    //io:println(Error2);
}



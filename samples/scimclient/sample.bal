package samples.scimclient;


import ballerina.io;
import src.scimclient;

public function main (string[] args) {
    endpoint<scimclient:ScimConnector> userAdminConnector {
        create scimclient:ScimConnector("YWRtaW46YWRtaW4=");
    }


    //create user=======================================================================================================
    scimclient:User user = {};

    scimclient:PhonePhotoIms phone = {};
    phone.|type| = "work";
    phone.value = "0777777777";
    user.phoneNumbers = [phone];

    scimclient:Name name = {};
    name.givenName = "Leo";
    name.familyName = "Messi";
    name.formatted = "Lionel Messi";
    user.name = name;

    scimclient:Address address = {};
    address.postalCode = "23433";
    address.streetAddress = "no/2";
    address.region = "Catalunia";
    address.locality = "Barcelona";
    address.country = "Spain";
    address.formatted = "no/2,Barcelona/Catalunia/Spain";
    address.primary = "true";
    address.|type| = "work";

    user.addresses = [address];

    user.userName = "leoMessi";
    user.password = "greatest";

    scimclient:Email email1 = {};
    email1.value = "messi@barca.com";
    email1.|type| = "work";

    scimclient:Email email2 = {};
    email2.value = "messi@gg.com";
    email2.|type| = "home";

    user.emails = [email1, email2];

    error Error;
    Error = userAdminConnector.createUser(user);
    io:println("creating user " + user.userName);
    io:println(Error);
    //==================================================================================================================

    //Get an user in the IS user store using getUserbyUserName action===================================================
    scimclient:User getUser = {};
    string userName = "iniesta";
    getUser, Error = userAdminConnector.getUserByUsername(userName);

    io:println("");
    io:println("get user iniesta");
    io:println(getUser);
    io:print("error: ");
    io:println(Error);
    //==================================================================================================================

    //Create a Group in the IS user store using createUser action=======================================================
    scimclient:Group group = {};
    group.displayName = "Captain";

    scimclient:Member member = {};
    member.display = getUser.userName;
    member.value = getUser.id;
    group.members = [member];

    Error = userAdminConnector.createGroup(group);
    io:println("");
    io:println("create group Captain with iniesta in it");
    io:println(Error);
    //==================================================================================================================

    //Get a Group from the IS user store by it's name using getGroupByName aciton=======================================
    scimclient:Group getGroup = {};
    getGroup, Error = userAdminConnector.getGroupByName("Captain");

    io:println("");
    io:println("get the Captain of the team");
    io:println(getGroup);
    io:print("error: ");
    io:println(Error);
    //==================================================================================================================

    //Add an existing user to a existing group==========================================================================
    userName = "leoMessi";
    string groupName = "Captain";
    Error = userAdminConnector.addUserToGroup(userName, groupName);

    io:println("");
    io:println("Adding user leoMessi to group Captain");
    io:println(Error);

    getGroup, Error = userAdminConnector.getGroupByName("Captain");
    io:println("members in Captain");
    io:println(getGroup.members);
    //==================================================================================================================

    //Remove an user from a given group=================================================================================
    userName = "iniesta";
    groupName = "Captain";

    Error = userAdminConnector.removeUserFromGroup(userName, groupName);
    io:println("");
    io:println("Removing iniesta from Captain");
    io:println(Error);

    getGroup, Error = userAdminConnector.getGroupByName("Captain");
    io:println("members in Captain");
    io:println(getGroup.members);
    //==================================================================================================================

    //Check whether a user with certain user name is in a certain group=================================================
    userName = "leoMessi";
    groupName = "Captain";
    boolean x;
    x, Error = userAdminConnector.isUserInGroup(userName, groupName);
    io:println("");
    io:println("Check if leoMessi is the Captain");
    io:println(x);
    io:print("error: ");
    io:println(Error);
    //==================================================================================================================

    //Delete an user from the user store================================================================================
    userName = "leoMessi";
    Error = userAdminConnector.deleteUserByUsername(userName);
    io:println("");
    io:println("delete leoMessi");
    io:println(Error);
    //==================================================================================================================

    //Delete a group====================================================================================================
    groupName = "Captain";
    Error = userAdminConnector.deleteGroupByName(groupName);
    io:println("");
    io:println("deleting group Captain");
    io:println(Error);
    //==================================================================================================================

    //Get the list of users in the user store===========================================================================
    scimclient:User[] userList;
    userList, Error = userAdminConnector.getListOfUsers();
    io:println("");
    io:println("get the list of users");
    io:println(userList);
    io:print("error: ");
    io:println(Error);
    //==================================================================================================================

    //Get the list of groups============================================================================================
    scimclient:Group[] groupList;
    groupList, Error = userAdminConnector.getListOfGroups();
    io:println("");
    io:println("get the list of Groups");
    io:println(groupList);
    io:print("error: ");
    io:println(Error);
    //==================================================================================================================


    //add user to group using struct bound function=====================================================================
    //scimclient:User user;
    //string userName = "tnm";
    //error Error;
    //user , Error = userAdminConnector.getUserByUsername(userName);
    //string groupName = "Leader2";
    //scimclient:Group group;
    //group , Error = user.addToGroup(groupName);
    //io:println(group);
    ////================================================================================================================

    //remove an user from a group using strut bound function============================================================
    //scimclient:User user;
    //string userName = "tnm";
    //error Error;
    //user , Error = userAdminConnector.getUserByUsername(userName);
    //string groupName = "Leader2";
    //scimclient:Group group;
    //group , Error = user.removeFromGroup(groupName);
    //io:println(group);
    //==================================================================================================================

    //get the user that is currently authenticated======================================================================
    //scimclient:User user;
    //error Error;
    //user,Error = userAdminConnector.getMe();
    //io:println(user);
    //==================================================================================================================

    //scimclient:User user;
    ////scimclient:Email email = {};
    ////email.value = "effdsdddddaf.com";
    ////email.|type| = "work";
    //scimclient:Address address = {};
    //address.|type| = "work";
    //address.formatted = "heodddfd/fjds";
    //string userName = "ayya";
    //string sending = "ti";
    //error Error1;
    //error Error2;
    //user , Error1 = userAdminConnector.getUserByUsername(userName);
    ////Error1 = user.updateNickname(sending);
    //Error2 = user.updateAddresses([address]);
    ////io:println(Error1);
    //io:println(Error2);
}



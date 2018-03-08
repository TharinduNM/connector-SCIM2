package src.wso2.scimclient;

public struct Group{
    string displayName;
    string id;
    Member[] members;
}

public struct Member{
    string display;
    string value;
}

public struct User {
    string userName;
    string id;
    string password;
    Group[] groups;
    Name name;
    json details;
}

public struct Name{
    string formatted;
    string givenName;
    string familyName;
    string middleName;
    string honorificPrefix;
    string honorificSuffix;
}
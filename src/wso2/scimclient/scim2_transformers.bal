package src.wso2.scimclient;

transformer <json j, Group g> convertGroupInUser() {
    g.displayName = j.display.toString();
    g.id = j.value.toString();
}
transformer <json j, Group g> convertGroupInRemoveResponse() {
    g.displayName = j.displayName.toString();
    g.id = j.id.toString();
}
transformer <json j, Name n> convertName(){
    n.givenName = j.givenName != null ? j.givenName.toString() : "";
    n.familyName = j.familyName.toString();
    n.formatted = j.formatted != null ? j.formatted.toString() : "";
    n.middleName = j.middleName != null ? j.middleName.toString() : "";
    n.honorificPrefix = j.honorificPrefix != null ? j.honorificPrefix.toString() : "";
    n.honorificSuffix = j.honorificSuffix != null ? j.honorificSuffix.toString() : "";
}
transformer <Group g, json j> convertGroupToJson(){
    j.display = g.displayName;
    j.value = g.id;
}
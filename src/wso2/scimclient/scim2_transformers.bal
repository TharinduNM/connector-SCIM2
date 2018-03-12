//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

package src.wso2.scimclient;

//Here are all the transformers that transform required json to structs and vice versa

transformer <json j, Name n> convertJsonToName() {
    n.givenName = j.givenName != null ? j.givenName.toString() : "";
    n.familyName = j.familyName.toString();
    n.formatted = j.formatted != null ? j.formatted.toString() : "";
    n.honorificPrefix = j.honorificPrefix != null ? j.honorificPrefix.toString() : "";
    n.honorificSuffix = j.honorificSuffix != null ? j.honorificSuffix.toString() : "";
}

transformer <json j, User u> convertJsonToUser() {
    u.id = j.id.toString();
    u.userName = j.userName.toString();
    u.displayName = j.displayName != null ? j.displayName.toString() : "";
    u.name = j.name != null ? <Name, convertJsonToName()>j.name : {};
    u.active = j.active != null ? j.active.toString() : "";
    u.externalId = j.externalId != null ? j.externalId.toString() : "";
    u.nickName = j.nickName != null ? j.nickName.toString() : "";
    u.userType = j.userType != null ? j.userType.toString() : "";
    u.title = j.title != null ? j.title.toString() : "";
    u.timezone = j.timezone != null ? j.timezone.toString() : "";
    u.profileUrl = j.profileUrl != null ? j.profileUrl.toString() : "";
    u.preferredLanguage = j.preferredLanguage != null ? j.preferredLanguage.toString() : "";
    u.locale = j.locale != null ? j.locale.toString() : "";
    u.meta = <Meta, convertJsonToMeta()>j.meta;
    u.x509Certificates = j.x509Certificates != null ? j.x509Certificates.map(
                                                                        function (json j)(X509Certificate){
                                                                            return <X509Certificate, convertJsonToCertificate()>j;
                                                                        }) : [];
    u.schemas = j.schemas != null ? j.schemas.map(
                                             function (json j)(string){
                                                 return j.toString();
                                             }) : [];
    u.addresses =  j.addresses != null ? j.addresses.map(
                                                    function (json j)(Address){
                                                        return <Address, convertJsonToAddress()>j;
                                                    }) : [];
    u.phoneNumbers = j.phoneNumbers != null ? j.phoneNumbers.map(
                                                            function (json j)(PhonePhotoIms) {
                                                                return <PhonePhotoIms , convertJsonToPhoneNumbers()>j;
                                                            }) : [];
    u.photos = j.photos != null ? j.photos.map(
                                          function (json j)(PhonePhotoIms){
                                              return <PhonePhotoIms, convertJsonToPhoneNumbers()>j;
                                          }) : [];
    u.ims = j.ims != null ? j.ims.map(
                                 function (json j)(PhonePhotoIms){
                                     return <PhonePhotoIms, convertJsonToPhoneNumbers()>j;
                                 }) : [];
    u.emails = j.emails != null ? j.emails.map(
                                          function (json j)(Email){
                                              return <Email , convertJsonToEmail()>j;
                                          }) : [];
    u.groups = j.groups != null ? j.groups.map(
                                          function (json j)(Group){
                                              return <Group , convertJsonToGroupRelatedToUser()>j;
                                          }) : [];
    u.EnterpriseUser = j.EnterpriseUser != null ? <EnterpriseUserExtension, convertJsonToEnterpriseExtension()>j.EnterpriseUser : null;
}

transformer <json j, EnterpriseUserExtension e> convertJsonToEnterpriseExtension() {
    e.costCenter = j.costCenter != null ? j.costCenter.toString() : "";
    e.department = j.department != null ? j.department.toString() : "";
    e.division = j.division != null ? j.division.toString() : "";
    e.employeeNumber = j.employeeNumber != null ? j.employeeNumber.toString() : "";
    e.organization = j.organization != null ? j.organization.toString() : "";
    e.manager = j.manager != null ? <Manager,convertJsonToManager()>j.manager : {};
}

transformer <json j, Manager m> convertJsonToManager(){
    m.displayName = j.displayName != null ? j.displayName.toString() : "";
    m.managerId = j.managerId != null ? j.managerId.toString() : "";
}

transformer <json j, Address a> convertJsonToAddress() {
    a.streetAddress = j.streetAddress != null ? j.streetAddress.toString() : "";
    a.formatted = j.formatted != null ? j.formatted.toString() : "";
    a.country = j.country != null ? j.country.toString() : "";
    a.locality = j.locality != null ? j.locality.toString() : "";
    a.postalCode = j.postalCode != null ? j.postalCode.toString() : "";
    a.primary = j.primary != null ? j.primary.toString() : "false";
    a.region = j.region != null ? j.region.toString() : "";
    a.|type| = j.|type| != null ? j.|type|.toString() : "";
}

transformer <json j, Meta m> convertJsonToMeta() {
    m.location = j.location != null ? j.location.toString() : "";
    m.lastModified = j.lastModified != null ? j.lastModified.toString() : "";
    m.created = j.created != null ? j.created.toString() : "";
}

transformer <json j,PhonePhotoIms p> convertJsonToPhoneNumbers() {
    p.value = j.value.toString();
    p.|type| = j.|type|.toString();
}

transformer <json j,Email e> convertJsonToEmail() {
    e.|type| = j.|type| != null ? j.|type|.toString() : "";
    e.value = j.value != null ? j.value.toString() : "";
    e.primary = j.primary != null ? j.primary.toString() : "";
}

transformer <json j, Group g> convertJsonToGroupRelatedToUser() {
    g.displayName = j.display != null ? j.display.toString() : "";
    g.id = j.value != null ? j.value.toString() : "";
    g.members = j.members != null ? j.members.map(
                                             function(json j)(Member){
                                                 return <Member, convertJsonToMember()>j;
                                             }) : [];
    g.meta = j.meta != null ? <Meta, convertJsonToMeta()>j : {};
}

transformer <json j, Group g> convertJsonToGroup(){
    g.displayName = j.displayName != null ? j.displayName.toString() : "";
    g.id = j.id != null ? j.id.toString() : "";
    g.meta = <Meta, convertJsonToMeta()>j.meta;
    g.members = j.members != null ? j.members.map(
                                             function(json j)(Member){
                                                 return <Member, convertJsonToMember()>j;
                                             }) : [];
}

transformer <json j, Member m> convertJsonToMember() {
    m.value = j.value.toString();
    m.display = j.display.toString();
}

transformer <json j, X509Certificate x> convertJsonToCertificate(){
    x.value = j.value.toString();
}
//==========================================================================================================================================//
transformer <Group g, json j> convertGroupToJsonUserRelated() {
    j.display = g.displayName;
    j.value = g.id;
}

transformer <Group g, json j> convertGroupToJson() {
    j.displayName = g.displayName != null ? g.displayName : "";
    j.id = g.id != null ? g.id : "";
    json[] listMembers = g.members != null ? g.members.map(
                                            function(Member m)(json){
                                                return <json,convertMemberToJson()>m;
                                            }) : [];
    j.members = listMembers;
}

transformer <Member m, json j> convertMemberToJson(){
    j.value = m.value != null ? m.value : "";
    j.display = m.display != null ? m.display : "";
}

transformer <Name n, json j> convertNameToJson(){
    j.givenName = n.givenName;
    j.familyName = n.familyName;
    j.formatted = n.formatted;
    j.honorificPrefix = n.honorificPrefix;
    j.honorificSuffix = n.honorificSuffix;
}

transformer <Address a, json j> convertAddressToJson(){
    j.streetAddress = a.streetAddress;
    j.formatted = a.formatted;
    j.country = a.country;
    j.locality = a.locality;
    j.postalCode = a.postalCode;
    j.primary = a.primary;
    j.region = a.region;
    j.|type| = a.|type|;
}

transformer <Email e, json j> convertEmailToJson(){
    j.|type| = e.|type|;
    j.value = e.value;
    j.primary = e.primary;
}

transformer <PhonePhotoIms p, json j> convertPhonePhotoImsToJson(){
    j.value = p.value;
    j.|type| = p.|type|;
}

transformer <X509Certificate x, json j> convertCertificateToJson(){
    j.value = x.value;
}

transformer <EnterpriseUserExtension e, json j> convertEnterpriseExtensionToJson() {
    j.employeeNumber = e.employeeNumber != null ? e.employeeNumber : "";
    j.costCenter = e.costCenter != null ? e.costCenter : "";
    j.organization = e.organization != null ? e.organization : "";
    j.division = e.division != null ? e.division : "";
    j.department = e.department != null ? e.department : "";
    j.manager = e.manager != null ? <json, convertManagerToJson()>e.manager : {};
}

transformer <Manager m, json j> convertManagerToJson(){
    j.managerId = m.managerId != null ? m.managerId : "";
    j.displayName = m.displayName != null ? m.displayName : "";
}

transformer <User u, json j> convertUserToJson(){
    j.userName = u.userName;
    j.id = u.id;
    j.password = u.password;
    j.externalId = u.externalId;
    j.displayName = u.displayName;
    j.nickName = u.nickName;
    j.profileUrl = u.profileUrl;
    j.userType = u.userType;
    j.title = u.title;
    j.preferredLanguage = u.preferredLanguage;
    j.timezone = u.timezone;
    j.active = u.active;
    j.locale = u.locale;
    j.schemas = u.schemas != null ? u.schemas : [];
    j.name = u.name != null ? <json,convertNameToJson()>u.name : {};
    j.meta = {};
    json[] listCertificates = u.x509Certificates != null ? u.x509Certificates.map(
                                                                             function (X509Certificate x)(json){
                                                                                 return <json, convertCertificateToJson()>x;
                                                                             }) : [];
    j.x509Certificates = listCertificates;
    json[] listGroups = u.groups != null ? u.groups.map(
                                                   function (Group g)(json){
                                                       return <json , convertGroupToJsonUserRelated()>g;
                                                   }) : [];
    j.groups = listGroups;
    json[] listAddresses =  u.addresses != null ? u.addresses.map(
                                                             function (Address a)(json){
                                                                 return <json, convertAddressToJson()>a;
                                                             }) : [];
    j.addresses = listAddresses;
    json[] listEmails = u.emails != null ? u.emails.map(
                                                   function (Email e)(json){
                                                       return <json , convertEmailToJson()>e;
                                                   }) : [];
    j.emails = listEmails;
    json[] listNumbers = u.phoneNumbers != null ? u.phoneNumbers.map(
                                                                function (PhonePhotoIms p)(json) {
                                                                    return <json , convertPhonePhotoImsToJson()>p;
                                                                }) : [];
    j.phoneNumbers = listNumbers;
    json[] listIms = u.ims != null ? u.ims.map(
                                          function (PhonePhotoIms i)(json){
                                              return <json, convertPhonePhotoImsToJson()>i;
                                          }) : [];
    j.ims = listIms;
    json[] listPhotos = u.photos != null ? u.photos.map(
                                                   function (PhonePhotoIms p)(json){
                                                       return <json, convertPhonePhotoImsToJson()>p;
                                                   }) : [];
    j.photos = listPhotos;

    j.|urn:ietf:params:scim:schemas:extension:enterprise:2.0:User| = u.EnterpriseUser != null ? <json, convertEnterpriseExtensionToJson()>u.EnterpriseUser : {};
}
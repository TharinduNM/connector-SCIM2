# Ballerina SCIM Connector

*The system for Cross-domain Identity Management (SCIM) specification
 is designed to make managing user identities in cloud-based applications 
 and services easier.*

### Why do you need a SCIM 

Over the last decade, the world is moving more and more towards cloud based operational environments.
 The SCIM protocol is an application-level HTTP-based protocol for provisioning and managing 
 identity data on the web and in cross-domain environments such as 
enterprise-to-cloud service providers or inter-cloud scenarios.  The protocol provides RESTful 
APIs for easier creation, 
modification, retrieval, and discovery of core identity resources such as Users and Groups, 
as well as custom resources and resource extensions. 

### Why would you use a Ballerina connector for SCIM

Ballerina makes integration with data sources, services, or network-connect APIs much easier than
ever before. Ballerina can be used to easily integrate the SCIM REST API with other endpoints.

The SCIM connector enables you to access the SCIM REST API through Ballerina. The actions of the
SCIM connector are invoked using a Ballerina main function. 

WSO2 Identity Server uses SCIM for identity provisioning and therefore you can deploay the wso2 
Identity Server and use it to run the samples. 

The following sections provide you with information on how to use the Ballerina SCIM connector.

- [Getting started](#getting-started)
- [Running Samples](#running-samples)
- [Quick Testing](#quick-testing)
- [Working with SCIM connector actions](#working-with-SCIM-connector-actions)

## Getting started

1. Build Ballerina from the source by following steps given in 
 https://github.com/ballerina-lang/ballerina/blob/master/README.md.
2. Extract `ballerina-scim2-0.963.1.zip` and copy the `ballerina-scim2-0.963.1.jar` 
file into the `<ballerina-tools>/bre/lib` folder.



##### Prerequisites
1. Download and deploy the wso2 Identity Server by following the installation guide which can 
be found at 
https://docs.wso2.com/display/IS540/Installation+Guide/.
2. Follow the steps given in 
https://docs.wso2.com/display/ISCONNECTORS/Configuring+SCIM+2.0+Provisioning+Connector
to deploy the SCIM2 connector with WSO2 Identity Server. 
3. Identify the URI for the SCIM2 connector. 
(By default it should be `https://localhost:9443/scim2/`)

## Running Samples


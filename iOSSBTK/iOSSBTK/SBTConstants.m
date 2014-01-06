/*
 * © Copyright IBM Corp. 2013
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

//  This class is used to access library-wide constants

BOOL const IS_DEBUGGING_SBTK = YES;
NSString *BASICAUTH = @"basic";
NSString *OAUTH2 = @"oauth";


#pragma mark - IBMCredentialStore constants

NSString *IBM_CREDENTIAL_USERNAME = @"IBM_CREDENTIAL_USERNAME";
NSString *IBM_CREDENTIAL_PASSWORD = @"IBM_CREDENTIAL_PASSWORD";
NSString *IBM_CREDENTIAL_OAUTH2_TOKEN = @"IBM_CREDENTIAL_OAUTH2_TOKEN";
NSString *IBM_CREDENTIAL_OAUTH2_REFRESH_TOKEN = @"IBM_CREDENTIAL_OAUTH2_REFRESH_TOKEN";
NSString *IBM_CREDENTIAL_OAUTH2_EXPIRES_IN = @"IBM_CREDENTIAL_OAUTH2_EXPIRES_IN";

#pragma mark - OAuth2.0 paths

NSString *IBM_OAUTH_AUTHORIZATION_URL = @"oauth2/endpoint/connectionsProvider/authorize";
NSString *IBM_OAUTH_TOKEN_URL = @"oauth2/endpoint/connectionsProvider/token";

#pragma mark - keys for base urls
// Define a new one here if you want to enable a new endpoint
NSString *IBM_CREDENTIAL_CONNECTIONS_URL = @"IBM_CREDENTIAL_CONNECTIONS_URL";
NSString *IBM_CREDENTIAL_SMARTCLOUD_URL = @"IBM_CREDENTIAL_SMARTCLOUD_URL";
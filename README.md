# CloudKitStatus


Simple app that fetches Apple status information, currently configured to capture CloudKit information. Can be used to capture status for developer tools or user facing endpoints.

        case 0:
            systemStatusURL = "https://www.apple.com/support/systemstatus/data/developer/system_status_en_US.js" // This is the URL for developer features such as cloudkit, xCode Clouod, etc
        default:
            systemStatusURL = "https://www.apple.com/support/systemstatus/data/system_status_en_US.js" // this is the URL for system status for public facing sites suchas   Apple Books, App Store, Apple Music, etc

![image](https://user-images.githubusercontent.com/2520545/160118846-36be2d7d-9767-4b68-aa85-6ee537ce0bcd.png)

Author
Rob Evans, robert.evansii@gmail.com

License
CloudKitStatus is available under the MIT license. See the LICENSE file for more info.

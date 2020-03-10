# iOS - MTProtocol Framework

## Adding the framework to your app
1. Open your project in Xcode.
2. You can either drag an drop the `.framework` file inside your project navigator panel or use the "File > Add files to [Project name]" option in the menue bar.
3. Next go to your targets settings and add the framework under *General* tab and within the *Embedded Binaries* section. Make sure the framework is added to the *Linked Frameworks and Libraries* section as well!

## Using the framework to your app
Once the framework is added to your app add the following import statements to start using new functionality provided by the framework.
*Swift*: 
    `import MTProtocolFramework`
*Objective-C*:
    `#import <MTProtocolFramework/MTProtocolFramework.h>`

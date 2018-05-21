# Virgil Pythia Objective-C/Swift SDK

[![GitHub license](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](https://github.com/VirgilSecurity/virgil/blob/master/LICENSE)


[Introduction](#introduction) | [SDK Features](#sdk-features) | [Install and configure SDK](#install-and-configure-sdk) | [Usage Examples](#usage-examples) | [Docs](#docs) | [Support](#support)

## Introduction

<a href="https://developer.virgilsecurity.com/docs"><img width="230px" src="https://cdn.virgilsecurity.com/assets/images/github/logos/virgil-logo-red.png" align="left" hspace="10" vspace="6"></a>[Virgil Security](https://virgilsecurity.com) provides an SDK which allows you to communicate with Virgil Pythia Service and implement Pythia protocol in order to generate user's BrainKey. 
**BrainKey** is a user's Private Key which is based on user's password. BrainKey can be easily restored and is resistant to online and offline attacks.

## SDK Features
- communicate with Virgil Pythia Service
- generate user's BrainKey
- use [Virgil Crypto library][_virgil_crypto]

## Install and configure SDK

```swift
///Install SDK
```

## Usage Examples

### Generate BrainKey

```swift
///Specify your JWT provider
///Blind your password
///Make a transform request
///Generate and save BrainKey
///Create and publish user's Card
```

## Docs
Virgil Security has a powerful set of APIs, and the documentation below can get you started today.

* [Breach-Proof Password][_pythia_use_case] Use Case
* [The Pythia PRF Service](https://eprint.iacr.org/2015/644.pdf) - foundation principles of the protocol
* [Virgil Security Documenation][_documentation]

## License

This library is released under the [3-clause BSD License](LICENSE).

## Support
Our developer support team is here to help you. Find out more information on our [Help Center](https://help.virgilsecurity.com/).

You can find us on [Twitter](https://twitter.com/VirgilSecurity) or send us email support@VirgilSecurity.com.

Also, get extra help from our support team on [Slack](https://virgilsecurity.slack.com/join/shared_invite/enQtMjg4MDE4ODM3ODA4LTc2OWQwOTQ3YjNhNTQ0ZjJiZDc2NjkzYjYxNTI0YzhmNTY2ZDliMGJjYWQ5YmZiOGU5ZWEzNmJiMWZhYWVmYTM).

[_virgil_crypto]: https://github.com/VirgilSecurity/virgil-crypto
[_pythia_use_case]: https://developer.virgilsecurity.com/docs/cs/use-cases/v5/breach-proof-password
[_documentation]: https://developer.virgilsecurity.com/
[_dashboard]: https://dashboard.virgilsecurity.com/


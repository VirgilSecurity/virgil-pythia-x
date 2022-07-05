//
// Copyright (C) 2015-2021 Virgil Security Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     (1) Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//
//     (2) Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in
//     the documentation and/or other materials provided with the
//     distribution.
//
//     (3) Neither the name of the copyright holder nor the names of its
//     contributors may be used to endorse or promote products derived from
//     this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>
//

import Foundation
import XCTest
import VirgilSDKPythia
import VirgilSDK
import VirgilCrypto

class VSY001_BrainKeyTests: XCTestCase {
    let config = TestConfig.readFromBundle()
    
    func test001_RealClient() {
        let crypto = try! VirgilCrypto()
        let apiKey = try! crypto.importPrivateKey(from: Data(base64Encoded: self.config.ApiPrivateKey)!).privateKey
        
        let generator = try! JwtGenerator(apiKey: apiKey,
                                          apiPublicKeyIdentifier: self.config.ApiKeyId,
                                          crypto: crypto,
                                          appId: self.config.AppId,
                                          ttl: 3600)
        let identity = UUID().uuidString
        let provider = GeneratorJwtProvider(jwtGenerator: generator, defaultIdentity: identity)
        
        let client = PythiaClient(accessTokenProvider: provider, serviceUrl: URL(string: self.config.ServiceURL)!)
        
        let brainKeyContext = try! BrainKeyContext.init(client: client, pythiaCrypto: PythiaCrypto(crypto: crypto))
        let brainKey = BrainKey(context: brainKeyContext)
        
        let keyPair1 = try! brainKey.generateKeyPair(password: "some password").startSync().get()
        sleep(5)
        let keyPair2 = try! brainKey.generateKeyPair(password: "some password").startSync().get()
        sleep(5)
        let keyPair3 = try! brainKey.generateKeyPair(password: "another password").startSync().get()
        sleep(5)
        let keyPair4 = try! brainKey.generateKeyPair(password: "some password", brainKeyId: "my password 1").startSync().get()
        
        XCTAssert(keyPair1.publicKey.identifier == keyPair2.publicKey.identifier)
        XCTAssert(keyPair1.publicKey.identifier != keyPair3.publicKey.identifier)
        XCTAssert(keyPair1.publicKey.identifier != keyPair4.publicKey.identifier)
    }
}

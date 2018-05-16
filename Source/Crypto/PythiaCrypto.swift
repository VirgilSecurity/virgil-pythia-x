//
// Copyright (C) 2015-2018 Virgil Security Inc.
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
import VirgilCryptoApiImpl
import VirgilCrypto

@objc(VSYPythiaCrypto) open class PythiaCrypto: NSObject, PythiaCryptoProtocol {
    @objc public let virgilPythia = VirgilPythia()
    @objc public let virgilCrypto = VirgilCrypto()
    
    @objc open func blind(password: String) throws -> BlindResult {
        guard let passwordData = password.data(using: .utf8) else {
            throw NSError() // FIXME
        }
        
        let blindResult = try self.virgilPythia.blind(password: passwordData)
        
        return BlindResult(blindedPassword: blindResult.blindedPassword, blindingSecret: blindResult.blindingSecret)
    }
    
    @objc open func deblind(transformedPassword: Data, blindingSecret: Data) throws -> Data {
        return try self.virgilPythia.deblind(transformedPassword: transformedPassword, blindingSecret: blindingSecret)
    }
    
    @objc open func generateKeyPair(ofType type: VSCKeyType, fromSeed seed: Data) throws -> VirgilKeyPair {
        guard let keyPair = KeyPair(keyPairType: type, keyMaterial: seed, password: nil) else {
            throw NSError() // FIXME
        }

        return try self.virgilCrypto.wrapKeyPair(privateKey: keyPair.privateKey(), publicKey: keyPair.publicKey())
    }
}

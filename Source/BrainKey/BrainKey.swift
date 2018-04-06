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
import VirgilSDK
import VirgilCryptoApiImpl

public protocol BrainKeyProtocol: class {
    
}

@objc(VSYBrainKey) open class BrainKey: NSObject, BrainKeyProtocol {
    @objc public static let defaultBrainKeyId = "DEFAULT_ID"
    
    @objc let client: PythiaClientProtocol
    @objc let pythiaCrypto: PythiaCryptoProtocol
    @objc let accessTokenProvider: AccessTokenProvider
    
    init(client: PythiaClientProtocol, pythiaCrypto: PythiaCryptoProtocol, accessTokenProvider: AccessTokenProvider) {
        self.client = client
        self.pythiaCrypto = pythiaCrypto
        self.accessTokenProvider = accessTokenProvider
        
        super.init()
    }
    
    open func generatePrivateKey(password: String, brainKeyId: String = BrainKey.defaultBrainKeyId, token: String) -> GenericOperation<VirgilPrivateKey> {
        return CallbackOperation { _, completion in
            let blindedPassword: Data
            do {
                blindedPassword = try self.pythiaCrypto.blind(password: password)
            }
            catch {
                completion(nil, error)
                return
            }
            
            // TODO: Update TokenContext
            let tokenContext = TokenContext(operation: "get", forceReload: false)
            let getTokenOperation = OperationsUtils.makeGetTokenOperation(tokenContext: tokenContext, accessTokenProvider: self.accessTokenProvider)
            let seedOperation = self.makeSeedOperation(blindedPassword: blindedPassword, brainKeyId: brainKeyId)
            let generateKeyOperation = self.makeGenerateKeyOperation()
            
            let completionOperation = OperationsUtils.makeCompletionOperation(completion: completion)
            
            seedOperation.addDependency(getTokenOperation)
            
            generateKeyOperation.addDependency(seedOperation)
            
            completionOperation.addDependency(getTokenOperation)
            completionOperation.addDependency(seedOperation)
            completionOperation.addDependency(generateKeyOperation)
            
            let queue = OperationQueue()
            let operations = [getTokenOperation, seedOperation, generateKeyOperation, completionOperation]
            queue.addOperations(operations, waitUntilFinished: false)
        }
    }
}

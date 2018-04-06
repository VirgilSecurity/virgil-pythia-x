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

public protocol PythiaAuthProtocol: class {
    func authenticate(password: String, salt: Data, transformedPassword: Data, version: String, proof: Bool) -> GenericOperation<Bool>
    func register(password: String, version: String) -> CallbackOperation<PythiaAuthUserInfo>
}

@objc(VSYPythiaAuth) open class PythiaAuth: NSObject, PythiaAuthProtocol {
    @objc let client: PythiaClientProtocol
    @objc let pythiaCrypto: PythiaCryptoProtocol
    @objc let accessTokenProvider: AccessTokenProvider
    
    init(client: PythiaClientProtocol, pythiaCrypto: PythiaCryptoProtocol, accessTokenProvider: AccessTokenProvider) {
        self.client = client
        self.pythiaCrypto = pythiaCrypto
        self.accessTokenProvider = accessTokenProvider
        
        super.init()
    }
    
    open func rotatePassword() {
        // TODO: Implement
    }
    
    open func register(password: String, version: String) -> CallbackOperation<PythiaAuthUserInfo> {
        return CallbackOperation { _, completion in
            let salt: Data
            let blindedPassword: Data
            do {
                salt = try self.pythiaCrypto.generateSalt()
                blindedPassword = try self.pythiaCrypto.blind(password: password)
            }
            catch {
                completion(nil, error)
                return
            }
            
            // TODO: Update TokenContext
            let tokenContext = TokenContext(operation: "get", forceReload: false)
            let getTokenOperation = OperationsUtils.makeGetTokenOperation(tokenContext: tokenContext, accessTokenProvider: self.accessTokenProvider)
            let transformOperation = self.makeTransformOperation(blindedPassword: blindedPassword, salt: salt, version: version, proof: true)
            let proofOperation = self.makeProofOperation(blindedPassword: blindedPassword, salt: salt, transformationPublicKey: Data()) // FIXME: transformationPublicKey
            let finishRegistrationOperation = CallbackOperation<PythiaAuthUserInfo> { operation, completion in
                do {
                    let transformResponse: TransformResponse = try operation.findDependencyResult()
                    
                    let registrationResponse = PythiaAuthUserInfo(salt: salt, transformedPassword: transformResponse.transformedPassword, version: version) // FIXME: transformationPublicKey
                    completion(registrationResponse, nil)
                }
                catch {
                    completion(nil, error)
                }
            }
            
            let completionOperation = OperationsUtils.makeCompletionOperation(completion: completion)
            
            transformOperation.addDependency(getTokenOperation)
            
            proofOperation.addDependency(transformOperation)
            finishRegistrationOperation.addDependency(transformOperation)
            
            completionOperation.addDependency(getTokenOperation)
            completionOperation.addDependency(transformOperation)
            completionOperation.addDependency(proofOperation)
            completionOperation.addDependency(finishRegistrationOperation)
            
            let queue = OperationQueue()
            let operations = [getTokenOperation, transformOperation, proofOperation, finishRegistrationOperation, completionOperation]
            queue.addOperations(operations, waitUntilFinished: false)
        }
    }
    
    open func authenticate(password: String, salt: Data, transformedPassword: Data, version: String, proof: Bool) -> GenericOperation<Bool> {
        return CallbackOperation { _, completion in
            // TODO: Update TokenContext
            let tokenContext = TokenContext(operation: "get", forceReload: false)
            let getTokenOperation = OperationsUtils.makeGetTokenOperation(tokenContext: tokenContext, accessTokenProvider: self.accessTokenProvider)
            
            let blindedPassword: Data
            do {
                blindedPassword = try self.pythiaCrypto.blind(password: password)
            }
            catch {
                completion(nil, error)
                return
            }
            
            let transformPasswordOperation = self.makeTransformOperation(blindedPassword: blindedPassword, salt: salt, version: version, proof: proof)
            
            let proofOperation: GenericOperation<Bool>
            if proof {
                proofOperation = self.makeProofOperation(blindedPassword: blindedPassword, salt: salt, transformationPublicKey: Data()) // FIXME: transformationPublicKey
            }
            else {
                proofOperation = CallbackOperation { _, completion in
                    completion(true, nil)
                }
            }
            
            let authOperation = CallbackOperation<Bool> { operation, completion in
                do {
                    let transformResponse: TransformResponse = try operation.findDependencyResult()
                    
                    guard transformResponse.transformedPassword == transformedPassword else {
                        completion(false, nil)
                        return
                    }
                    
                    completion(true, nil)
                }
                catch {
                    completion(nil, error)
                }
            }
            
            let completionOperation = CallbackOperation { _, completion in
                completion(Void(), nil)
            }
            
            completionOperation.completionBlock = {
                guard let proofResult = proofOperation.result,
                    let authResult = authOperation.result,
                    case let .success(proof) = proofResult, proof,
                    case let .success(auth) = authResult, auth else {
                        completion(false, nil)
                        return
                }
                
                completion(true, nil)
            }
            
            transformPasswordOperation.addDependency(getTokenOperation)
            
            authOperation.addDependency(transformPasswordOperation)
            proofOperation.addDependency(transformPasswordOperation)
            
            completionOperation.addDependency(getTokenOperation)
            completionOperation.addDependency(transformPasswordOperation)
            completionOperation.addDependency(proofOperation)
            completionOperation.addDependency(authOperation)
            
            let queue = OperationQueue()
            let operations = [getTokenOperation, transformPasswordOperation, authOperation, completionOperation]
            queue.addOperations(operations, waitUntilFinished: false)
        }
    }
}

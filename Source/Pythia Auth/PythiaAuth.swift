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
    func authenticate(password: String, pythiaUser: PythiaUser, proof: Bool) -> GenericOperation<Bool>
    func register(password: String) -> GenericOperation<PythiaUser>
    func rotateSecret(newVersion: Int, updateToken: String, pythiaUser: PythiaUser) throws -> PythiaUser
    func changePassword(for pythiaUser: PythiaUser, newPassword: String) -> GenericOperation<PythiaUser>
}

open class PythiaAuth: NSObject, PythiaAuthProtocol {
    let config: PythiaConfig
    let client: PythiaClientProtocol
    let pythiaCrypto: PythiaCryptoProtocol
    let accessTokenProvider: AccessTokenProvider
    
    init(config: PythiaConfig, client: PythiaClientProtocol, pythiaCrypto: PythiaCryptoProtocol, accessTokenProvider: AccessTokenProvider) {
        self.config = config
        self.client = client
        self.pythiaCrypto = pythiaCrypto
        self.accessTokenProvider = accessTokenProvider
        
        super.init()
    }
    
    open func changePassword(for pythiaUser: PythiaUser, newPassword: String) -> GenericOperation<PythiaUser> {
        return CallbackOperation { _, completion in
            let salt: Data
            let blindedPassword: Data
            let blindingSecret: Data
            do {
                let blinded = try self.pythiaCrypto.blind(password: newPassword)
                blindedPassword = blinded.0
                blindingSecret = blinded.1
                
                salt = try self.pythiaCrypto.generateSalt()
            }
            catch {
                completion(nil, error)
                return
            }
            
            // TODO: Update TokenContext
            let tokenContext = TokenContext(operation: "get", forceReload: false)
            let getTokenOperation = OperationsUtils.makeGetTokenOperation(tokenContext: tokenContext, accessTokenProvider: self.accessTokenProvider)
            let latestTransformationPublicKey = self.config.transformationPublicKey
            let transformOperation = self.makeTransformOperation(blindedPassword: blindedPassword, salt: salt, version: latestTransformationPublicKey.0, proof: true)
            let verifyOperation = self.makeVerifyOperation(blindedPassword: blindedPassword, salt: salt, transformationPublicKey: latestTransformationPublicKey.1)
            let finishRegistrationOperation = CallbackOperation<PythiaUser> { operation, completion in
                do {
                    let transformResponse: TransformResponse = try operation.findDependencyResult()
                    
                    let deblindedPassword = try self.pythiaCrypto.deblind(transformedPassword: transformResponse.transformedPassword, blindingSecret: blindingSecret)
                    
                    let registrationResponse = PythiaUser(salt: salt, deblindedPassword: deblindedPassword, version: latestTransformationPublicKey.0)
                    
                    completion(registrationResponse, nil)
                }
                catch {
                    completion(nil, error)
                }
            }
            
            let completionOperation = OperationsUtils.makeCompletionOperation(completion: completion)
            
            transformOperation.addDependency(getTokenOperation)
            
            verifyOperation.addDependency(transformOperation)
            finishRegistrationOperation.addDependency(transformOperation)
            
            completionOperation.addDependency(getTokenOperation)
            completionOperation.addDependency(transformOperation)
            completionOperation.addDependency(verifyOperation)
            completionOperation.addDependency(finishRegistrationOperation)
            
            let queue = OperationQueue()
            let operations = [getTokenOperation, transformOperation, verifyOperation, finishRegistrationOperation, completionOperation]
            queue.addOperations(operations, waitUntilFinished: false)
        }
    }
    
    open func rotateSecret(newVersion: Int, updateToken: String, pythiaUser: PythiaUser) throws -> PythiaUser {
        let updateTokenData = Data(base64Encoded: updateToken)!
        let newDeblindedPassword = try self.pythiaCrypto.updateDeblindedWithToken(deblindedPassword: pythiaUser.deblindedPassword, updateToken: updateTokenData)
                
        return PythiaUser(salt: pythiaUser.salt, deblindedPassword: newDeblindedPassword, version: newVersion)
    }
    
    open func register(password: String) -> GenericOperation<PythiaUser> {
        return CallbackOperation { _, completion in
            let salt: Data
            let blindedPassword: Data
            let blindingSecret: Data
            do {
                salt = try self.pythiaCrypto.generateSalt()
                let blinded = try self.pythiaCrypto.blind(password: password)
                blindedPassword = blinded.0
                blindingSecret = blinded.1
            }
            catch {
                completion(nil, error)
                return
            }
            
            // TODO: Update TokenContext
            let tokenContext = TokenContext(operation: "get", forceReload: false)
            let getTokenOperation = OperationsUtils.makeGetTokenOperation(tokenContext: tokenContext, accessTokenProvider: self.accessTokenProvider)
            let latestTransformationPublicKey = self.config.transformationPublicKey
            let transformOperation = self.makeTransformOperation(blindedPassword: blindedPassword, salt: salt, version: latestTransformationPublicKey.0, proof: true)
            let verifyOperation = self.makeVerifyOperation(blindedPassword: blindedPassword, salt: salt, transformationPublicKey: latestTransformationPublicKey.1)
            let finishRegistrationOperation = CallbackOperation<PythiaUser> { operation, completion in
                do {
                    let transformResponse: TransformResponse = try operation.findDependencyResult()
                    
                    let deblindedPassword = try self.pythiaCrypto.deblind(transformedPassword: transformResponse.transformedPassword, blindingSecret: blindingSecret)
                    
                    let registrationResponse = PythiaUser(salt: salt, deblindedPassword: deblindedPassword, version: latestTransformationPublicKey.0)
                    
                    completion(registrationResponse, nil)
                }
                catch {
                    completion(nil, error)
                }
            }
            
            let completionOperation = OperationsUtils.makeCompletionOperation(completion: completion)
            
            transformOperation.addDependency(getTokenOperation)
            
            verifyOperation.addDependency(transformOperation)
            finishRegistrationOperation.addDependency(transformOperation)
            
            completionOperation.addDependency(getTokenOperation)
            completionOperation.addDependency(transformOperation)
            completionOperation.addDependency(verifyOperation)
            completionOperation.addDependency(finishRegistrationOperation)
            
            let queue = OperationQueue()
            let operations = [getTokenOperation, transformOperation, verifyOperation, finishRegistrationOperation, completionOperation]
            queue.addOperations(operations, waitUntilFinished: false)
        }
    }
    
    open func authenticate(password: String, pythiaUser: PythiaUser, proof: Bool) -> GenericOperation<Bool> {
        return CallbackOperation { _, completion in
            // TODO: Update TokenContext
            let tokenContext = TokenContext(operation: "get", forceReload: false)
            let getTokenOperation = OperationsUtils.makeGetTokenOperation(tokenContext: tokenContext, accessTokenProvider: self.accessTokenProvider)
            
            let blindedPassword: Data
            let blindingSecret: Data
            let transformationPublicKey: Data
            do {
                let blinded = try self.pythiaCrypto.blind(password: password)
                blindedPassword = blinded.0
                blindingSecret = blinded.1
                
                transformationPublicKey = try self.config.transformationPublicKey(forVersion: pythiaUser.version)
            }
            catch {
                completion(nil, error)
                return
            }
            
            let transformPasswordOperation = self.makeTransformOperation(blindedPassword: blindedPassword, salt: pythiaUser.salt, version: pythiaUser.version, proof: proof)
            
            let verifyOperation: GenericOperation<Bool>
            if proof {
                verifyOperation = self.makeVerifyOperation(blindedPassword: blindedPassword, salt: pythiaUser.salt, transformationPublicKey: transformationPublicKey)
            }
            else {
                verifyOperation = CallbackOperation { _, completion in
                    completion(true, nil)
                }
            }
            
            let authOperation = CallbackOperation<Bool> { operation, completion in
                do {
                    let transformResponse: TransformResponse = try operation.findDependencyResult()
                    
                    let deblindedPassowrd = try self.pythiaCrypto.deblind(transformedPassword: transformResponse.transformedPassword, blindingSecret: blindingSecret)
                    
                    guard deblindedPassowrd == pythiaUser.deblindedPassword else {
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
                guard let proofResult = verifyOperation.result,
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
            verifyOperation.addDependency(transformPasswordOperation)
            
            completionOperation.addDependency(getTokenOperation)
            completionOperation.addDependency(transformPasswordOperation)
            completionOperation.addDependency(verifyOperation)
            completionOperation.addDependency(authOperation)
            
            let queue = OperationQueue()
            let operations = [getTokenOperation, transformPasswordOperation, verifyOperation, authOperation, completionOperation]
            queue.addOperations(operations, waitUntilFinished: false)
        }
    }
}

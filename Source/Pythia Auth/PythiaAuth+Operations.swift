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

extension PythiaAuth {
    func makeTransformOperation(blindedPassword: Data, salt: Data, version: Int, proof: Bool) -> GenericOperation<TransformResponse> {
        return CallbackOperation { operation, completion in
            do {
                let token: AccessToken = try operation.findDependencyResult()
                
                let transformResponse = try self.client.transformPassword(salt: salt, blindedPassword: blindedPassword, version: version, includeProof: proof, token: token.stringRepresentation())
                
                completion(transformResponse, nil)
            }
            catch {
                completion(nil, error)
            }
        }
    }
    
    func makeVerifyOperation(blindedPassword: Data, salt: Data, transformationPublicKey: Data) -> GenericOperation<Bool> {
        return CallbackOperation { operation, completion in
            let transformResponse: TransformResponse
            do {
                transformResponse = try operation.findDependencyResult()
            }
            catch {
                completion(nil, error)
                return
            }
            
            guard let proof = transformResponse.proof else {
                completion(false, nil)
                return
            }
            
            let verified = self.pythiaCrypto.verify(transformedPassword: transformResponse.transformedPassword,
                                                    blindedPassword: blindedPassword, tweak: salt,
                                                    transofrmationPublicKey: transformationPublicKey, proofC: proof.c, proofU: proof.u)
            
            guard verified else {
                completion(false, nil)
                return
            }
            
            completion(true, nil)
        }
    }
}

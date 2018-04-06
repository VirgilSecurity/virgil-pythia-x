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

extension PythiaClient: PythiaClientProtocol {
    @objc public static let xVirgilIncludeProofTrue = "true"
    
    @objc public func seed(blindedPassword: Data, brainKeyId: String, token: String) throws -> Data {
        guard let url = URL(string: "pythia/v1/seed", relativeTo: self.serviceUrl) else {
            throw PythiaClientError.constructingUrl
        }
        
        let params = [
            "blinded_password": blindedPassword.base64EncodedString(),
            "brain_key_id": brainKeyId
        ]
        
        let request = try ServiceRequest(url: url, method: .post, accessToken: token, params: params)
        
        let response = try self.connection.send(request)
        
        let seedResponse: SeedResponse = try self.processResponse(response)
        
        return seedResponse.seed
    }
    
    @objc public func transformPassword(salt: Data, blindedPassword: Data, version: String? = nil, includeProof: Bool = false, token: String) throws -> TransformResponse {
        guard let url = URL(string: "pythia/v1/password", relativeTo: self.serviceUrl) else {
            throw PythiaClientError.constructingUrl
        }
        
        var params = [
            "salt": salt.base64EncodedString(),
            "blinded_password": blindedPassword.base64EncodedString()
        ]
        
        if let version = version {
            params["version"] = version
        }
        
        if includeProof {
            params["include_proof"] = PythiaClient.xVirgilIncludeProofTrue
        }
        
        let request = try ServiceRequest(url: url, method: .post, accessToken: token, params: params)
        
        let response = try self.connection.send(request)
        
        return try self.processResponse(response)
    }
    
    @objc public func rotatePassword(token: String) throws -> RotateResponse {
        guard let url = URL(string: "pythia/v1/password/actions/rotate", relativeTo: self.serviceUrl) else {
            throw PythiaClientError.constructingUrl
        }
        
        let request = try ServiceRequest(url: url, method: .post, accessToken: token)
        
        let response = try self.connection.send(request)
        
        return try self.processResponse(response)
    }
}

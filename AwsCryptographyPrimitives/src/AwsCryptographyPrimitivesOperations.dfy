// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../Model/AwsCryptographyPrimitivesTypes.dfy"
include "Random.dfy"
include "WrappedHMAC.dfy"
include "WrappedHKDF.dfy"
include "./KDF/KdfCtr.dfy"
include "AESEncryption.dfy"
include "Digest.dfy"
include "RSAEncryption.dfy"
include "Signature.dfy"
include "AesKdfCtr.dfy"
include "ECDH.dfy"

module AwsCryptographyPrimitivesOperations refines AbstractAwsCryptographyPrimitivesOperations {
  import Random
  import AESEncryption
  import D = Digest
  import WrappedHMAC
  import WrappedHKDF
  import Signature
  import KdfCtr
  import RSAEncryption
  import ECDH

  datatype Config = Config
  type InternalConfig = Config
  predicate ValidInternalConfig?(config: InternalConfig)
  {true}
  function ModifiesInternalConfig(config: InternalConfig) : set<object>
  {{}}

  predicate GenerateRandomBytesEnsuresPublicly(input: GenerateRandomBytesInput, output: Result<seq<uint8>, Error>)
  {
    output.Success? ==> |output.value| == input.length as int
  }

  method GenerateRandomBytes ( config: InternalConfig,  input: GenerateRandomBytesInput )
    returns (output: Result<seq<uint8>, Error>)
  {
    output := Random.GenerateBytes(input.length);
  }

  predicate DigestEnsuresPublicly(input: DigestInput, output: Result<seq<uint8>, Error>)
  {
    output.Success? ==> |output.value| == D.Length(input.digestAlgorithm) as nat
  }

  method Digest ( config: InternalConfig,  input: DigestInput )
    returns (output: Result<seq<uint8>, Error>)
  {
    output := D.Digest(input);
  }

  predicate HMacEnsuresPublicly(input: HMacInput, output: Result<seq<uint8>, Error>)
  {true}

  function method HMac ( config: InternalConfig,  input: HMacInput )
    : (output: Result<seq<uint8>, Error>)
  {
    WrappedHMAC.Digest(input)
  }

  predicate HkdfExtractEnsuresPublicly(input: HkdfExtractInput, output: Result<seq<uint8>, Error>)
  {true}

  method HkdfExtract ( config: InternalConfig,  input: HkdfExtractInput )
    returns (output: Result<seq<uint8>, Error>)
  {
    output := WrappedHKDF.Extract(input);
  }

  predicate HkdfExpandEnsuresPublicly(input: HkdfExpandInput, output: Result<seq<uint8>, Error>)
  {
    output.Success?
    ==>
      && |output.value| == input.expectedLength as nat
  }

  method HkdfExpand ( config: InternalConfig,  input: HkdfExpandInput )
    returns (output: Result<seq<uint8>, Error>)
  {
    output := WrappedHKDF.Expand(input);
  }

  predicate HkdfEnsuresPublicly(input: HkdfInput, output: Result<seq<uint8>, Error>)
  {
    output.Success?
    ==>
      && |output.value| == input.expectedLength as nat
  }

  method Hkdf ( config: InternalConfig,  input: HkdfInput )
    returns (output: Result<seq<uint8>, Error>)
  {
    output := WrappedHKDF.Hkdf(input);
  }

  predicate KdfCounterModeEnsuresPublicly(input: KdfCtrInput, output: Result<seq<uint8>, Error>)
  {
    output.Success?
    ==>
      && |output.value| == input.expectedLength as nat
  }

  method KdfCounterMode(config: InternalConfig, input: KdfCtrInput)
    returns (output: Result<seq<uint8>, Error>)
  {
    output := KdfCtr.KdfCounterMode(input);
  }

  predicate AesKdfCounterModeEnsuresPublicly(input: AesKdfCtrInput, output: Result<seq<uint8>, Error>)
  {
    output.Success?
    ==>
      && |output.value| == input.expectedLength as nat
  }

  method AesKdfCounterMode(config: InternalConfig, input: AesKdfCtrInput)
    returns (output: Result<seq<uint8>, Error>)
  {
    output := Failure(Types.AwsCryptographicPrimitivesError(message := "Implement"));
  }

  predicate AESEncryptEnsuresPublicly(input: AESEncryptInput, output: Result<AESEncryptOutput, Error>)
  {
    && output.Success?
    ==>
      && |output.value.cipherText| == |input.msg|
      && |output.value.authTag| == input.encAlg.tagLength as nat
  }

  method AESEncrypt ( config: InternalConfig,  input: AESEncryptInput )
    returns (output: Result<AESEncryptOutput, Error>)
  {
    output := AESEncryption.AESEncrypt(input);
  }

  predicate AESDecryptEnsuresPublicly(input: AESDecryptInput, output: Result<seq<uint8>, Error>)
  {
    && output.Success?
    ==>
      && |output.value| == |input.cipherTxt|
  }

  method AESDecrypt ( config: InternalConfig,  input: AESDecryptInput )
    returns (output: Result<seq<uint8>, Error>)
  {
    output := AESEncryption.AESDecrypt(input);
  }

  predicate GenerateRSAKeyPairEnsuresPublicly(input: GenerateRSAKeyPairInput, output: Result<GenerateRSAKeyPairOutput, Error>)
  {true}

  method GenerateRSAKeyPair ( config: InternalConfig,  input: GenerateRSAKeyPairInput )
    returns (output: Result<GenerateRSAKeyPairOutput, Error>)
  {
    var publicKey, privateKey := RSAEncryption.GenerateKeyPair(input.lengthBits);
    output := Success(GenerateRSAKeyPairOutput(publicKey := publicKey, privateKey := privateKey));
  }

  predicate GetRSAKeyModulusLengthEnsuresPublicly(input: GetRSAKeyModulusLengthInput, output: Result<GetRSAKeyModulusLengthOutput, Error>)
  {true}

  function method GetRSAKeyModulusLength ( config: InternalConfig,  input: GetRSAKeyModulusLengthInput )
    : (output: Result<GetRSAKeyModulusLengthOutput, Error>)
  {
    var length :- RSAEncryption.GetRSAKeyModulusLength(input.publicKey);
    Success(GetRSAKeyModulusLengthOutput(length := length))
  }

  predicate RSADecryptEnsuresPublicly(input: RSADecryptInput, output: Result<seq<uint8>, Error>)
  {true}

  method RSADecrypt ( config: InternalConfig,  input: RSADecryptInput )
    returns (output: Result<seq<uint8>, Error>)
  {
    output := RSAEncryption.Decrypt(input);
  }

  predicate RSAEncryptEnsuresPublicly(input: RSAEncryptInput, output: Result<seq<uint8>, Error>)
  {true}

  method RSAEncrypt ( config: InternalConfig,  input: RSAEncryptInput )
    returns (output: Result<seq<uint8>, Error>)
  {
    output := RSAEncryption.Encrypt(input);
  }

  predicate GenerateECDSASignatureKeyEnsuresPublicly(input: GenerateECDSASignatureKeyInput, output: Result<GenerateECDSASignatureKeyOutput, Error>)
  {true}

  method GenerateECDSASignatureKey ( config: InternalConfig,  input: GenerateECDSASignatureKeyInput )
    returns (output: Result<GenerateECDSASignatureKeyOutput, Error>)
  {
    output := Signature.KeyGen(input);
  }

  predicate ECDSASignEnsuresPublicly(input: ECDSASignInput, output: Result<seq<uint8>, Error>)
  {true}

  method ECDSASign ( config: InternalConfig,  input: ECDSASignInput )
    returns (output: Result<seq<uint8>, Error>)
  {
    output := Signature.Sign(input.signatureAlgorithm, input.signingKey, input.message);
  }

  predicate ECDSAVerifyEnsuresPublicly(input: ECDSAVerifyInput, output: Result<bool, Error>)
  {true}

  method ECDSAVerify ( config: InternalConfig,  input: ECDSAVerifyInput )
    returns (output: Result<bool, Error>)
  {
    output := Signature.Verify(
      input.signatureAlgorithm,
      input.verificationKey,
      input.message,
      input.signature
    );
  }

  predicate GenerateECCKeyPairEnsuresPublicly(input: GenerateECCKeyPairInput, output: Result<GenerateECCKeyPairOutput, Error>)
  {true}

  method GenerateECCKeyPair (config: InternalConfig, input: GenerateECCKeyPairInput )
    returns (output: Result<GenerateECCKeyPairOutput, Error>)
  {
    output := ECDH.GenerateEccKeyPair(input);
  }

  predicate GetPublicKeyFromPrivateKeyEnsuresPublicly(input: GetPublicKeyFromPrivateKeyInput, output: Result<GetPublicKeyFromPrivateKeyOutput, Error>)
  {true}

  method GetPublicKeyFromPrivateKey (config: InternalConfig, input: GetPublicKeyFromPrivateKeyInput)
    returns (output: Result<GetPublicKeyFromPrivateKeyOutput, Error>)
  {
    output := ECDH.GetPublicKeyFromPrivate(input);
  }

  predicate ValidatePublicKeyEnsuresPublicly(input: ValidatePublicKeyInput, output: Result<ValidatePublicKeyOutput, Error>)
  {true}

  method ValidatePublicKey(config: InternalConfig, input: ValidatePublicKeyInput)
    returns (output: Result<ValidatePublicKeyOutput, Error>)
  {
    output := ECDH.ValidatePublicKey(input);
  }

  predicate DeriveSharedSecretEnsuresPublicly(input: DeriveSharedSecretInput, output: Result<DeriveSharedSecretOutput, Error>)
  {true}

  method DeriveSharedSecret(config: InternalConfig, input: DeriveSharedSecretInput)
    returns (output: Result<DeriveSharedSecretOutput, Error>)
  {
    output := ECDH.DeriveSharedSecret(input);
  }

  predicate CompressPublicKeyEnsuresPublicly(input: CompressPublicKeyInput, output: Result<CompressPublicKeyOutput, Error>)
  {true}

  method CompressPublicKey(config: InternalConfig, input: CompressPublicKeyInput)
    returns (output: Result<CompressPublicKeyOutput, Error>)
  {
    output := ECDH.CompressPublicKey(input);
  }

  predicate DecompressPublicKeyEnsuresPublicly(input: DecompressPublicKeyInput, output: Result<DecompressPublicKeyOutput, Error>)
  {true}

  method DecompressPublicKey(config: InternalConfig, input: DecompressPublicKeyInput)
    returns (output: Result<DecompressPublicKeyOutput, Error>)
  {
    output := ECDH.DecompressPublicKey(input);
  }

  predicate ParsePublicKeyEnsuresPublicly(input: ParsePublicKeyInput, output: Result<ParsePublicKeyOutput, Error>)
  {true}

  method ParsePublicKey(config: InternalConfig, input: ParsePublicKeyInput)
    returns (output: Result<ParsePublicKeyOutput, Error>)
  {
    output := ECDH.ParsePublicKey(input);
  }
}

// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../../Model/AwsCryptographyMaterialProvidersTypes.dfy"
include "../Materials.dfy"
include "MaterialWrapping.dfy"
include "../CanonicalEncryptionContext.dfy"

module IntermediateKeyWrapping {
  import opened StandardLibrary
  import opened UInt = StandardLibrary.UInt
  import opened StandardLibrary.MemoryMath
  import opened Actions
  import opened Wrappers
  import opened MaterialWrapping
  import opened AlgorithmSuites
  import Crypto = AwsCryptographyPrimitivesTypes
  import Types = AwsCryptographyMaterialProvidersTypes
  import AtomicPrimitives
  import Materials
  import UTF8
  import HKDF
  import CanonicalEncryptionContext

  const KEYWRAP_MAC_INFO : UTF8.ValidUTF8Bytes :=
    var s := [0x41, 0x57, 0x53, 0x5f, 0x4d, 0x50, 0x4c, 0x5f, 0x49, 0x4e, 0x54, 0x45, 0x52, 0x4d, 0x45, 0x44, 0x49, 0x41, 0x54, 0x45, 0x5f, 0x4b, 0x45, 0x59, 0x57, 0x52, 0x41, 0x50, 0x5f, 0x4d, 0x41, 0x43];
    assert s == UTF8.EncodeAscii("AWS_MPL_INTERMEDIATE_KEYWRAP_MAC");
    s

  const KEYWRAP_ENC_INFO : UTF8.ValidUTF8Bytes :=
    var s := [0x41, 0x57, 0x53, 0x5f, 0x4d, 0x50, 0x4c, 0x5f, 0x49, 0x4e, 0x54, 0x45, 0x52, 0x4d, 0x45, 0x44, 0x49, 0x41, 0x54, 0x45, 0x5f, 0x4b, 0x45, 0x59, 0x57, 0x52, 0x41, 0x50, 0x5f, 0x45, 0x4e, 0x43];
    assert s == UTF8.EncodeAscii("AWS_MPL_INTERMEDIATE_KEYWRAP_ENC");
    s

  datatype IntermediateUnwrapOutput<T> = IntermediateUnwrapOutput(
    nameonly plaintextDataKey: seq<uint8>,
    nameonly symmetricSigningKey: seq<uint8>,
    nameonly unwrapInfo: T,
    nameonly ghost intermediateMaterial: seq<uint8>
  )

  datatype IntermediateGenerateAndWrapOutput<T> = IntermediateGenerateAndWrapOutput(
    nameonly plaintextDataKey: seq<uint8>,
    nameonly wrappedMaterial: seq<uint8>,
    nameonly symmetricSigningKey: seq<uint8>,
    nameonly wrapInfo: T,
    nameonly ghost intermediateMaterial: seq<uint8>
  )

  datatype IntermediateWrapOutput<T> = IntermediateWrapOutput(
    nameonly wrappedMaterial: seq<uint8>,
    nameonly symmetricSigningKey: seq<uint8>,
    nameonly wrapInfo: T,
    nameonly ghost intermediateMaterial: seq<uint8>
  )

  function method GetIvLengthZeros(len: int32)
    : (output: seq<uint8>)
    requires len >= 0
    ensures |output| == len as nat
    ensures forall x <- output :: x == 0
  {
    if len == 12 then
      [0,0,0,0,0,0,0,0,0,0,0,0]
    else
      seq(len, _ => 0)
  }

  method IntermediateUnwrap<T>(
    unwrap: UnwrapMaterial<T>,
    wrappedMaterial: seq<uint8>,
    algorithmSuite: Types.AlgorithmSuiteInfo,
    encryptionContext: Types.EncryptionContext
  ) returns (res: Result<IntermediateUnwrapOutput<T>, Types.Error>)
    requires unwrap.Invariant()
    requires |wrappedMaterial| >=
             (AlgorithmSuites.GetEncryptKeyLength(algorithmSuite) + AlgorithmSuites.GetEncryptTagLength(algorithmSuite)) as nat
    requires algorithmSuite.commitment.HKDF?
    modifies unwrap.Modifies
    ensures res.Success? ==> |res.value.plaintextDataKey| == AlgorithmSuites.GetEncryptKeyLength(algorithmSuite) as nat
    ensures
      res.Success? ==>
        && var maybeIntermediateWrappedMat := DeserializeIntermediateWrappedMaterial(wrappedMaterial, algorithmSuite);
        && maybeIntermediateWrappedMat.Success?
        && var unwrapRes := UnwrapOutput(
                              unwrappedMaterial := res.value.intermediateMaterial,
                              unwrapInfo := res.value.unwrapInfo);
        && unwrap.Ensures(
          UnwrapInput(
            wrappedMaterial := maybeIntermediateWrappedMat.value.providerWrappedIkm,
            encryptionContext := encryptionContext,
            algorithmSuite := algorithmSuite,
            serializedEC := CanonicalEncryptionContext.EncryptionContextToAAD(encryptionContext)
          ),
          Success(unwrapRes),
          [])

  {
    var maybeCrypto := AtomicPrimitives.AtomicPrimitives();
    var cryptoPrimitivesX : Crypto.IAwsCryptographicPrimitivesClient :- maybeCrypto
    .MapFailure(e => Types.AwsCryptographyPrimitives(e));
    assert cryptoPrimitivesX is AtomicPrimitives.AtomicPrimitivesClient;
    var cryptoPrimitives := cryptoPrimitivesX as AtomicPrimitives.AtomicPrimitivesClient;
    // Deserialize the Intermediate-Wrapped material
    var deserializedWrapped :- DeserializeIntermediateWrappedMaterial(wrappedMaterial, algorithmSuite);
    var DeserializedIntermediateWrappedMaterial(encryptedPdk, providerWrappedIkm) := deserializedWrapped;
    var serializedEC := CanonicalEncryptionContext.EncryptionContextToAAD(encryptionContext);

    var unwrapOutput :- unwrap.Invoke(
      UnwrapInput(
        wrappedMaterial := providerWrappedIkm,
        encryptionContext := encryptionContext,
        algorithmSuite := algorithmSuite,
        serializedEC := serializedEC
      ), []);
    var UnwrapOutput(intermediateMaterial, unwrapInfo) := unwrapOutput;

    var derivedKeys :- DeriveKeysFromIntermediateMaterial(
      intermediateMaterial,
      algorithmSuite,
      encryptionContext,
      cryptoPrimitives
    );
    var PdkEncryptionAndSymmetricSigningKeys(pdkEncryptionKey, symmetricSigningKey) := derivedKeys;

    // Decrypt the plaintext data key with the pdkEncryptionKey
    var iv: seq<uint8> := GetIvLengthZeros(AlgorithmSuites.GetEncryptIvLength(algorithmSuite)); // IV is zero
    var tagIndex : uint64 := |encryptedPdk| as uint64 - AlgorithmSuites.GetEncryptTagLength(algorithmSuite) as uint64;
    var aad :- serializedEC;

    var decInput := Crypto.AESDecryptInput(
      encAlg := algorithmSuite.encrypt.AES_GCM,
      iv := iv,
      key := pdkEncryptionKey,
      cipherTxt := encryptedPdk[..tagIndex],
      authTag := encryptedPdk[tagIndex..],
      aad := aad
    );
    var decOutR := cryptoPrimitives.AESDecrypt(decInput);
    var plaintextDataKey :- decOutR.MapFailure(e => Types.AwsCryptographyPrimitives(e));

    assert |plaintextDataKey| == AlgorithmSuites.GetEncryptKeyLength(algorithmSuite) as nat;

    return Success(IntermediateUnwrapOutput(
                     plaintextDataKey := plaintextDataKey,
                     symmetricSigningKey := symmetricSigningKey,
                     unwrapInfo := unwrapInfo,
                     intermediateMaterial := intermediateMaterial
                   ));
  }

  method IntermediateWrap<T>(
    generateAndWrap: GenerateAndWrapMaterial<T>,
    plaintextDataKey: seq<uint8>,
    algorithmSuite: Types.AlgorithmSuiteInfo,
    encryptionContext: Types.EncryptionContext
  ) returns (res: Result<IntermediateWrapOutput<T>, Types.Error>)
    requires generateAndWrap.Invariant()
    requires algorithmSuite.commitment.HKDF?
    requires |plaintextDataKey| == AlgorithmSuites.GetEncryptKeyLength(algorithmSuite) as nat
    modifies generateAndWrap.Modifies
    ensures
      res.Success? ==>
        && var maybeIntermediateWrappedMat :=
          DeserializeIntermediateWrappedMaterial(res.value.wrappedMaterial, algorithmSuite);
        && maybeIntermediateWrappedMat.Success?
        && generateAndWrap.Ensures(
             GenerateAndWrapInput(
               algorithmSuite := algorithmSuite,
               encryptionContext := encryptionContext,
               serializedEC := CanonicalEncryptionContext.EncryptionContextToAAD(encryptionContext)
             ),
             Success(
               GenerateAndWrapOutput(
                 plaintextMaterial := res.value.intermediateMaterial,
                 wrappedMaterial := maybeIntermediateWrappedMat.value.providerWrappedIkm,
                 wrapInfo := res.value.wrapInfo)),
             [])

        //= aws-encryption-sdk-specification/framework/algorithm-suites.md#intermediate-key-wrapping
        //# - The [EDK ciphertext](./structures.md#ciphertext) MUST be the following serialization:
        //  | Field                      | Length (bytes)                                     | Interpreted as |
        //  | -------------------------- | -------------------------------------------------- | -------------- |
        //  | Wrapped Plaintext Data Key | The algorithm suite's encryption key length + 16   | Bytes          |
        //  | Wrapped Intermediate Key   | Determined by the keyring responsible for wrapping | Bytes          |
        && res.value.wrappedMaterial ==
           maybeIntermediateWrappedMat.value.encryptedPdk + maybeIntermediateWrappedMat.value.providerWrappedIkm

        //= aws-encryption-sdk-specification/framework/algorithm-suites.md#wrapped-plaintext-data-key
        //= type=implication
        //# This value MUST be equal to the algorithm suite's encryption key length + 16.
        && |maybeIntermediateWrappedMat.value.encryptedPdk| as uint64 ==
           (AlgorithmSuites.GetEncryptKeyLength(algorithmSuite) + AlgorithmSuites.GetEncryptTagLength(algorithmSuite)) as uint64
  {
    var maybeCrypto := AtomicPrimitives.AtomicPrimitives();
    var cryptoPrimitivesX : Crypto.IAwsCryptographicPrimitivesClient :- maybeCrypto
    .MapFailure(e => Types.AwsCryptographyPrimitives(e));

    assert cryptoPrimitivesX is AtomicPrimitives.AtomicPrimitivesClient;
    var cryptoPrimitives := cryptoPrimitivesX as AtomicPrimitives.AtomicPrimitivesClient;


    // Use the provider to get the intermediate key material, and wrapped intermediate key material
    var generateAndWrapOutput :- generateAndWrap.Invoke(
      GenerateAndWrapInput(
        algorithmSuite := algorithmSuite,
        encryptionContext := encryptionContext,
        serializedEC := CanonicalEncryptionContext.EncryptionContextToAAD(encryptionContext)
      ), []);

    //= aws-encryption-sdk-specification/framework/algorithm-suites.md#intermediate-key-wrapping
    //# - For each encrypted data key, a distinct `intermediate key` MUST be generated using cryptographically secure random bytes.
    var GenerateAndWrapOutput(intermediateMaterial, providerWrappedIkm, wrapInfo) := generateAndWrapOutput;

    var derivedKeys :- DeriveKeysFromIntermediateMaterial(
      intermediateMaterial,
      algorithmSuite,
      encryptionContext,
      cryptoPrimitives
    );
    var PdkEncryptionAndSymmetricSigningKeys(pdkEncryptionKey, symmetricSigningKey) := derivedKeys;

    //= aws-encryption-sdk-specification/framework/algorithm-suites.md#wrapped-plaintext-data-key
    //# The wrapped plaintext data key MUST be the result of the following AES GCM 256 Encrypt operation:
    //  - Plaintext: the [plaintext data key](./structures.md#plaintext-data-key) in the related encryption or decryption materials.
    //  - Encryption key: The `key encryption key` derived above.
    //  - AAD: The [encryption context](./structures.md#encryption-context) in the related encryption or decryption materials,
    //    [serialized according to it's specification](structures.md#serialization).
    //  - IV: The IV is 0.
    var iv: seq<uint8> := GetIvLengthZeros(AlgorithmSuites.GetEncryptIvLength(algorithmSuite));
    var aad :- CanonicalEncryptionContext.EncryptionContextToAAD(encryptionContext);
    var encInput := Crypto.AESEncryptInput(
      encAlg := algorithmSuite.encrypt.AES_GCM,
      iv := iv,
      key := pdkEncryptionKey,
      msg := plaintextDataKey,
      aad := aad
    );
    var encOutR := cryptoPrimitives.AESEncrypt(encInput);
    var encryptedPdk :- encOutR.MapFailure(e => Types.AwsCryptographyPrimitives(e));

    assert |encryptedPdk.cipherText + encryptedPdk.authTag| ==
           (AlgorithmSuites.GetEncryptKeyLength(algorithmSuite) + AlgorithmSuites.GetEncryptTagLength(algorithmSuite)) as nat;

    var serializedMaterial := encryptedPdk.cipherText + encryptedPdk.authTag + providerWrappedIkm;

    return Success(IntermediateWrapOutput(
                     wrappedMaterial := serializedMaterial,
                     symmetricSigningKey := symmetricSigningKey,
                     wrapInfo := wrapInfo,
                     intermediateMaterial := intermediateMaterial
                   ));
  }

  method IntermediateGenerateAndWrap<T>(
    generateAndWrap: GenerateAndWrapMaterial<T>,
    algorithmSuite: Types.AlgorithmSuiteInfo,
    encryptionContext: Types.EncryptionContext
  ) returns (res: Result<IntermediateGenerateAndWrapOutput<T>, Types.Error>)
    requires generateAndWrap.Invariant()
    requires algorithmSuite.commitment.HKDF?
    modifies generateAndWrap.Modifies
    ensures
      res.Success? ==>
        && var maybeIntermediateWrappedMat :=
          DeserializeIntermediateWrappedMaterial(res.value.wrappedMaterial, algorithmSuite);
        && maybeIntermediateWrappedMat.Success?
        && generateAndWrap.Ensures(GenerateAndWrapInput(
                                     algorithmSuite := algorithmSuite,
                                     encryptionContext := encryptionContext,
                                     serializedEC := CanonicalEncryptionContext.EncryptionContextToAAD(encryptionContext)
                                   ), Success(
                                     GenerateAndWrapOutput(
                                       plaintextMaterial := res.value.intermediateMaterial,
                                       wrappedMaterial := maybeIntermediateWrappedMat.value.providerWrappedIkm,
                                       wrapInfo := res.value.wrapInfo)),
                                   [])
  {
    var maybeCrypto := AtomicPrimitives.AtomicPrimitives();
    var cryptoPrimitives :- maybeCrypto
    .MapFailure(e => Types.AwsCryptographyPrimitives(e));

    var generateBytesResult := cryptoPrimitives
    .GenerateRandomBytes(Crypto.GenerateRandomBytesInput(length := GetEncryptKeyLength(algorithmSuite)));
    var plaintextDataKey :- generateBytesResult.MapFailure(e => Types.AwsCryptographyPrimitives(AwsCryptographyPrimitives := e));

    var wrapOutput :- IntermediateWrap(
      generateAndWrap,
      plaintextDataKey,
      algorithmSuite,
      encryptionContext
    );

    return Success(IntermediateGenerateAndWrapOutput(
                     plaintextDataKey := plaintextDataKey,
                     wrappedMaterial := wrapOutput.wrappedMaterial,
                     symmetricSigningKey := wrapOutput.symmetricSigningKey,
                     wrapInfo := wrapOutput.wrapInfo,
                     intermediateMaterial := wrapOutput.intermediateMaterial
                   ));
  }

  datatype DeserializedIntermediateWrappedMaterial = DeserializedIntermediateWrappedMaterial(
    nameonly encryptedPdk: seq<uint8>,
    nameonly providerWrappedIkm: seq<uint8>
  )

  // Given material wrapped using Intermediate Key Wrapping,
  // get the provider wrapped portion
  function method DeserializeIntermediateWrappedMaterial(material: seq<uint8>, algSuite: Types.AlgorithmSuiteInfo)
    : (ret: Result<DeserializedIntermediateWrappedMaterial, Types.Error>)
  {
    SequenceIsSafeBecauseItIsInMemory(material);
    :- Need(|material| as uint64 >= (AlgorithmSuites.GetEncryptKeyLength(algSuite) + AlgorithmSuites.GetEncryptTagLength(algSuite)) as uint64,
            Types.AwsCryptographicMaterialProvidersException(
              message := "Unable to deserialize Intermediate Key Wrapped material: too short."));
    var encryptedPdkLen := AlgorithmSuites.GetEncryptKeyLength(algSuite) + AlgorithmSuites.GetEncryptTagLength(algSuite);
    Success(DeserializedIntermediateWrappedMaterial(
              encryptedPdk := material[..encryptedPdkLen],
              providerWrappedIkm := material[encryptedPdkLen..]
            ))
  }

  datatype PdkEncryptionAndSymmetricSigningKeys = PdkEncryptionAndSymmetricSigningKeys(
    nameonly pdkEncryptionKey: seq<uint8>,
    nameonly symmetricSigningKey: seq<uint8>
  )

  method DeriveKeysFromIntermediateMaterial(
    intermediateMaterial: seq<uint8>,
    algorithmSuite: Types.AlgorithmSuiteInfo,
    encryptionContext: Types.EncryptionContext,
    cryptoPrimitives: AtomicPrimitives.AtomicPrimitivesClient
  )
    returns (res: Result<PdkEncryptionAndSymmetricSigningKeys, Types.Error>)
    requires cryptoPrimitives.ValidState()
    requires algorithmSuite.commitment.HKDF?
    modifies cryptoPrimitives.Modifies
    ensures cryptoPrimitives.ValidState()
  {
    var hkdfExtractInput := Crypto.HkdfExtractInput(
      digestAlgorithm := algorithmSuite.commitment.HKDF.hmac,
      salt := None,
      ikm := intermediateMaterial
    );

    var maybePseudoRandomKey := cryptoPrimitives.HkdfExtract(hkdfExtractInput);
    var pseudoRandomKey :- maybePseudoRandomKey
    .MapFailure(e => Types.AwsCryptographyPrimitives(e));

    var symmetricSigningKeyInput := Crypto.HkdfExpandInput(
      digestAlgorithm := algorithmSuite.commitment.HKDF.hmac,
      prk := pseudoRandomKey,
      info := KEYWRAP_MAC_INFO,
      expectedLength := algorithmSuite.commitment.HKDF.outputKeyLength
    );
    var pdkEncryptionKeyInput := symmetricSigningKeyInput.(
    info := KEYWRAP_ENC_INFO
    );

    //= aws-encryption-sdk-specification/framework/algorithm-suites.md#intermediate-key-wrapping
    //# - For each encrypted data key, a [symmetric signing key](./structures.md#symmetric-signing-key) MUST be derived from the `intermediate key`
    //# using the key derivation algorithm in the algorithm suite, with the following specifics:
    //  - The input key material is the `intermediate key`
    //  - The salt is empty
    //  - The info is "AWS_MPL_INTERMEDIATE_KEYWRAP_MAC" as UTF8 bytes.
    var maybeSymmetricSigningKey := cryptoPrimitives.HkdfExpand(symmetricSigningKeyInput);
    var symmetricSigningKey :- maybeSymmetricSigningKey
    .MapFailure(e => Types.AwsCryptographyPrimitives(e));

    //= aws-encryption-sdk-specification/framework/algorithm-suites.md#intermediate-key-wrapping
    //# - For each encrypted data key, a `key encryption key` MUST be derived from the `intermediate key`
    //# using the key derivation algorithm in the algorithm suite, with the following specifics:
    //  - The input key material is the `intermediate key`
    //  - The salt is empty
    //  - The info is "AWS_MPL_INTERMEDIATE_KEYWRAP_ENC" as UTF8 bytes.
    var maybePdkEncryptionKey := cryptoPrimitives.HkdfExpand(pdkEncryptionKeyInput);
    var pdkEncryptionKey :- maybePdkEncryptionKey
    .MapFailure(e => Types.AwsCryptographyPrimitives(e));

    return Success(
        PdkEncryptionAndSymmetricSigningKeys(
          pdkEncryptionKey := pdkEncryptionKey,
          symmetricSigningKey := symmetricSigningKey
        )
      );
  }
}

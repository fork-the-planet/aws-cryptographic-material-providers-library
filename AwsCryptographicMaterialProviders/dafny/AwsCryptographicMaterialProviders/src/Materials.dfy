// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../Model/AwsCryptographyMaterialProvidersTypes.dfy"
include "AlgorithmSuites.dfy"

module Materials {
  import opened StandardLibrary
  import opened Wrappers
  import opened UInt = StandardLibrary.UInt
  import opened StandardLibrary.MemoryMath
  import Base64
  import UTF8
  import Types = AwsCryptographyMaterialProvidersTypes
  import AS = AlgorithmSuites

  // UTF-8 encoded "aws-crypto-public-key"
  const EC_PUBLIC_KEY_FIELD: UTF8.ValidUTF8Bytes :=
    var s :=
      [0x61, 0x77, 0x73, 0x2D, 0x63, 0x72, 0x79, 0x70, 0x74, 0x6F, 0x2D, 0x70,
       0x75, 0x62, 0x6C, 0x69, 0x63, 0x2D, 0x6B, 0x65, 0x79];
    assert UTF8.ValidUTF8Range(s, 0, 21);
    s
  const RESERVED_KEY_VALUES := { EC_PUBLIC_KEY_FIELD }

  // Encryption Materials

  // This function is responsible for putting
  // the validation key into the encryption context.
  function method InitializeEncryptionMaterials(
    input: Types.InitializeEncryptionMaterialsInput
  )
    :(res: Result<Types.EncryptionMaterials, Types.Error>)
    ensures
      && res.Success?
      ==>
        && ValidEncryptionMaterials(res.value)
        && var suite := AS.GetSuite(input.algorithmSuiteId);
        && res.value.algorithmSuite == suite
        && (!suite.signature.None? <==> EC_PUBLIC_KEY_FIELD in res.value.encryptionContext)
           //= aws-encryption-sdk-specification/framework/structures.md#signing-key
           //= type=implication
           //# If the
           //# algorithm suite does not contain an asymmetric signing algorithm, the signing key
           //# MUST NOT be present.
        && (suite.signature.None? <==> res.value.signingKey.None?)
    //= aws-encryption-sdk-specification/framework/structures.md#encryption-context-1
    //= type=implication
    //# The mapped value
    //# from the reserved key `aws-crypto-public-key` SHOULD be the signature
    //# verification key corresponding to the [signing key](#signing-key)
    //# stored on the [encryption material](#encryption-materials).
    ensures
      && EC_PUBLIC_KEY_FIELD in input.encryptionContext
      ==>
        && res.Failure?
  {
    :- Need(EC_PUBLIC_KEY_FIELD !in input.encryptionContext, Types.AwsCryptographicMaterialProvidersException(
              message := "Encryption Context "));

    :- Need(forall key <- input.requiredEncryptionContextKeys :: key in input.encryptionContext,
            Types.AwsCryptographicMaterialProvidersException(
              message := "Required encryption context keys do not exist in provided encryption context.")
       );

    var suite := AS.GetSuite(input.algorithmSuiteId);

    :- Need(suite.signature.ECDSA? <==> input.signingKey.Some? && input.verificationKey.Some?,
            Types.Error.AwsCryptographicMaterialProvidersException(
              message := "Missing signature key for signed suite."));
    :- Need(suite.signature.None? <==> input.signingKey.None? && input.verificationKey.None?,
            Types.Error.AwsCryptographicMaterialProvidersException(
              message := "Signature key not allowed for non-signed suites."));

    var encryptionContext :- match suite.signature
      case ECDSA(curve) =>
        var enc_vk :- UTF8.Encode(Base64.Encode(input.verificationKey.value))
                      .MapFailure(e => Types.AwsCryptographicMaterialProvidersException( message := e ));
        Success(input.encryptionContext[EC_PUBLIC_KEY_FIELD := enc_vk])
      case None => Success(input.encryptionContext);

    Success(Types.EncryptionMaterials(
              algorithmSuite := suite,
              encryptionContext := encryptionContext,
              encryptedDataKeys := [],
              plaintextDataKey := Option.None,
              signingKey := input.signingKey,
              symmetricSigningKeys := if suite.symmetricSignature.None? then None else Some([]),
              requiredEncryptionContextKeys := input.requiredEncryptionContextKeys
            ))
  }

  function method InitializeDecryptionMaterials(
    input: Types.InitializeDecryptionMaterialsInput
  )
    :(res: Result<Types.DecryptionMaterials, Types.Error>)
    ensures
      && res.Success?
      ==>
        && ValidDecryptionMaterials(res.value)
        && var suite := AS.GetSuite(input.algorithmSuiteId);
        && res.value.algorithmSuite == suite
        && (suite.signature.None? <==> EC_PUBLIC_KEY_FIELD !in input.encryptionContext)
           //= aws-encryption-sdk-specification/framework/structures.md#encryption-context-2
           //= type=implication
           //# The mapped value
           //# from the reserved key `aws-crypto-public-key` SHOULD be the signature
           //# verification key stored on the [decryption materials](#decryption-materials).
        && var verificationKey := DecodeVerificationKey(input.encryptionContext);
        && (
          verificationKey.Success? && verificationKey.value.Some?
          ==>
            res.value.verificationKey == Some(verificationKey.value.value)
        )
  {

    :- Need(forall key <- input.requiredEncryptionContextKeys :: key in input.encryptionContext,
            Types.AwsCryptographicMaterialProvidersException(
              message := "Reproduced encryption context key did not exist in provided encryption context.")
       );

    var suite := AS.GetSuite(input.algorithmSuiteId);
    :- Need(suite.signature.ECDSA? <==> EC_PUBLIC_KEY_FIELD in input.encryptionContext,
            Types.Error.AwsCryptographicMaterialProvidersException(
              message := "Encryption Context missing verification key."));
    :- Need(suite.signature.None? <==> EC_PUBLIC_KEY_FIELD !in input.encryptionContext,
            Types.Error.AwsCryptographicMaterialProvidersException(
              message := "Verification key can not exist in non-signed Algorithm Suites."));

    var verificationKey :- DecodeVerificationKey(input.encryptionContext);

    Success(Types.DecryptionMaterials(
              encryptionContext := input.encryptionContext,
              algorithmSuite := suite,
              plaintextDataKey := Wrappers.None,
              verificationKey := verificationKey,
              symmetricSigningKey := Wrappers.None,
              requiredEncryptionContextKeys := input.requiredEncryptionContextKeys
            ))
  }

  function method DecodeVerificationKey(encryptionContext: Types.EncryptionContext):
    (res: Result<Option<seq<uint8>>, Types.Error>)
  {
    if EC_PUBLIC_KEY_FIELD in encryptionContext then
      var utf8Key: UTF8.ValidUTF8Bytes := encryptionContext[EC_PUBLIC_KEY_FIELD];
      var base64Key :- UTF8.Decode(utf8Key)
                       .MapFailure(e => Types.AwsCryptographicMaterialProvidersException( message := e ));
      var key :- Base64.Decode(base64Key)
                 .MapFailure(e => Types.AwsCryptographicMaterialProvidersException( message := e ));
      Success(Some(key))
    else
      Success(None)
  }

  /* The goal of ValidEncryptionMaterialsTransition is to approximate
   * _some_ mutability in an otherwise immutable structure.
   * Encryption Materials should allow for the addition
   * of the plaintext data key and encrypted data keys.
   * Once a plaintext data key is added,
   * it can never be removed or altered.
   * Similarly encrypted data keys can be added,
   * but none can be removed.
   * This lets keyrings/CMM handle immutable data,
   * and easily assert these invariants.
   */
  predicate method ValidEncryptionMaterialsTransition(
    oldMat: Types.EncryptionMaterials,
    newMat: Types.EncryptionMaterials
  ) {
    SequenceIsSafeBecauseItIsInMemory(oldMat.encryptedDataKeys);
    SequenceIsSafeBecauseItIsInMemory(newMat.encryptedDataKeys);
    && newMat.algorithmSuite == oldMat.algorithmSuite
    && newMat.encryptionContext == oldMat.encryptionContext
    && newMat.requiredEncryptionContextKeys == oldMat.requiredEncryptionContextKeys
    && newMat.signingKey == oldMat.signingKey
    && (
         || (oldMat.plaintextDataKey.None? && newMat.plaintextDataKey.Some?)
         || oldMat.plaintextDataKey == newMat.plaintextDataKey
       )
    && newMat.plaintextDataKey.Some?
    && |oldMat.encryptedDataKeys| as uint64 <= |newMat.encryptedDataKeys| as uint64
    && multiset(oldMat.encryptedDataKeys) <= multiset(newMat.encryptedDataKeys)
    && (
         !oldMat.algorithmSuite.symmetricSignature.None?
         ==>
           && newMat.symmetricSigningKeys.Some?
           && (oldMat.symmetricSigningKeys.Some? || (oldMat.symmetricSigningKeys.None? && |oldMat.encryptedDataKeys| as uint64 == 0))
           && multiset(oldMat.symmetricSigningKeys.UnwrapOr([])) <= multiset(newMat.symmetricSigningKeys.value))
    && ValidEncryptionMaterials(oldMat)
    && ValidEncryptionMaterials(newMat)
  }

  // Chain of custody is important.
  // Being given valid materials
  // means that you MUST always have valid materials.
  lemma TransitionImplyValidEncryptionMaterials(
    oldMat: Types.EncryptionMaterials,
    newMat: Types.EncryptionMaterials
  )
    // You can not transition from invalid materials
    ensures !ValidEncryptionMaterials(oldMat)
            ==> !ValidEncryptionMaterialsTransition(oldMat, newMat)

    // You can not transition to invalid materials
    ensures !ValidEncryptionMaterials(newMat)
            ==> !ValidEncryptionMaterialsTransition(oldMat, newMat)

    // During transitions, we MUST always end up with a plaintext data key.
    // It is not valid to start with a plaintext datakey and remove it.
    // It is not valid to start with no plaintext datakey and not add one.
    ensures
      && newMat.plaintextDataKey.None?
      ==> !ValidEncryptionMaterialsTransition(oldMat, newMat)
  {}

  predicate method ValidEncryptionMaterials(encryptionMaterials: Types.EncryptionMaterials) {
    SequenceIsSafeBecauseItIsInMemory(encryptionMaterials.encryptedDataKeys);
    OptionalSequenceIsSafeBecauseItIsInMemory(encryptionMaterials.plaintextDataKey);
    OptionalSequenceIsSafeBecauseItIsInMemory(encryptionMaterials.symmetricSigningKeys);
    && AS.AlgorithmSuite?(encryptionMaterials.algorithmSuite)
    && var suite := encryptionMaterials.algorithmSuite;
    && (suite.signature.None? <==> encryptionMaterials.signingKey.None?)
       //= aws-encryption-sdk-specification/framework/structures.md#plaintext-data-key
       //= type=implication
       //# The plaintext data key MUST:
       //# - Fit the specification for the [key derivation algorithm](algorithm-
       //#   suites.md#key-derivation-algorithm) included in this decryption
       //#   material's [algorithm suite](#algorithm-suite).
    && (encryptionMaterials.plaintextDataKey.Some? ==> AS.GetEncryptKeyLength(suite) as uint64 == |encryptionMaterials.plaintextDataKey.value| as uint64)
       //= aws-encryption-sdk-specification/framework/structures.md#encrypted-data-keys
       //= type=implication
       //# If the plaintext data key is not included in this set of encryption
       //# materials, this list MUST be empty.
    && (encryptionMaterials.plaintextDataKey.None? ==> |encryptionMaterials.encryptedDataKeys| as uint64 == 0)
       //= aws-encryption-sdk-specification/framework/structures.md#encryption-context-1
       //= type=implication
       //# If an [encryption material](#encryption-materials) contains a [signing key]
       //# (#signing-key), the [encryption context](#encryption-context) SHOULD
       //# include the reserved key `aws-crypto-public-key`.
       //
       //= aws-encryption-sdk-specification/framework/structures.md#encryption-context-1
       //= type=implication
       //# If an [encryption
       //# material](#encryption-materials) does not contains a [signing key]
       //# (#signing-key), the [encryption context](#encryption-context) SHOULD
       //# NOT include the reserved key `aws-crypto-public-key`.
    && (!suite.signature.None? <==> EC_PUBLIC_KEY_FIELD in encryptionMaterials.encryptionContext)

    //= aws-encryption-sdk-specification/framework/structures.md#signing-key
    //= type=exception
    //# The signing key MUST fit the specification described by the [asymmetric signature algorithm](algorithm-suites.md#asymmetric-signature-algorithm)
    //# included in this encryption material's [algorithm suite](#algorithm-suite).
    // ECDSA keys are just bytes.
    // `FieldSize` in Signature.dfy could be exported to do this check
    // But at this time existence is deemed acceptable.
    && (suite.signature.ECDSA? <==> encryptionMaterials.signingKey.Some?)
    && (!suite.signature.None? <==> EC_PUBLIC_KEY_FIELD in encryptionMaterials.encryptionContext)
       //= aws-encryption-sdk-specification/framework/structures.md#symmetric-signing-keys
       //= type=implication
       //# If the algorithm suite does contain a symmetric signing algorithm, this list MUST have length equal to the [encrypted data key list](#encrypted-data-keys).
    && (suite.symmetricSignature.HMAC? && encryptionMaterials.symmetricSigningKeys.Some? ==>
          |encryptionMaterials.symmetricSigningKeys.value| as uint64 == |encryptionMaterials.encryptedDataKeys| as uint64)
    && (suite.symmetricSignature.HMAC? ==>
          || encryptionMaterials.symmetricSigningKeys.Some?
          || (|encryptionMaterials.encryptedDataKeys| as uint64 == 0 && encryptionMaterials.symmetricSigningKeys.None?))
       //= aws-encryption-sdk-specification/framework/structures.md#symmetric-signing-keys
       //= type=implication
       //# If the algorithm suite does not contain a symmetric signing algorithm, this list MUST NOT be included in the materials.
    && (suite.symmetricSignature.None? ==> encryptionMaterials.symmetricSigningKeys.None?)

    //= aws-encryption-sdk-specification/framework/structures.md#required-encryption-context-keys
    //= type=implication
    //# Every key in Required Encryption Context Keys
    //# MUST be a key in the [encryption context](#encryption-context-1).
    && forall key <- encryptionMaterials.requiredEncryptionContextKeys
         :: key in encryptionMaterials.encryptionContext
  }

  // This is cited here to demonstrate the connection between this function
  // and its use in the Default CMM to verify the correctness of Encryption Materials.

  // if the output materials are valid then they contain the required fields
  //= aws-encryption-sdk-specification/framework/cmm-interface.md#get-encryption-materials
  //# The encryption materials returned MUST include the following:

  // See EncryptionMaterialsHasPlaintextDataKey for details
  //= aws-encryption-sdk-specification/framework/cmm-interface.md#get-encryption-materials
  //# The CMM MUST ensure that the encryption materials returned are valid.
  //# - The encryption materials returned MUST follow the specification for [encryption-materials](structures.md#encryption-materials).
  //# - The value of the plaintext data key MUST be non-NULL.
  //# - The plaintext data key length MUST be equal to the [key derivation input length](algorithm-suites.md#key-derivation-input-length).
  //# - The encrypted data keys list MUST contain at least one encrypted data key.
  //# - If the algorithm suite contains a signing algorithm, the encryption materials returned MUST include the generated signing key.
  //# - For every key in [Required Encryption Context Keys](structures.md#required-encryption-context-keys)
  //#   there MUST be a matching key in the [Encryption Context](structures.md#encryption-context-1).
  predicate method EncryptionMaterialsHasPlaintextDataKey(encryptionMaterials: Types.EncryptionMaterials) {
    SequenceIsSafeBecauseItIsInMemory(encryptionMaterials.encryptedDataKeys);
    && encryptionMaterials.plaintextDataKey.Some?
    && |encryptionMaterials.encryptedDataKeys| as uint64 > 0
    && ValidEncryptionMaterials(encryptionMaterials)
  }

  function method EncryptionMaterialAddEncryptedDataKeys(
    encryptionMaterials: Types.EncryptionMaterials,
    encryptedDataKeysToAdd: Types.EncryptedDataKeyList,
    symmetricSigningKeysToAdd: Option<Types.SymmetricSigningKeyList>
  )
    :(res: Result<Types.EncryptionMaterials, Types.Error>)
    requires |encryptedDataKeysToAdd| > 0
    requires symmetricSigningKeysToAdd.Some? ==> |encryptedDataKeysToAdd| == |symmetricSigningKeysToAdd.value|
    ensures res.Success?
            ==>
              && EncryptionMaterialsHasPlaintextDataKey(res.value)
              && ValidEncryptionMaterialsTransition(encryptionMaterials, res.value)
  {
    :- Need(ValidEncryptionMaterials(encryptionMaterials),
            Types.InvalidEncryptionMaterialsTransition( message := "Attempt to modify invalid encryption material."));
    :- Need(encryptionMaterials.plaintextDataKey.Some?,
            Types.InvalidEncryptionMaterialsTransition( message := "Adding encrypted data keys without a plaintext data key is not allowed."));
    :- Need(symmetricSigningKeysToAdd.None? ==> encryptionMaterials.algorithmSuite.symmetricSignature.None?,
            Types.InvalidEncryptionMaterialsTransition( message := "Adding encrypted data keys without a symmetric signing key when using symmetric signing is not allowed."));
    :- Need(symmetricSigningKeysToAdd.Some? ==> !encryptionMaterials.algorithmSuite.symmetricSignature.None?,
            Types.InvalidEncryptionMaterialsTransition( message := "Adding encrypted data keys with a symmetric signing key when not using symmetric signing is not allowed."));

    var symmetricSigningKeys :=
      if symmetricSigningKeysToAdd.None? then
        encryptionMaterials.symmetricSigningKeys
      else
        Some(encryptionMaterials.symmetricSigningKeys.UnwrapOr([]) + symmetricSigningKeysToAdd.value);

    Success(Types.EncryptionMaterials(
              plaintextDataKey := encryptionMaterials.plaintextDataKey,
              encryptedDataKeys := encryptionMaterials.encryptedDataKeys + encryptedDataKeysToAdd,
              algorithmSuite := encryptionMaterials.algorithmSuite,
              encryptionContext := encryptionMaterials.encryptionContext,
              signingKey := encryptionMaterials.signingKey,
              symmetricSigningKeys := symmetricSigningKeys,
              requiredEncryptionContextKeys := encryptionMaterials.requiredEncryptionContextKeys
            ))
  }

  function method EncryptionMaterialAddDataKey(
    encryptionMaterials: Types.EncryptionMaterials,
    plaintextDataKey: seq<uint8>,
    encryptedDataKeysToAdd: Types.EncryptedDataKeyList,
    symmetricSigningKeysToAdd: Option<Types.SymmetricSigningKeyList>
  )
    :(res: Result<Types.EncryptionMaterials, Types.Error>)
    requires |encryptedDataKeysToAdd| > 0
    requires symmetricSigningKeysToAdd.Some? ==> |encryptedDataKeysToAdd| == |symmetricSigningKeysToAdd.value|
    ensures res.Success?
            ==>
              && EncryptionMaterialsHasPlaintextDataKey(res.value)
              && ValidEncryptionMaterialsTransition(encryptionMaterials, res.value)
  {
    var suite := encryptionMaterials.algorithmSuite;
    :- Need(ValidEncryptionMaterials(encryptionMaterials),
            Types.InvalidEncryptionMaterialsTransition( message := "Attempt to modify invalid encryption material."));
    :- Need(encryptionMaterials.plaintextDataKey.None?,
            Types.InvalidEncryptionMaterialsTransition( message :="Attempt to modify plaintextDataKey."));
    SequenceIsSafeBecauseItIsInMemory(plaintextDataKey);
    :- Need(AS.GetEncryptKeyLength(suite) as uint64 == |plaintextDataKey| as uint64,
            Types.InvalidEncryptionMaterialsTransition( message := "plaintextDataKey does not match Algorithm Suite specification."));
    :- Need(symmetricSigningKeysToAdd.None? == encryptionMaterials.algorithmSuite.symmetricSignature.None?,
            Types.InvalidEncryptionMaterialsTransition( message := "Adding encrypted data keys without a symmetric signing key when using symmetric signing is not allowed."));
    :- Need(symmetricSigningKeysToAdd.Some? == !encryptionMaterials.algorithmSuite.symmetricSignature.None?,
            Types.InvalidEncryptionMaterialsTransition( message := "Adding encrypted data keys with a symmetric signing key when not using symmetric signing is not allowed."));

    var symmetricSigningKeys :=
      if symmetricSigningKeysToAdd.None? then
        encryptionMaterials.symmetricSigningKeys
      else
        Some(encryptionMaterials.symmetricSigningKeys.UnwrapOr([]) + symmetricSigningKeysToAdd.value);

    Success(Types.EncryptionMaterials(
              plaintextDataKey := Some(plaintextDataKey),
              encryptedDataKeys := encryptionMaterials.encryptedDataKeys + encryptedDataKeysToAdd,
              algorithmSuite := encryptionMaterials.algorithmSuite,
              encryptionContext := encryptionMaterials.encryptionContext,
              signingKey := encryptionMaterials.signingKey,
              symmetricSigningKeys := symmetricSigningKeys,
              requiredEncryptionContextKeys := encryptionMaterials.requiredEncryptionContextKeys
            ))
  }

  // Decryption Materials
  /* The goal of DecryptionMaterialsTransitionIsValid is to approximate
   * _some_ mutability in an otherwise immutable structure.
   * Decryption Materials allow for the addition
   * of a plaintext data key.
   * Once a plaintext data key is added,
   * it can never be removed or altered.
   * This lets keyrings/CMM handle immutable data,
   * and easily assert these invariants.
   */
  predicate method DecryptionMaterialsTransitionIsValid(
    oldMat: Types.DecryptionMaterials,
    newMat: Types.DecryptionMaterials
  ) {
    && newMat.algorithmSuite == oldMat.algorithmSuite
    && newMat.encryptionContext == oldMat.encryptionContext
    && newMat.requiredEncryptionContextKeys == oldMat.requiredEncryptionContextKeys
    && newMat.verificationKey == oldMat.verificationKey
    && oldMat.plaintextDataKey.None?
    && newMat.plaintextDataKey.Some?
    && oldMat.symmetricSigningKey.None?
    && ValidDecryptionMaterials(oldMat)
    && ValidDecryptionMaterials(newMat)
  }

  // Chain of custody is important.
  // Being given valid materials
  // means that you MUST always have valid materials.
  lemma TransitionImplyValidDecryptionMaterials(
    oldMat: Types.DecryptionMaterials,
    newMat: Types.DecryptionMaterials
  )
    // You can not transition from invalid materials
    ensures !ValidDecryptionMaterials(oldMat)
            ==> !DecryptionMaterialsTransitionIsValid(oldMat, newMat)

    // You can not transition to invalid materials
    ensures !ValidDecryptionMaterials(newMat)
            ==> !DecryptionMaterialsTransitionIsValid(oldMat, newMat)
  {}

  predicate method ValidDecryptionMaterials(decryptionMaterials: Types.DecryptionMaterials) {
    OptionalSequenceIsSafeBecauseItIsInMemory(decryptionMaterials.plaintextDataKey);
    && AS.AlgorithmSuite?(decryptionMaterials.algorithmSuite)
    && var suite := decryptionMaterials.algorithmSuite;
    //= aws-encryption-sdk-specification/framework/structures.md#plaintext-data-key-1
    //= type=implication
    //# The plaintext data key MUST:
    //# - Fit the specification for the [encryption algorithm](algorithm-
    //# suites.md#encryption-algorithm)  included in this decryption
    //# material's [algorithm suite](#algorithm-suite-1).
    && (decryptionMaterials.plaintextDataKey.Some? ==> AS.GetEncryptKeyLength(suite) as uint64 == |decryptionMaterials.plaintextDataKey.value| as uint64)
       //= aws-encryption-sdk-specification/framework/structures.md#encryption-context-2
       //= type=implication
       //# If a [decryption materials](#decryption-materials) contains a [verification key]
       //# (#verification-key), the [encryption context](#encryption-context) SHOULD
       //# include the reserved key `aws-crypto-public-key`.
       //
       //= aws-encryption-sdk-specification/framework/structures.md#encryption-context-2
       //= type=implication
       //# If a [decryption materials](#decryption-materials) does not contain a
       //# [verification key](#verification-key), the [encryption context]
       //# (#encryption-context) SHOULD NOT include the reserved key `aws-crypto-
       //# public-key`.
    && (!suite.signature.None? <==> EC_PUBLIC_KEY_FIELD in decryptionMaterials.encryptionContext)

    //= aws-encryption-sdk-specification/framework/structures.md#verification-key
    //= type=exception
    //# The verification key MUST fit the specification for the [asymmetric signature algorithm](algorithm-suites.md#asymmetric-signature-algorithm)
    //# included in this decryption material's [algorithm suite](#algorithm-suite-1).
    // ECDSA keys are just bytes.
    // `FieldSize` in Signature.dfy could be exported to do this check
    // But at this time existence is deemed acceptable.
    && (suite.signature.ECDSA? <==> decryptionMaterials.verificationKey.Some?)
    && (!suite.signature.None? <==> EC_PUBLIC_KEY_FIELD in decryptionMaterials.encryptionContext)
       //= aws-encryption-sdk-specification/framework/structures.md#symmetric-signing-key
       //= type=implication
       //# If the algorithm suite does contain a symmetric signing algorithm,
       //# the symmetric signing key MUST also be included in the materials
       //# if and only if the materials also include a [plaintext data key](#plaintext-data-key-1).
    && (!suite.symmetricSignature.None? ==> (decryptionMaterials.plaintextDataKey.Some? <==> decryptionMaterials.symmetricSigningKey.Some?))
       //= aws-encryption-sdk-specification/framework/structures.md#symmetric-signing-key
       //= type=implication
       //# If the algorithm suite does not contain a symmetric signing algorithm,
       //# the symmetric signing key MUST NOT be included in the materials.
    && (suite.symmetricSignature.None? ==> decryptionMaterials.symmetricSigningKey.None?)

    //= aws-encryption-sdk-specification/framework/structures.md#required-encryption-context-keys-1
    //= type=implication
    //# Every key in Required Encryption Context Keys
    //# MUST be a key in the [encryption context](#encryption-context-2).
    && forall k <- decryptionMaterials.requiredEncryptionContextKeys
         :: k in decryptionMaterials.encryptionContext
  }

  function method DecryptionMaterialsAddDataKey(
    decryptionMaterials: Types.DecryptionMaterials,
    plaintextDataKey: seq<uint8>,
    symmetricSigningKey: Option<seq<uint8>>
  )
    :(res: Result<Types.DecryptionMaterials, Types.Error>)
    ensures res.Success?
            ==>
              && DecryptionMaterialsWithPlaintextDataKey(res.value)
              && DecryptionMaterialsTransitionIsValid(decryptionMaterials, res.value)
  {
    SequenceIsSafeBecauseItIsInMemory(plaintextDataKey);
    var suite := decryptionMaterials.algorithmSuite;
    :- Need(ValidDecryptionMaterials(decryptionMaterials),
            Types.InvalidDecryptionMaterialsTransition( message := "Attempt to modify invalid decryption material."));
    :- Need(decryptionMaterials.plaintextDataKey.None?,
            Types.InvalidDecryptionMaterialsTransition( message := "Attempt to modify plaintextDataKey."));
    :- Need(AS.GetEncryptKeyLength(suite) as uint64 == |plaintextDataKey| as uint64,
            Types.InvalidDecryptionMaterialsTransition( message := "plaintextDataKey does not match Algorithm Suite specification."));
    :- Need(symmetricSigningKey.Some? == !decryptionMaterials.algorithmSuite.symmetricSignature.None?,
            Types.InvalidDecryptionMaterialsTransition( message := "symmetric signature key must be added with plaintextDataKey if using an algorithm suite with symmetric signing."));
    :- Need(symmetricSigningKey.None? == decryptionMaterials.algorithmSuite.symmetricSignature.None?,
            Types.InvalidDecryptionMaterialsTransition( message := "symmetric signature key cannot be added with plaintextDataKey if using an algorithm suite without symmetric signing."));

    Success(Types.DecryptionMaterials(
              plaintextDataKey := Some(plaintextDataKey),
              algorithmSuite := decryptionMaterials.algorithmSuite,
              encryptionContext := decryptionMaterials.encryptionContext,
              verificationKey := decryptionMaterials.verificationKey,
              symmetricSigningKey := symmetricSigningKey,
              requiredEncryptionContextKeys := decryptionMaterials.requiredEncryptionContextKeys
            ))
  }

  predicate method DecryptionMaterialsWithoutPlaintextDataKey(decryptionMaterials: Types.DecryptionMaterials) {
    && decryptionMaterials.plaintextDataKey.None?
    && ValidDecryptionMaterials(decryptionMaterials)
  }

  // This is cited here to demonstrate the connection between this function
  // and its use in the Default CMM to verify the correctness of Decryption Materials.

  // if the output materials are valid then they contain the required fields
  //= aws-encryption-sdk-specification/framework/cmm-interface.md#decrypt-materials
  //# The decryption materials returned MUST include the following:

  //= aws-encryption-sdk-specification/framework/cmm-interface.md#decrypt-materials
  //# - All key-value pairs that exist in [Reproduced Encryption Context](structures.md#encryption-context)
  //# but do not exist in encryption context on the [decrypt materials request](#decrypt-materials-request)
  //# SHOULD be appended to the decryption materials.
  //
  //= aws-encryption-sdk-specification/framework/cmm-interface.md#decrypt-materials
  //# - All keys in this set MUST exist in the decryption materials encryption context.
  //
  //= aws-encryption-sdk-specification/framework/cmm-interface.md#decrypt-materials
  //# The CMM MUST ensure that the decryption materials returned are valid.
  //# - The decryption materials returned MUST follow the specification for [decryption-materials](structures.md#decryption-materials).
  //# - The value of the plaintext data key MUST be non-NULL.
  predicate method DecryptionMaterialsWithPlaintextDataKey(decryptionMaterials: Types.DecryptionMaterials) {
    && decryptionMaterials.plaintextDataKey.Some?
    && ValidDecryptionMaterials(decryptionMaterials)
  }

  // The distinction between DecryptionMaterials with and without a PlaintextDataKey
  // is relevant to DecryptionMaterials in a way that it is not for EncryptionMaterials.
  // To avoid ambiguity a keyring that receives DecryptionMaterials with a PlaintextDataKey MUST fail.
  // Given the failure mode of the MultiKeyring,
  // or any other rational combinator.
  type DecryptionMaterialsPendingPlaintextDataKey = d: Types.DecryptionMaterials
    | DecryptionMaterialsWithoutPlaintextDataKey(d)
    witness *

  type SealedDecryptionMaterials = d: Types.DecryptionMaterials
    | DecryptionMaterialsWithPlaintextDataKey(d)
    witness *

}

// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
// Do not modify this file. This file is machine generated, and any changes to it will be overwritten.
package software.amazon.cryptography.materialproviderstestvectorkeys;

import dafny.DafnySequence;
import java.lang.IllegalArgumentException;
import java.lang.RuntimeException;
import java.util.List;
import software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.Error;
import software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.Error_CollectionOfErrors;
import software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.Error_KeyVectorException;
import software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.Error_Opaque;
import software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.Error_OpaqueWithText;
import software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.IKeyVectorsClient;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.CmmOperation;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.CollectionOfErrors;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.GetKeyDescriptionInput;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.GetKeyDescriptionOutput;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.HierarchyKeyring;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.KMSInfo;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.KeyDescription;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.KeyVectorException;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.KeyVectorsConfig;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.KmsEcdhKeyring;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.KmsMrkAware;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.KmsMrkAwareDiscovery;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.KmsRsaKeyring;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.MultiKeyring;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.OpaqueError;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.OpaqueWithTextError;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.RawAES;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.RawEcdh;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.RawRSA;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.RequiredEncryptionContextCMM;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.SerializeKeyDescriptionInput;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.SerializeKeyDescriptionOutput;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.StaticKeyring;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.TestVectorCmmInput;
import software.amazon.cryptography.materialproviderstestvectorkeys.model.TestVectorKeyringInput;

public class ToNative {

  public static OpaqueError Error(Error_Opaque dafnyValue) {
    OpaqueError.Builder nativeBuilder = OpaqueError.builder();
    nativeBuilder.obj(dafnyValue.dtor_obj());
    return nativeBuilder.build();
  }

  public static OpaqueWithTextError Error(Error_OpaqueWithText dafnyValue) {
    OpaqueWithTextError.Builder nativeBuilder = OpaqueWithTextError.builder();
    nativeBuilder.obj(dafnyValue.dtor_obj());
    nativeBuilder.objMessage(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_objMessage()
      )
    );
    return nativeBuilder.build();
  }

  public static CollectionOfErrors Error(Error_CollectionOfErrors dafnyValue) {
    CollectionOfErrors.Builder nativeBuilder = CollectionOfErrors.builder();
    nativeBuilder.list(
      software.amazon.smithy.dafny.conversion.ToNative.Aggregate.GenericToList(
        dafnyValue.dtor_list(),
        ToNative::Error
      )
    );
    nativeBuilder.message(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_message()
      )
    );
    return nativeBuilder.build();
  }

  public static KeyVectorException Error(Error_KeyVectorException dafnyValue) {
    KeyVectorException.Builder nativeBuilder = KeyVectorException.builder();
    nativeBuilder.message(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_message()
      )
    );
    return nativeBuilder.build();
  }

  public static RuntimeException Error(Error dafnyValue) {
    if (dafnyValue.is_KeyVectorException()) {
      return ToNative.Error((Error_KeyVectorException) dafnyValue);
    }
    if (dafnyValue.is_Opaque()) {
      return ToNative.Error((Error_Opaque) dafnyValue);
    }
    if (dafnyValue.is_OpaqueWithText()) {
      return ToNative.Error((Error_OpaqueWithText) dafnyValue);
    }
    if (dafnyValue.is_CollectionOfErrors()) {
      return ToNative.Error((Error_CollectionOfErrors) dafnyValue);
    }
    OpaqueError.Builder nativeBuilder = OpaqueError.builder();
    nativeBuilder.obj(dafnyValue);
    return nativeBuilder.build();
  }

  public static GetKeyDescriptionInput GetKeyDescriptionInput(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.GetKeyDescriptionInput dafnyValue
  ) {
    GetKeyDescriptionInput.Builder nativeBuilder =
      GetKeyDescriptionInput.builder();
    nativeBuilder.json(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.ByteBuffer(
        dafnyValue.dtor_json()
      )
    );
    return nativeBuilder.build();
  }

  public static GetKeyDescriptionOutput GetKeyDescriptionOutput(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.GetKeyDescriptionOutput dafnyValue
  ) {
    GetKeyDescriptionOutput.Builder nativeBuilder =
      GetKeyDescriptionOutput.builder();
    nativeBuilder.keyDescription(
      ToNative.KeyDescription(dafnyValue.dtor_keyDescription())
    );
    return nativeBuilder.build();
  }

  public static HierarchyKeyring HierarchyKeyring(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.HierarchyKeyring dafnyValue
  ) {
    HierarchyKeyring.Builder nativeBuilder = HierarchyKeyring.builder();
    nativeBuilder.keyId(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_keyId()
      )
    );
    return nativeBuilder.build();
  }

  public static KeyVectorsConfig KeyVectorsConfig(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.KeyVectorsConfig dafnyValue
  ) {
    KeyVectorsConfig.Builder nativeBuilder = KeyVectorsConfig.builder();
    nativeBuilder.keyManifestPath(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_keyManifestPath()
      )
    );
    return nativeBuilder.build();
  }

  public static KmsEcdhKeyring KmsEcdhKeyring(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.KmsEcdhKeyring dafnyValue
  ) {
    KmsEcdhKeyring.Builder nativeBuilder = KmsEcdhKeyring.builder();
    nativeBuilder.senderKeyId(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_senderKeyId()
      )
    );
    nativeBuilder.recipientKeyId(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_recipientKeyId()
      )
    );
    nativeBuilder.senderPublicKey(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_senderPublicKey()
      )
    );
    nativeBuilder.recipientPublicKey(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_recipientPublicKey()
      )
    );
    nativeBuilder.curveSpec(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_curveSpec()
      )
    );
    nativeBuilder.keyAgreementScheme(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_keyAgreementScheme()
      )
    );
    return nativeBuilder.build();
  }

  public static KMSInfo KMSInfo(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.KMSInfo dafnyValue
  ) {
    KMSInfo.Builder nativeBuilder = KMSInfo.builder();
    nativeBuilder.keyId(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_keyId()
      )
    );
    return nativeBuilder.build();
  }

  public static KmsMrkAware KmsMrkAware(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.KmsMrkAware dafnyValue
  ) {
    KmsMrkAware.Builder nativeBuilder = KmsMrkAware.builder();
    nativeBuilder.keyId(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_keyId()
      )
    );
    return nativeBuilder.build();
  }

  public static KmsMrkAwareDiscovery KmsMrkAwareDiscovery(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.KmsMrkAwareDiscovery dafnyValue
  ) {
    KmsMrkAwareDiscovery.Builder nativeBuilder = KmsMrkAwareDiscovery.builder();
    nativeBuilder.keyId(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_keyId()
      )
    );
    nativeBuilder.defaultMrkRegion(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_defaultMrkRegion()
      )
    );
    if (dafnyValue.dtor_awsKmsDiscoveryFilter().is_Some()) {
      nativeBuilder.awsKmsDiscoveryFilter(
        software.amazon.cryptography.materialproviders.ToNative.DiscoveryFilter(
          dafnyValue.dtor_awsKmsDiscoveryFilter().dtor_value()
        )
      );
    }
    return nativeBuilder.build();
  }

  public static KmsRsaKeyring KmsRsaKeyring(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.KmsRsaKeyring dafnyValue
  ) {
    KmsRsaKeyring.Builder nativeBuilder = KmsRsaKeyring.builder();
    nativeBuilder.keyId(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_keyId()
      )
    );
    nativeBuilder.encryptionAlgorithm(
      software.amazon.cryptography.services.kms.internaldafny.ToNative.EncryptionAlgorithmSpec(
        dafnyValue.dtor_encryptionAlgorithm()
      )
    );
    return nativeBuilder.build();
  }

  public static MultiKeyring MultiKeyring(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.MultiKeyring dafnyValue
  ) {
    MultiKeyring.Builder nativeBuilder = MultiKeyring.builder();
    if (dafnyValue.dtor_generator().is_Some()) {
      nativeBuilder.generator(
        ToNative.KeyDescription(dafnyValue.dtor_generator().dtor_value())
      );
    }
    nativeBuilder.childKeyrings(
      ToNative.KeyDescriptionList(dafnyValue.dtor_childKeyrings())
    );
    return nativeBuilder.build();
  }

  public static RawAES RawAES(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.RawAES dafnyValue
  ) {
    RawAES.Builder nativeBuilder = RawAES.builder();
    nativeBuilder.keyId(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_keyId()
      )
    );
    nativeBuilder.providerId(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_providerId()
      )
    );
    return nativeBuilder.build();
  }

  public static RawEcdh RawEcdh(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.RawEcdh dafnyValue
  ) {
    RawEcdh.Builder nativeBuilder = RawEcdh.builder();
    nativeBuilder.senderKeyId(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_senderKeyId()
      )
    );
    nativeBuilder.recipientKeyId(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_recipientKeyId()
      )
    );
    nativeBuilder.senderPublicKey(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_senderPublicKey()
      )
    );
    nativeBuilder.recipientPublicKey(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_recipientPublicKey()
      )
    );
    nativeBuilder.providerId(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_providerId()
      )
    );
    nativeBuilder.curveSpec(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_curveSpec()
      )
    );
    nativeBuilder.keyAgreementScheme(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_keyAgreementScheme()
      )
    );
    return nativeBuilder.build();
  }

  public static RawRSA RawRSA(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.RawRSA dafnyValue
  ) {
    RawRSA.Builder nativeBuilder = RawRSA.builder();
    nativeBuilder.keyId(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_keyId()
      )
    );
    nativeBuilder.providerId(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_providerId()
      )
    );
    nativeBuilder.padding(
      software.amazon.cryptography.materialproviders.ToNative.PaddingScheme(
        dafnyValue.dtor_padding()
      )
    );
    return nativeBuilder.build();
  }

  public static RequiredEncryptionContextCMM RequiredEncryptionContextCMM(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.RequiredEncryptionContextCMM dafnyValue
  ) {
    RequiredEncryptionContextCMM.Builder nativeBuilder =
      RequiredEncryptionContextCMM.builder();
    nativeBuilder.underlying(
      ToNative.KeyDescription(dafnyValue.dtor_underlying())
    );
    nativeBuilder.requiredEncryptionContextKeys(
      software.amazon.cryptography.materialproviders.ToNative.EncryptionContextKeys(
        dafnyValue.dtor_requiredEncryptionContextKeys()
      )
    );
    return nativeBuilder.build();
  }

  public static SerializeKeyDescriptionInput SerializeKeyDescriptionInput(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.SerializeKeyDescriptionInput dafnyValue
  ) {
    SerializeKeyDescriptionInput.Builder nativeBuilder =
      SerializeKeyDescriptionInput.builder();
    nativeBuilder.keyDescription(
      ToNative.KeyDescription(dafnyValue.dtor_keyDescription())
    );
    return nativeBuilder.build();
  }

  public static SerializeKeyDescriptionOutput SerializeKeyDescriptionOutput(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.SerializeKeyDescriptionOutput dafnyValue
  ) {
    SerializeKeyDescriptionOutput.Builder nativeBuilder =
      SerializeKeyDescriptionOutput.builder();
    nativeBuilder.json(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.ByteBuffer(
        dafnyValue.dtor_json()
      )
    );
    return nativeBuilder.build();
  }

  public static StaticKeyring StaticKeyring(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.StaticKeyring dafnyValue
  ) {
    StaticKeyring.Builder nativeBuilder = StaticKeyring.builder();
    nativeBuilder.keyId(
      software.amazon.smithy.dafny.conversion.ToNative.Simple.String(
        dafnyValue.dtor_keyId()
      )
    );
    return nativeBuilder.build();
  }

  public static TestVectorCmmInput TestVectorCmmInput(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.TestVectorCmmInput dafnyValue
  ) {
    TestVectorCmmInput.Builder nativeBuilder = TestVectorCmmInput.builder();
    nativeBuilder.keyDescription(
      ToNative.KeyDescription(dafnyValue.dtor_keyDescription())
    );
    nativeBuilder.forOperation(
      ToNative.CmmOperation(dafnyValue.dtor_forOperation())
    );
    return nativeBuilder.build();
  }

  public static TestVectorKeyringInput TestVectorKeyringInput(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.TestVectorKeyringInput dafnyValue
  ) {
    TestVectorKeyringInput.Builder nativeBuilder =
      TestVectorKeyringInput.builder();
    nativeBuilder.keyDescription(
      ToNative.KeyDescription(dafnyValue.dtor_keyDescription())
    );
    return nativeBuilder.build();
  }

  public static CmmOperation CmmOperation(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.CmmOperation dafnyValue
  ) {
    if (dafnyValue.is_ENCRYPT()) {
      return CmmOperation.ENCRYPT;
    }
    if (dafnyValue.is_DECRYPT()) {
      return CmmOperation.DECRYPT;
    }
    throw new IllegalArgumentException(
      "No entry of software.amazon.cryptography.materialproviderstestvectorkeys.model.CmmOperation matches the input : " +
      dafnyValue
    );
  }

  public static KeyDescription KeyDescription(
    software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.KeyDescription dafnyValue
  ) {
    KeyDescription.Builder nativeBuilder = KeyDescription.builder();
    if (dafnyValue.is_Kms()) {
      nativeBuilder.Kms(ToNative.KMSInfo(dafnyValue.dtor_Kms()));
    }
    if (dafnyValue.is_KmsMrk()) {
      nativeBuilder.KmsMrk(ToNative.KmsMrkAware(dafnyValue.dtor_KmsMrk()));
    }
    if (dafnyValue.is_KmsMrkDiscovery()) {
      nativeBuilder.KmsMrkDiscovery(
        ToNative.KmsMrkAwareDiscovery(dafnyValue.dtor_KmsMrkDiscovery())
      );
    }
    if (dafnyValue.is_RSA()) {
      nativeBuilder.RSA(ToNative.RawRSA(dafnyValue.dtor_RSA()));
    }
    if (dafnyValue.is_AES()) {
      nativeBuilder.AES(ToNative.RawAES(dafnyValue.dtor_AES()));
    }
    if (dafnyValue.is_ECDH()) {
      nativeBuilder.ECDH(ToNative.RawEcdh(dafnyValue.dtor_ECDH()));
    }
    if (dafnyValue.is_Static()) {
      nativeBuilder.Static(ToNative.StaticKeyring(dafnyValue.dtor_Static()));
    }
    if (dafnyValue.is_KmsRsa()) {
      nativeBuilder.KmsRsa(ToNative.KmsRsaKeyring(dafnyValue.dtor_KmsRsa()));
    }
    if (dafnyValue.is_KmsECDH()) {
      nativeBuilder.KmsECDH(ToNative.KmsEcdhKeyring(dafnyValue.dtor_KmsECDH()));
    }
    if (dafnyValue.is_Hierarchy()) {
      nativeBuilder.Hierarchy(
        ToNative.HierarchyKeyring(dafnyValue.dtor_Hierarchy())
      );
    }
    if (dafnyValue.is_Multi()) {
      nativeBuilder.Multi(ToNative.MultiKeyring(dafnyValue.dtor_Multi()));
    }
    if (dafnyValue.is_RequiredEncryptionContext()) {
      nativeBuilder.RequiredEncryptionContext(
        ToNative.RequiredEncryptionContextCMM(
          dafnyValue.dtor_RequiredEncryptionContext()
        )
      );
    }
    return nativeBuilder.build();
  }

  public static List<KeyDescription> KeyDescriptionList(
    DafnySequence<
      ? extends software.amazon.cryptography.materialproviderstestvectorkeys.internaldafny.types.KeyDescription
    > dafnyValue
  ) {
    return software.amazon.smithy.dafny.conversion.ToNative.Aggregate.GenericToList(
      dafnyValue,
      software.amazon.cryptography.materialproviderstestvectorkeys.ToNative::KeyDescription
    );
  }

  public static KeyVectors KeyVectors(IKeyVectorsClient dafnyValue) {
    return new KeyVectors(dafnyValue);
  }
}

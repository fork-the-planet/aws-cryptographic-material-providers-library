// Code generated by smithy-go-codegen DO NOT EDIT.

package WrappedAwsCryptographyPrimitivesService

import (
	"context"

	"github.com/aws/aws-cryptographic-material-providers-library/primitives/AwsCryptographyPrimitivesTypes"
	"github.com/aws/aws-cryptographic-material-providers-library/primitives/awscryptographyprimitivessmithygenerated"
	"github.com/dafny-lang/DafnyStandardLibGo/Wrappers"
)

type Shim struct {
	AwsCryptographyPrimitivesTypes.IAwsCryptographicPrimitivesClient
	client *awscryptographyprimitivessmithygenerated.Client
}

func (_static *CompanionStruct_Default___) WrappedAtomicPrimitives(inputConfig AwsCryptographyPrimitivesTypes.CryptoConfig) Wrappers.Result {
	var nativeConfig = awscryptographyprimitivessmithygenerated.CryptoConfig_FromDafny(inputConfig)
	var nativeClient, nativeError = awscryptographyprimitivessmithygenerated.NewClient(nativeConfig)
	if nativeError != nil {
		return Wrappers.Companion_Result_.Create_Failure_(AwsCryptographyPrimitivesTypes.Companion_Error_.Create_Opaque_(nativeError))
	}
	return Wrappers.Companion_Result_.Create_Success_(&Shim{client: nativeClient})
}

func (shim *Shim) GenerateRandomBytes(input AwsCryptographyPrimitivesTypes.GenerateRandomBytesInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.GenerateRandomBytesInput_FromDafny(input)
	var native_response, native_error = shim.client.GenerateRandomBytes(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.Aws_cryptography_primitives_GenerateRandomBytesOutput_data_ToDafny(native_response))
}

func (shim *Shim) Digest(input AwsCryptographyPrimitivesTypes.DigestInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.DigestInput_FromDafny(input)
	var native_response, native_error = shim.client.Digest(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.Aws_cryptography_primitives_DigestOutput_digest_ToDafny(native_response))
}

func (shim *Shim) HMac(input AwsCryptographyPrimitivesTypes.HMacInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.HMacInput_FromDafny(input)
	var native_response, native_error = shim.client.HMac(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.Aws_cryptography_primitives_HMacOutput_digest_ToDafny(native_response))
}

func (shim *Shim) HkdfExtract(input AwsCryptographyPrimitivesTypes.HkdfExtractInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.HkdfExtractInput_FromDafny(input)
	var native_response, native_error = shim.client.HkdfExtract(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.Aws_cryptography_primitives_HkdfExtractOutput_prk_ToDafny(native_response))
}

func (shim *Shim) HkdfExpand(input AwsCryptographyPrimitivesTypes.HkdfExpandInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.HkdfExpandInput_FromDafny(input)
	var native_response, native_error = shim.client.HkdfExpand(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.Aws_cryptography_primitives_HkdfExpandOutput_okm_ToDafny(native_response))
}

func (shim *Shim) Hkdf(input AwsCryptographyPrimitivesTypes.HkdfInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.HkdfInput_FromDafny(input)
	var native_response, native_error = shim.client.Hkdf(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.Aws_cryptography_primitives_HkdfOutput_okm_ToDafny(native_response))
}

func (shim *Shim) KdfCounterMode(input AwsCryptographyPrimitivesTypes.KdfCtrInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.KdfCtrInput_FromDafny(input)
	var native_response, native_error = shim.client.KdfCounterMode(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.Aws_cryptography_primitives_KdfCtrOutput_okm_ToDafny(native_response))
}

func (shim *Shim) AesKdfCounterMode(input AwsCryptographyPrimitivesTypes.AesKdfCtrInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.AesKdfCtrInput_FromDafny(input)
	var native_response, native_error = shim.client.AesKdfCounterMode(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.Aws_cryptography_primitives_AesKdfCtrOutput_okm_ToDafny(native_response))
}

func (shim *Shim) AESEncrypt(input AwsCryptographyPrimitivesTypes.AESEncryptInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.AESEncryptInput_FromDafny(input)
	var native_response, native_error = shim.client.AESEncrypt(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.AESEncryptOutput_ToDafny(*native_response))
}

func (shim *Shim) AESDecrypt(input AwsCryptographyPrimitivesTypes.AESDecryptInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.AESDecryptInput_FromDafny(input)
	var native_response, native_error = shim.client.AESDecrypt(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.Aws_cryptography_primitives_AESDecryptOutput_plaintext_ToDafny(native_response))
}

func (shim *Shim) GenerateRSAKeyPair(input AwsCryptographyPrimitivesTypes.GenerateRSAKeyPairInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.GenerateRSAKeyPairInput_FromDafny(input)
	var native_response, native_error = shim.client.GenerateRSAKeyPair(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.GenerateRSAKeyPairOutput_ToDafny(*native_response))
}

func (shim *Shim) GetRSAKeyModulusLength(input AwsCryptographyPrimitivesTypes.GetRSAKeyModulusLengthInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.GetRSAKeyModulusLengthInput_FromDafny(input)
	var native_response, native_error = shim.client.GetRSAKeyModulusLength(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.GetRSAKeyModulusLengthOutput_ToDafny(*native_response))
}

func (shim *Shim) RSADecrypt(input AwsCryptographyPrimitivesTypes.RSADecryptInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.RSADecryptInput_FromDafny(input)
	var native_response, native_error = shim.client.RSADecrypt(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.Aws_cryptography_primitives_RSADecryptOutput_plaintext_ToDafny(native_response))
}

func (shim *Shim) RSAEncrypt(input AwsCryptographyPrimitivesTypes.RSAEncryptInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.RSAEncryptInput_FromDafny(input)
	var native_response, native_error = shim.client.RSAEncrypt(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.Aws_cryptography_primitives_RSAEncryptOutput_cipherText_ToDafny(native_response))
}

func (shim *Shim) GenerateECDSASignatureKey(input AwsCryptographyPrimitivesTypes.GenerateECDSASignatureKeyInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.GenerateECDSASignatureKeyInput_FromDafny(input)
	var native_response, native_error = shim.client.GenerateECDSASignatureKey(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.GenerateECDSASignatureKeyOutput_ToDafny(*native_response))
}

func (shim *Shim) ECDSASign(input AwsCryptographyPrimitivesTypes.ECDSASignInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.ECDSASignInput_FromDafny(input)
	var native_response, native_error = shim.client.ECDSASign(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.Aws_cryptography_primitives_ECDSASignOutput_signature_ToDafny(native_response))
}

func (shim *Shim) ECDSAVerify(input AwsCryptographyPrimitivesTypes.ECDSAVerifyInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.ECDSAVerifyInput_FromDafny(input)
	var native_response, native_error = shim.client.ECDSAVerify(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.Aws_cryptography_primitives_ECDSAVerifyOutput_success_ToDafny(native_response))
}

func (shim *Shim) GenerateECCKeyPair(input AwsCryptographyPrimitivesTypes.GenerateECCKeyPairInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.GenerateECCKeyPairInput_FromDafny(input)
	var native_response, native_error = shim.client.GenerateECCKeyPair(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.GenerateECCKeyPairOutput_ToDafny(*native_response))
}

func (shim *Shim) GetPublicKeyFromPrivateKey(input AwsCryptographyPrimitivesTypes.GetPublicKeyFromPrivateKeyInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.GetPublicKeyFromPrivateKeyInput_FromDafny(input)
	var native_response, native_error = shim.client.GetPublicKeyFromPrivateKey(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.GetPublicKeyFromPrivateKeyOutput_ToDafny(*native_response))
}

func (shim *Shim) ValidatePublicKey(input AwsCryptographyPrimitivesTypes.ValidatePublicKeyInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.ValidatePublicKeyInput_FromDafny(input)
	var native_response, native_error = shim.client.ValidatePublicKey(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.ValidatePublicKeyOutput_ToDafny(*native_response))
}

func (shim *Shim) DeriveSharedSecret(input AwsCryptographyPrimitivesTypes.DeriveSharedSecretInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.DeriveSharedSecretInput_FromDafny(input)
	var native_response, native_error = shim.client.DeriveSharedSecret(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.DeriveSharedSecretOutput_ToDafny(*native_response))
}

func (shim *Shim) CompressPublicKey(input AwsCryptographyPrimitivesTypes.CompressPublicKeyInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.CompressPublicKeyInput_FromDafny(input)
	var native_response, native_error = shim.client.CompressPublicKey(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.CompressPublicKeyOutput_ToDafny(*native_response))
}

func (shim *Shim) DecompressPublicKey(input AwsCryptographyPrimitivesTypes.DecompressPublicKeyInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.DecompressPublicKeyInput_FromDafny(input)
	var native_response, native_error = shim.client.DecompressPublicKey(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.DecompressPublicKeyOutput_ToDafny(*native_response))
}

func (shim *Shim) ParsePublicKey(input AwsCryptographyPrimitivesTypes.ParsePublicKeyInput) Wrappers.Result {
	var native_request = awscryptographyprimitivessmithygenerated.ParsePublicKeyInput_FromDafny(input)
	var native_response, native_error = shim.client.ParsePublicKey(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographyprimitivessmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographyprimitivessmithygenerated.ParsePublicKeyOutput_ToDafny(*native_response))
}
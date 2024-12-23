// Code generated by smithy-go-codegen DO NOT EDIT.

package WrappedAwsCryptographyKeyStoreService

import (
	"context"

	"github.com/aws/aws-cryptographic-material-providers-library/mpl/AwsCryptographyKeyStoreTypes"
	"github.com/aws/aws-cryptographic-material-providers-library/mpl/awscryptographykeystoresmithygenerated"
	"github.com/dafny-lang/DafnyStandardLibGo/Wrappers"
)

type Shim struct {
	AwsCryptographyKeyStoreTypes.IKeyStoreClient
	client *awscryptographykeystoresmithygenerated.Client
}

func (_static *CompanionStruct_Default___) WrappedKeyStore(inputConfig AwsCryptographyKeyStoreTypes.KeyStoreConfig) Wrappers.Result {
	var nativeConfig = awscryptographykeystoresmithygenerated.KeyStoreConfig_FromDafny(inputConfig)
	var nativeClient, nativeError = awscryptographykeystoresmithygenerated.NewClient(nativeConfig)
	if nativeError != nil {
		return Wrappers.Companion_Result_.Create_Failure_(AwsCryptographyKeyStoreTypes.Companion_Error_.Create_Opaque_(nativeError))
	}
	return Wrappers.Companion_Result_.Create_Success_(&Shim{client: nativeClient})
}

func (shim *Shim) GetKeyStoreInfo() Wrappers.Result {

	var native_response, native_error = shim.client.GetKeyStoreInfo(context.Background())
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographykeystoresmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographykeystoresmithygenerated.GetKeyStoreInfoOutput_ToDafny(*native_response))
}

func (shim *Shim) CreateKeyStore(input AwsCryptographyKeyStoreTypes.CreateKeyStoreInput) Wrappers.Result {
	var native_request = awscryptographykeystoresmithygenerated.CreateKeyStoreInput_FromDafny(input)
	var native_response, native_error = shim.client.CreateKeyStore(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographykeystoresmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographykeystoresmithygenerated.CreateKeyStoreOutput_ToDafny(*native_response))
}

func (shim *Shim) CreateKey(input AwsCryptographyKeyStoreTypes.CreateKeyInput) Wrappers.Result {
	var native_request = awscryptographykeystoresmithygenerated.CreateKeyInput_FromDafny(input)
	var native_response, native_error = shim.client.CreateKey(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographykeystoresmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographykeystoresmithygenerated.CreateKeyOutput_ToDafny(*native_response))
}

func (shim *Shim) VersionKey(input AwsCryptographyKeyStoreTypes.VersionKeyInput) Wrappers.Result {
	var native_request = awscryptographykeystoresmithygenerated.VersionKeyInput_FromDafny(input)
	var native_response, native_error = shim.client.VersionKey(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographykeystoresmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographykeystoresmithygenerated.VersionKeyOutput_ToDafny(*native_response))
}

func (shim *Shim) GetActiveBranchKey(input AwsCryptographyKeyStoreTypes.GetActiveBranchKeyInput) Wrappers.Result {
	var native_request = awscryptographykeystoresmithygenerated.GetActiveBranchKeyInput_FromDafny(input)
	var native_response, native_error = shim.client.GetActiveBranchKey(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographykeystoresmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographykeystoresmithygenerated.GetActiveBranchKeyOutput_ToDafny(*native_response))
}

func (shim *Shim) GetBranchKeyVersion(input AwsCryptographyKeyStoreTypes.GetBranchKeyVersionInput) Wrappers.Result {
	var native_request = awscryptographykeystoresmithygenerated.GetBranchKeyVersionInput_FromDafny(input)
	var native_response, native_error = shim.client.GetBranchKeyVersion(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographykeystoresmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographykeystoresmithygenerated.GetBranchKeyVersionOutput_ToDafny(*native_response))
}

func (shim *Shim) GetBeaconKey(input AwsCryptographyKeyStoreTypes.GetBeaconKeyInput) Wrappers.Result {
	var native_request = awscryptographykeystoresmithygenerated.GetBeaconKeyInput_FromDafny(input)
	var native_response, native_error = shim.client.GetBeaconKey(context.Background(), native_request)
	if native_error != nil {
		return Wrappers.Companion_Result_.Create_Failure_(awscryptographykeystoresmithygenerated.Error_ToDafny(native_error))
	}
	return Wrappers.Companion_Result_.Create_Success_(awscryptographykeystoresmithygenerated.GetBeaconKeyOutput_ToDafny(*native_response))
}

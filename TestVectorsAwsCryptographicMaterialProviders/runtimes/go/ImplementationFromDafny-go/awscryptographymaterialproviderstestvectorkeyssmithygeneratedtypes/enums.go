// Code generated by smithy-go-codegen DO NOT EDIT.

package awscryptographymaterialproviderstestvectorkeyssmithygeneratedtypes

type CmmOperation string

const (
	CmmOperationEncrypt CmmOperation = "ENCRYPT"
	CmmOperationDecrypt CmmOperation = "DECRYPT"
)

func (CmmOperation) Values() []CmmOperation {
	return []CmmOperation{
		"ENCRYPT",
		"DECRYPT",
	}
}

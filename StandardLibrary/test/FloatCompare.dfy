// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../src/StandardLibrary.dfy"
include "../src/FloatCompare.dfy"

module FloatCompareTest {
  import opened Wrappers
  import opened FloatCompare

  method TestCompareFloat(x : string, y : string, ret : CompareType)
    ensures CompareFloat(x, y) == ret
    ensures CompareFloat(y, x) == -ret
  {
    if CompareFloat(x, y) != ret {
      print "CompareFloat(", x, ", ", y, ") was ", CompareFloat(x, y), " but should have been ", ret, "\n";
    }
    if CompareFloat(y, x) != -ret {
      print "CompareFloat(", y, ", ", x, ") was ", CompareFloat(y, x), " but should have been ", -ret, "\n";
    }
    expect CompareFloat(x, y) == ret;
    expect CompareFloat(y, x) == -ret;
  }

  method {:test} SimpleTests() {
    TestCompareFloat("1", "1", Equal);
    TestCompareFloat("2", "1", Greater);
    TestCompareFloat("1.1", "1.2", Less);
    TestCompareFloat("1.2", "1.2", Equal);
    TestCompareFloat("1.35", "1.357", Less);
    TestCompareFloat("1.35e2", "13.5e1", Equal);
    TestCompareFloat("1.351e2", "13.5e1", Greater);
    TestCompareFloat("1.35e-1", "13.5e-2", Equal);
    TestCompareFloat("1", "-2", Greater);
    TestCompareFloat("1.2e7", "2.3e2", Greater);
    TestCompareFloat("-1.2e7", "2.3e2", Less);
    TestCompareFloat("1.2e7", "-2.3e2", Greater);
    TestCompareFloat("-1.2e7", "-2.3e2", Less);
  }

  method {:test} SignTests() {
    TestCompareFloat("+1", "1", Equal);
    TestCompareFloat("+1e+0", "1", Equal);
    TestCompareFloat("+1e-0", "1", Equal);

    TestCompareFloat("-1", "1", Less);
    TestCompareFloat("-1", "+1", Less);
    TestCompareFloat("1", "-1", Greater);
    TestCompareFloat("+1", "-1", Greater);
  }

  method {:test} ExponentTests() {
    TestCompareFloat("2e0", "2e0", Equal);
    TestCompareFloat("1e0", "2e0", Less);
    TestCompareFloat("3e0", "2e0", Greater);

    TestCompareFloat("1e-5", "1e5", Less);
    TestCompareFloat("1e5", "1e-5", Greater);
    TestCompareFloat("1e5", "1e6", Less);
    TestCompareFloat("1e5", "1e4", Greater);
    TestCompareFloat("1e-5", "1e-4", Less);
    TestCompareFloat("1e-5", "1e-6", Greater);

    TestCompareFloat("-1e5", "-1e-5", Less);
    TestCompareFloat("-1e-5", "-1e5", Greater);
    TestCompareFloat("-1e5", "-1e4", Less);
    TestCompareFloat("-1e5", "-1e6", Greater);
    TestCompareFloat("-1e-5", "-1e-6", Less);
    TestCompareFloat("-1e-5", "-1e-4", Greater);
  }

  method {:test} ZeroTests() {
    TestCompareFloat("-0", "0", Equal);
    TestCompareFloat("+0", "0", Equal);
    TestCompareFloat("00", "0", Equal);
    TestCompareFloat("0.0", "0", Equal);
    TestCompareFloat("0", "000", Equal);
    TestCompareFloat("0", ".000", Equal);
    TestCompareFloat("0.0", "000.00000", Equal);

    TestCompareFloat("0", "000.000e0", Equal);
    TestCompareFloat("0", "0e+0", Equal);
    TestCompareFloat("0", "0e-0", Equal);
    TestCompareFloat("0", "0e99", Equal);
    TestCompareFloat("0", "0e-99", Equal);
    TestCompareFloat("0e+99", "0e-99", Equal);
    TestCompareFloat("+0e+99", "-0e-99", Equal);
    TestCompareFloat("-0e+99", "-0e-99", Equal);
    TestCompareFloat("-0e+99", "+0e-99", Equal);

    TestCompareFloat("01", "1", Equal);
    TestCompareFloat("1", "001", Equal);
    TestCompareFloat("1.0", "001.00000", Equal);
  }

  // Test compares of very large and small numbers
  method {:test} ExtremeNumTest() {
    // numbers with high precision
    TestCompareFloat("123456789.01234567890123456789012345678", "123456789.01234567890123456789012345678", Equal);
    TestCompareFloat("1234567890123456789012345678901234567800000000000000000000000000000", "1234567890123456789012345678901234567800000000000000000000000000000", Equal);
    TestCompareFloat(".000000000000000000000000012345678901234567890123456789012345678", "0.000000000000000000000000012345678901234567890123456789012345678", Equal);
    TestCompareFloat("123456789.01234567890123456789012345676", "123456789.01234567890123456789012345678", Less);
    TestCompareFloat("123456789.01234567890123456789012345675", "123456789.01234567890123456789012345676", Less);
    TestCompareFloat("123456789.01234567890123456789012345679", "123456789.01234567890123456789012345678", Greater);
    TestCompareFloat("123456789.01234567890123456789012345677", "123456789.01234567890123456789012345676", Greater);
    TestCompareFloat("-123456789.01234567890123456789012345678", "123456789.01234567890123456789012345678", Less);
    TestCompareFloat("123456789.01234567890123456789012345678", "-123456789.01234567890123456789012345678", Greater);

    // It appears we have issues dealing with exponents

    // high and low exponents
    TestCompareFloat("0000000000000000000000000012345.67e121", "123456700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Equal);
    TestCompareFloat("12345.67e121", "123456700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Equal);
    TestCompareFloat("0.00000001e133", "100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Equal);
    TestCompareFloat("0.00000001e-122", "0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Equal);
    TestCompareFloat("1234567e-136", "0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001234567", Equal);
    TestCompareFloat("0000000000000000000000000012345.66e121", "123456700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Less);
    TestCompareFloat("0000000000000000000000000012345.68e121", "123456700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Greater);
    TestCompareFloat("12345.67e120", "12345.67e121", Less);
    TestCompareFloat("12345.67e122", "12345.67e121", Greater);
    TestCompareFloat("-12345.67e122", "-12345.67e121", Less);
    TestCompareFloat("-12345.67e120", "-12345.67e121", Greater);
    TestCompareFloat("12345.67e120", "123456700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Less);
    TestCompareFloat("12345.67e122", "123456700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Greater);
    TestCompareFloat("-12345.67e122", "-123456700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Less);
    TestCompareFloat("-12345.67e120", "-123456700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Greater);
    TestCompareFloat("0.00000001e-123", "0.00000001e-122", Less);
    TestCompareFloat("0.00000001e-121", "0.00000001e-122", Greater);
    TestCompareFloat("-0.00000001e-121", "-0.00000001e-122", Less);
    TestCompareFloat("-0.00000001e-123", "-0.00000001e-122", Greater);
    TestCompareFloat("0.00000001e-123", "0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Less);
    TestCompareFloat("0.00000001e-121", "0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Greater);
    TestCompareFloat("-0.00000001e-121", "-0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Less);
    TestCompareFloat("-0.00000001e-123", "-0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Greater);

    // large positive numbers
    TestCompareFloat("9.9999999999999999999999999999999999999E+125", "999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Equal);
    TestCompareFloat(".99999999999999999999999999999999999999E+126", "999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Equal);
    TestCompareFloat("999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Equal);
    TestCompareFloat("9.9999999999999999999999999999999999999E+124", "999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Less);
    TestCompareFloat("9.9999999999999999999999999999999999999E+126", "999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Greater);
    TestCompareFloat("999999999999999999999999999999999999989999999999999999999999999999999999999999999999999999999999999999999999999999999999999999", "999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Less);
    TestCompareFloat("999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", "999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Greater);

    // small positive numbers
    TestCompareFloat("1E-130", "0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Equal);
    TestCompareFloat("10E-131", "0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Equal);
    TestCompareFloat("0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", "0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Equal);
    TestCompareFloat("1E-131", "0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Less);
    TestCompareFloat("1E-129", "0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Greater);
    TestCompareFloat("0.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009", "0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Less);
    TestCompareFloat("0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002", "0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Greater);

    // large negative numbers
    TestCompareFloat("-9.9999999999999999999999999999999999999E+125", "-999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Equal);
    TestCompareFloat("-.99999999999999999999999999999999999999E+126", "-999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Equal);
    TestCompareFloat("-999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "-999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Equal);
    TestCompareFloat("-9.9999999999999999999999999999999999999E+126", "-999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Less);
    TestCompareFloat("-9.9999999999999999999999999999999999999E+124", "-999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Greater);
    TestCompareFloat("-999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", "-999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Less);
    TestCompareFloat("-99999999999999999999999999999999999998999999999999999999999999999999999999999999999999999999999999999999999999999999999999999", "-999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", Greater);

    // small negative numbers
    TestCompareFloat("-1E-130", "-0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Equal);
    TestCompareFloat("-10E-131", "-0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Equal);
    TestCompareFloat("-0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", "-0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Equal);
    TestCompareFloat("-1E-129", "-0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Less);
    TestCompareFloat("-1E-131", "-0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Greater);
    TestCompareFloat("-0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002", "-0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Less);
    TestCompareFloat("-0.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009", "-0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", Greater);
  }

  // The results for non-numbers is undefined, but should be consistent
  // If DynamoDB has an opinion on this, we will agree with them
  method {:test} InvalidTests() {
    TestCompareFloat("a", "0", Equal);
    TestCompareFloat("a", "b", Equal);
  }
}

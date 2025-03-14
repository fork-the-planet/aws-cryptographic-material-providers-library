// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
// Do not modify this file. This file is machine generated, and any changes to it will be overwritten.
using System;
using AWS.Cryptography.MaterialProviders;
namespace AWS.Cryptography.MaterialProviders
{
  public class StormTrackingCache
  {
    private int? _entryCapacity;
    private int? _entryPruningTailSize;
    private int? _gracePeriod;
    private int? _graceInterval;
    private int? _fanOut;
    private int? _inFlightTTL;
    private int? _sleepMilli;
    private AWS.Cryptography.MaterialProviders.TimeUnits _timeUnits;
    public int EntryCapacity
    {
      get { return this._entryCapacity.GetValueOrDefault(); }
      set { this._entryCapacity = value; }
    }
    public bool IsSetEntryCapacity()
    {
      return this._entryCapacity.HasValue;
    }
    public int EntryPruningTailSize
    {
      get { return this._entryPruningTailSize.GetValueOrDefault(); }
      set { this._entryPruningTailSize = value; }
    }
    public bool IsSetEntryPruningTailSize()
    {
      return this._entryPruningTailSize.HasValue;
    }
    public int GracePeriod
    {
      get { return this._gracePeriod.GetValueOrDefault(); }
      set { this._gracePeriod = value; }
    }
    public bool IsSetGracePeriod()
    {
      return this._gracePeriod.HasValue;
    }
    public int GraceInterval
    {
      get { return this._graceInterval.GetValueOrDefault(); }
      set { this._graceInterval = value; }
    }
    public bool IsSetGraceInterval()
    {
      return this._graceInterval.HasValue;
    }
    public int FanOut
    {
      get { return this._fanOut.GetValueOrDefault(); }
      set { this._fanOut = value; }
    }
    public bool IsSetFanOut()
    {
      return this._fanOut.HasValue;
    }
    public int InFlightTTL
    {
      get { return this._inFlightTTL.GetValueOrDefault(); }
      set { this._inFlightTTL = value; }
    }
    public bool IsSetInFlightTTL()
    {
      return this._inFlightTTL.HasValue;
    }
    public int SleepMilli
    {
      get { return this._sleepMilli.GetValueOrDefault(); }
      set { this._sleepMilli = value; }
    }
    public bool IsSetSleepMilli()
    {
      return this._sleepMilli.HasValue;
    }
    public AWS.Cryptography.MaterialProviders.TimeUnits TimeUnits
    {
      get { return this._timeUnits; }
      set { this._timeUnits = value; }
    }
    public bool IsSetTimeUnits()
    {
      return this._timeUnits != null;
    }
    public void Validate()
    {
      if (!IsSetEntryCapacity()) throw new System.ArgumentException("Missing value for required property 'EntryCapacity'");
      if (!IsSetGracePeriod()) throw new System.ArgumentException("Missing value for required property 'GracePeriod'");
      if (!IsSetGraceInterval()) throw new System.ArgumentException("Missing value for required property 'GraceInterval'");
      if (!IsSetFanOut()) throw new System.ArgumentException("Missing value for required property 'FanOut'");
      if (!IsSetInFlightTTL()) throw new System.ArgumentException("Missing value for required property 'InFlightTTL'");
      if (!IsSetSleepMilli()) throw new System.ArgumentException("Missing value for required property 'SleepMilli'");
      if (IsSetEntryPruningTailSize())
      {
        if (EntryPruningTailSize < 1)
        {
          throw new System.ArgumentException(
              String.Format("Member EntryPruningTailSize of structure StormTrackingCache has type CountingNumber which has a minimum of 1 but was given the value {0}.", EntryPruningTailSize));
        }
      }
    }
  }
}

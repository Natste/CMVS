classdef Sensor
  properties (Constant = false)
    aTime = Sensor.INTTIME_100MS;
    aGain = Sensor.GAIN_LOW;
  end
  properties (Constant = true)
    INTTIME_100MS = 0x00 % 100 millis
    INTTIME_200MS = 0x01 % 200 millis
    INTTIME_300MS = 0x02 % 300 millis
    INTTIME_400MS = 0x03 % 400 millis
    INTTIME_500MS = 0x04 % 500 millis
    INTTIME_600MS = 0x05 % 600 millis
    GAIN_LOW      = 0x00
    GAIN_MED      = 0x10
    GAIN_HIGH     = 0x20
    GAIN_MAX      = 0x30
    GA            = 1.0   % Glass Attenuation (equals 1 if uncovered)
    % DF            = 408.0 % Device Factor (specific to TSL2591)
    % COEFA         = 1.00  % IR channel (ch0) coefficients
    % COEFB         = 1.64  % IR channel (ch0) coefficients
    % COEFC         = 0.59  % FULL channel (ch1) coefficients
    % COEFD         = 0.86  % FULL channel (ch1) coefficients
    DF            = 60    % Device Factor (specific to TSL2591)
    COEFA         = 1.00  % IR channel (ch0) coefficients
    COEFB         = 1.87  % IR channel (ch0) coefficients
    COEFC         = 0.63  % FULL channel (ch1) coefficients
    COEFD         = 1.00  % FULL channel (ch1) coefficients
  end
  methods
    function s = Sensor(setTime, setGain)
      arguments
        setTime = 0;
        setGain = 0;
      end
      switch setTime % How long the sensor collects light
        case s.INTTIME_100MS, s.aTime = 100.0;
        case s.INTTIME_200MS, s.aTime = 200.0;
        case s.INTTIME_300MS, s.aTime = 300.0;
        case s.INTTIME_400MS, s.aTime = 400.0;
        case s.INTTIME_500MS, s.aTime = 500.0;
        case s.INTTIME_600MS, s.aTime = 600.0;
        otherwise           , s.aTime = 100.0; % Default
      end
      switch setGain
        case s.GAIN_LOW , s.aGain = 1.0;
        case s.GAIN_MED , s.aGain = 25.0;
        case s.GAIN_HIGH, s.aGain = 428.0;
        case s.GAIN_MAX , s.aGain = 9876.0;
        otherwise       , s.aGain = 1.0; % Default
      end
    end
  end
end
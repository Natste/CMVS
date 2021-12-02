function [lux, luxIfBright, luxIfDim] = calculate_lux(Tsl, lum)
lumsize = size(lum);
lumel = numel(lum);
lum = uint32(lum(:))';
lum = struct(full=bitshift(lum, -16), ir=bitand(lum, 0x0000FFFF)); %comment

% Note: This algorithm is based on preliminary coefficients
% provided by AMS and may need to be updated in the future
countsPerLux = (Tsl.aTime * Tsl.aGain) / Tsl.DF;
luxIfBright   = (Tsl.COEFA * cast(lum.ir, 'single') - Tsl.COEFB * cast(lum.full, 'single')) / countsPerLux;
luxIfDim      = (Tsl.COEFC * cast(lum.ir, 'single') - Tsl.COEFD * cast(lum.full, 'single')) / countsPerLux;
lux      = max([luxIfBright ; luxIfDim ; zeros(1, lumel)]);

% Report overflows as -1

lux(lum.ir == 0xFFFF) = -1;
if sum(lux(lux == -1) > 0)
  warning("Overflow Detected");
end
lux = reshape(lux, lumsize);
end
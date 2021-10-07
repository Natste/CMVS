function [DATA_WINDOW, FILTER_WINDOW, I_DATA_END, I_DATA_START] = ensure_valid_sample(DATA_WINDOW, data, FILTER_WINDOW, I_DATA_END, I_DATA_START, I_DELTA)
if DATA_WINDOW > length(data)
    DATA_WINDOW = length(data);
    dataWindowWarn = sprintf("DATA_WINDOW exceeds length of data and has been trimmed");
else
    dataWindowWarn = sprintf('');
end
if FILTER_WINDOW > length(data)
    FILTER_WINDOW = length(data);
    filterWindowWarn = sprintf("FILTER_WINDOW exceeds length of data and has been trimmed");
else
    filterWindowWarn = sprintf('');
end
if I_DATA_END > length(data)
    I_DATA_END = length(data);
    I_DATA_START = max(I_DATA_END - I_DELTA, 1);
    dataEndWarn = sprintf("I_DATA_END exceeds length of data. Range parameters have been changed");
else
    dataEndWarn = sprintf('');
end
if ~ismissing([dataWindowWarn, filterWindowWarn, dataEndWarn])
    warning('\n\t%s\n\t%s\n\t%s', dataWindowWarn, filterWindowWarn, dataEndWarn);
end
end
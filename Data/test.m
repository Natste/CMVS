i = 0;
lastMat = 0;
while i < 5
    T = thingSpeakRead(1552033, ...
        Fields=[1], ...
        NumPoints=1, ...
        ReadKey='AD8ZB04MFD6HIYI8', ...
        OutputFormat='table');
    Tdat = T(:, {'cmvsData'});
    Tstr = rowfun(@string, Tdat);
    Tarr = Tstr{:,:};
    Cell = arrayfun(@(x) uint32(str2num(x)),Tarr,'uniform',0); %#ok<ST2NM>
    Mat = cell2mat(Cell);
    if ~isequal(Mat, lastMat)
        disp(Mat(end, :));
    else
        disp("same");
    end
    pause(1.5);
    i = i + 1;
    lastMat = Mat;
end % while

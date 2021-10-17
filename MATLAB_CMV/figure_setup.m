function figure_setup()
  SENSOR_STRINGS = [' S';'SW';'SE'
                    ' N';'NW';'NE'
                    ' O';' W';' E'];
  FIGURE_STRINGS  = ["data"
                    "dataSample"
                    "smoothSample"
                    "smoothSampleNorm"];
  SCALE = 150;
  FMT = struct;
  FMT.COLORORDER = colororder;
  FMT.AX.FontSize = 15;
  FMT.AX.FontWeight = 'bold';
  FMT.AX.YLim = [0 inf];
  FMT.POLAX.FontSize = 10;
  FMT.POLAX.FontWeight = 'normal';
  FMT.POLAX.ThetaTick = 0:15:360;
  FMT.POLAX.TickLabelInterpreter = 'tex';
  FMT.RTICKSET = @() set(gca, ...
    RTickLabel=strcat("\fontsize{7}", string(gca().RTickLabel)));

  BIN_EDGES = pi/8:pi/4:2*pi;
  POLAR_ORDER = [9 6 4 5 8 2 1 3];

  tickLabel = string(FMT.POLAX.ThetaTick);
  tickInc = round((length(FMT.POLAX.ThetaTick) - 1) / length(BIN_EDGES));
  idx = ~ismember(tickLabel(1:end-1), tickLabel(1:tickInc:end-1));
  tickLabel(idx) = strcat("\color{gray}\fontsize{7}", tickLabel(idx));
  % FMT.POLAX_DOTS = @(pax, rmax) polarplot(deg2rad(pax.BinEdges), ...
  %   repelem(rmax, length(pax.BinEdges)));
  FMT.POLAX.ThetaTickLabel = tickLabel;
  FMT.POLAX.TickLength = [0.2 0] ;
  FMT.POLAX.ThetaMinorTick = 'on' ;
  TILE.ROWS = 2;
  TILE.COLS = 3;
  TILE.LARGE_SPAN = [2 2];
  TILE.POS(1) = 1;
  TILE.POS(2) = 3;
  TILE.POS(3) = 6;
  FMT.TLO.Padding = 'compact';
  FMT.TLO.TileSpacing = 'compact';

  FMT.FIG.Units = 'Normalized';
  FMT.FIG.Visible = false;
  % FMT.FIG.OuterPosition = [0, 0.04, 0.25, 0.25];



CARDINAL.DEG = [...
    0  0  0
    2 48 45
    5 37 30
    8 26 15
   11 15  0
   14  3 45
   16 52 30
   19 41 15
   22 30  0
   25 18 45
   28  7 30
   30 56 15
   33 45  0
   36 33 45
   39 22 30
   42 11 15
   45  0  0
   47 48 45
   50 37 30
   53 26 15
   56 15  0
   59  3 45
   61 52 30
   64 41 15
   67 30  0
   70 18 45
   73  7 30
   75 56 15
   78 45  0
   81 33 45
   84 22 30
   87 11 15
   90  0  0
   92 48 45
   95 37 30
   98 26 15
  101 15  0
  104  3 45
  106 52 30
  109 41 15
  112 30  0
  115 18 45
  118  7 30
  120 56 15
  123 45  0
  126 33 45
  129 22 30
  132 11 15
  135  0  0
  137 48 45
  140 37 30
  143 26 15
  146 15  0
  149  3 45
  151 52 30
  154 41 15
  157 30  0
  160 18 45
  163  7 30
  165 56 15
  168 45  0
  171 33 45
  174 22 30
  177 11 15
  180  0  0
  182 48 45
  185 37 30
  188 26 15
  191 15  0
  194  3 45
  196 52 30
  199 41 15
  202 30  0
  205 18 45
  208  7 30
  210 56 15
  213 45  0
  216 33 45
  219 22 30
  222 11 15
  225  0  0
  227 48 45
  230 37 30
  233 26 15
  236 15  0
  239  3 45
  241 52 30
  244 41 15
  247 30  0
  250 18 45
  253  7 30
  255 56 15
  258 45  0
  261 33 45
  264 22 30
  267 11 15
  270  0  0
  272 48 45
  275 37 30
  278 26 15
  281 15  0
  284  3 45
  286 52 30
  289 41 15
  292 30  0
  295 18 45
  298  7 30
  300 56 15
  303 45  0
  306 33 45
  309 22 30
  312 11 15
  315  0  0
  317 48 45
  320 37 30
  323 26 15
  326 15  0
  329  3 45
  331 52 30
  334 41 15
  337 30  0
  340 18 45
  343  7 30
  345 56 15
  348 45  0
  351 33 45
  354 22 30
  357 11 15
  360  0  0];
CARDINAL.DEG(:,2) = CARDINAL.DEG(:,2)/60;
CARDINAL.DEG(:,3) = CARDINAL.DEG(:,3)/3600;
CARDINAL.DEG = sum(CARDINAL.DEG, 2);
CARDINAL.STR = [ ...
"   N"
"   N\frac{1/4}E"
"   N\frac{1/2}E"
"   N\frac{3/4}E"
" NbE"
" NbE\frac{1/4}E"
" NbE\frac{1/2}E"
" NbE\frac{3/4}E"
" NNE"
" NNE\frac{1/4}E"
" NNE\frac{1/2}E"
" NNE\frac{3/4}E"
"NEbN"
"  NE\frac{3/4}N"
"  NE\frac{1/2}N"
"  NE\frac{1/4}N"
"  NE"
"  NE\frac{1/4}E"
"  NE\frac{1/2}E"
"  NE\frac{3/4}E"
"NEbE"
"NEbE\frac{1/4}E"
"NEbE\frac{1/2}E"
"NEbE\frac{3/4}E"
" ENE"
" ENE\frac{1/4}E"
" ENE\frac{1/2}E"
" ENE\frac{3/4}E"
" EbN"
"   E\frac{3/4}N"
"   E\frac{1/2}N"
"   E\frac{1/4}N"
"   E"
"   E\frac{1/4}S"
"   E\frac{1/2}S"
"   E\frac{3/4}S"
" EbS"
" ESE\frac{3/4}E"
" ESE\frac{1/2}E"
" ESE\frac{1/4}E"
" ESE"
"SEbE\frac{3/4}E"
"SEbE\frac{1/2}E"
"SEbE\frac{1/4}E"
"SEbE"
"  SE\frac{3/4}E"
"  SE\frac{1/2}E"
"  SE\frac{1/4}E"
"  SE"
"  SE\frac{1/4}S"
"  SE\frac{1/2}S"
"  SE\frac{3/4}S"
"SEbS"
" SSE\frac{3/4}E"
" SSE\frac{1/2}E"
" SSE\frac{1/4}E"
" SSE"
" SbE\frac{3/4}E"
" SbE\frac{1/2}E"
" SbE\frac{1/4}E"
" SbE"
"   S\frac{3/4}E"
"   S\frac{1/2}E"
"   S\frac{1/4}E"
"   S"
"   S\frac{1/4}W"
"   S\frac{1/2}W"
"   S\frac{3/4}W"
" SbW"
" SbW\frac{1/4}W"
" SbW\frac{1/2}W"
" SbW\frac{3/4}W"
" SSW"
" SSW\frac{1/4}W"
" SSW\frac{1/2}W"
" SSW\frac{3/4}W"
"SWbS"
"  SW\frac{3/4}S"
"  SW\frac{1/2}S"
"  SW\frac{1/4}S"
"  SW"
"  SW\frac{1/4}W"
"  SW\frac{1/2}W"
"  SW\frac{3/4}W"
"SWbW"
"SWbW\frac{1/4}W"
"SWbW\frac{1/2}W"
"SWbW\frac{3/4}W"
" WSW"
" WSW\frac{1/4}W"
" WSW\frac{1/2}W"
" WSW\frac{3/4}W"
" WbS"
"   W\frac{3/4}S"
"   W\frac{1/2}S"
"   W\frac{1/4}S"
"   W"
"   W\frac{1/4}N"
"   W\frac{1/2}N"
"   W\frac{3/4}N"
" WbN"
" WNW\frac{3/4}W"
" WNW\frac{1/2}W"
" WNW\frac{1/4}W"
" WNW"
"NWbW\frac{3/4}W"
"NWbW\frac{1/2}W"
"NWbW\frac{1/4}W"
"NWbW"
"  NW\frac{3/4}W"
"  NW\frac{1/2}W"
"  NW\frac{1/4}W"
"  NW"
"  NW\frac{1/4}N"
"  NW\frac{1/2}N"
"  NW\frac{3/4}N"
"NWbN"
" NNW\frac{3/4}W"
" NNW\frac{1/2}W"
" NNW\frac{1/4}W"
" NNW"
" NbW\frac{3/4}W"
" NbW\frac{1/2}W"
" NbW\frac{1/4}W"
" NbW"
"   N\frac{3/4}W"
"   N\frac{1/2}W"
"   N\frac{1/4}W"
"   N"
];
  save figure_setup;
end
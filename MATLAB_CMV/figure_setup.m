function figure_setup();
  COMPASS_STRINGS = [' S';'SW';'SE'
                    ' N';'NW';'NE'
                    ' O';' W';' E'];
  FIGURE_STRINGS  = ["data"
                    "dataSample"
                    "smoothSample"
                    "smoothSampleNorm"];

  SCALE = 150;

  AX_FMT.FontSize = 15;
  AX_FMT.FontWeight = 'bold';
  AX_FMT.YLim = [0 inf];

  BIN_EDGES = pi/8:pi/4:2*pi;
  POLAR_ORDER = [9 6 4 5 8 2 1 3];
  POLAR_AX_FMT.ThetaTickLabel = COMPASS_STRINGS(POLAR_ORDER, :);
  POLAR_AX_FMT.FontSize = 12;
  POLAR_AX_FMT.FontWeight = 'bold';
  POLAR_AX_FMT.ThetaTick = 0:45:360;

  FIG_FMT.Units = 'Normalized';
  FIG_FMT.Visible = false;
  FIG_FMT.OuterPosition = [0, 0.04, 0.25, 0.25];

  save figure_setup;
end
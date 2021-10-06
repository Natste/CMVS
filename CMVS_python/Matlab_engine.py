import matlab.engine

import SELib
from win32com.client import Dispatch
import pythoncom

s = Dispatch("SESolver.StonerElectricSolver")
s.Init("", "kilowatt")

eng = matlab.engine.start_matlab()
eng.CMV_Main(nargout=0)
eng.quit()

del s
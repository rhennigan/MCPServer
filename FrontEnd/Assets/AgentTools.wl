<|
"AgentToolsStrings" -> {

	"prefsSubtitle" -> LanguageSwitched["LLMs and their calling harnesses can be configured to access your Wolfram System through either of the following toolsets:", <|
		"ChineseSimplified"  -> "LLMs and their calling harnesses can be configured to access your Wolfram System through either of the following toolsets:",
		"ChineseTraditional" -> "LLMs and their calling harnesses can be configured to access your Wolfram System through either of the following toolsets:",
		"French"             -> "LLMs and their calling harnesses can be configured to access your Wolfram System through either of the following toolsets:",
		"Japanese"           -> "LLMs and their calling harnesses can be configured to access your Wolfram System through either of the following toolsets:",
		"Korean"             -> "LLMs and their calling harnesses can be configured to access your Wolfram System through either of the following toolsets:",
		"Spanish"            -> "LLMs and their calling harnesses can be configured to access your Wolfram System through either of the following toolsets:"
	|>],
	
	"prefsDocsLinkText" -> LanguageSwitched["Documentation", <|
		"ChineseSimplified"  -> "Documentation",
		"ChineseTraditional" -> "Documentation",
		"French"             -> "Documentation",
		"Japanese"           -> "Documentation",
		"Korean"             -> "Documentation",
		"Spanish"            -> "Documentation"
	|>],
	
	"prefsComputationTools" -> LanguageSwitched["Computation Tools", <|
		"ChineseSimplified"  -> "Computation Tools",
		"ChineseTraditional" -> "Computation Tools",
		"French"             -> "Computation Tools",
		"Japanese"           -> "Computation Tools",
		"Korean"             -> "Computation Tools",
		"Spanish"            -> "Computation Tools"
	|>],
	
	"prefsComputationToolsDescription" -> LanguageSwitched["Tools for general computation and knowledge", <|
		"ChineseSimplified"  -> "Tools for general computation and knowledge",
		"ChineseTraditional" -> "Tools for general computation and knowledge",
		"French"             -> "Tools for general computation and knowledge",
		"Japanese"           -> "Tools for general computation and knowledge",
		"Korean"             -> "Tools for general computation and knowledge",
		"Spanish"            -> "Tools for general computation and knowledge"
	|>],
	
	"prefsDevelopmentTools" -> LanguageSwitched["Development Tools", <|
		"ChineseSimplified"  -> "Development Tools",
		"ChineseTraditional" -> "Development Tools",
		"French"             -> "Development Tools",
		"Japanese"           -> "Development Tools",
		"Korean"             -> "Development Tools",
		"Spanish"            -> "Development Tools"
	|>],
	
	"prefsDevelopmentToolsDescription" -> LanguageSwitched["Tools for Wolfram Language development", <|
		"ChineseSimplified"  -> "Tools for Wolfram Language development",
		"ChineseTraditional" -> "Tools for Wolfram Language development",
		"French"             -> "Tools for Wolfram Language development",
		"Japanese"           -> "Tools for Wolfram Language development",
		"Korean"             -> "Tools for Wolfram Language development",
		"Spanish"            -> "Tools for Wolfram Language development"
	|>],
	
	"prefsHarnessesConfigured" -> LanguageSwitched["Configured:", <|
		"ChineseSimplified"  -> "Configured:",
		"ChineseTraditional" -> "Configured:",
		"French"             -> "Configured:",
		"Japanese"           -> "Configured:",
		"Korean"             -> "Configured:",
		"Spanish"            -> "Configured:"
	|>],
	
	"prefsHarnessesMore" -> LanguageSwitched["More:", <|
		"ChineseSimplified"  -> "More:",
		"ChineseTraditional" -> "More:",
		"French"             -> "More:",
		"Japanese"           -> "More:",
		"Korean"             -> "More:",
		"Spanish"            -> "More:"
	|>],

	"prefsPickTool" -> LanguageSwitched["Pick a toolset", <|
		"ChineseSimplified"  -> "Pick a toolset",
		"ChineseTraditional" -> "Pick a toolset",
		"French"             -> "Pick a toolset",
		"Japanese"           -> "Pick a toolset",
		"Korean"             -> "Pick a toolset",
		"Spanish"            -> "Pick a toolset"
	|>],
	
	"prefsNoTool" -> LanguageSwitched["No toolset", <|
		"ChineseSimplified"  -> "No toolset",
		"ChineseTraditional" -> "No toolset",
		"French"             -> "No toolset",
		"Japanese"           -> "No toolset",
		"Korean"             -> "No toolset",
		"Spanish"            -> "No toolset"
	|>],

	"prefsInstallLocation" -> LanguageSwitched["Install location:", <|
		"ChineseSimplified"  -> "Install location:",
		"ChineseTraditional" -> "Install location:",
		"French"             -> "Install location:",
		"Japanese"           -> "Install location:",
		"Korean"             -> "Install location:",
		"Spanish"            -> "Install location:"
	|>],
	
	"prefsSpecificDirectories" -> LanguageSwitched["Settings for specific directories:", <|
		"ChineseSimplified"  -> "Settings for specific directories:",
		"ChineseTraditional" -> "Settings for specific directories:",
		"French"             -> "Settings for specific directories:",
		"Japanese"           -> "Settings for specific directories:",
		"Korean"             -> "Settings for specific directories:",
		"Spanish"            -> "Settings for specific directories:"
	|>],
	
	"prefsUninstallTool" -> LanguageSwitched["Uninstall this toolset", <|
		"ChineseSimplified"  -> "Uninstall this toolset",
		"ChineseTraditional" -> "Uninstall this toolset",
		"French"             -> "Uninstall this toolset",
		"Japanese"           -> "Uninstall this toolset",
		"Korean"             -> "Uninstall this toolset",
		"Spanish"            -> "Uninstall this toolset"
	|>]
	
},


(************************************************************************************)


"AgentToolsExpressions" -> {



"prefsDownPointer" -> (GraphicsBox[
  {#1, LineBox[{{0, 0.75}, {0.5, 0.25}, {1, 0.75}}]},
  ImageSize->#2,
  PlotRange->{0, 1}]&),


"prefsRemoveIcon" -> (GraphicsBox[
  {#1, LineBox[{{{0, 0}, {1, 1}}, {{1, 0}, {0, 1}}}]},
  ImageSize->#2,
  PlotRange->{-0.25, 1.25}]&),


(*
"prefsRestoreIcon" -> (GraphicsBox[
  {#1, Arrowheads[{{0.5, Automatic}}], 
   ArrowBox[CircleBox[{0, 0}, 1, NCache[{Rational[-3, 4] Pi, Rational[3, 4] Pi}, {-2.356194490192345, 2.356194490192345}]]]},
  ImageSize->#2,
  PlotRange->{-1.5, 1.5}]&),
*)
  
"prefsInfoIcon" -> (GraphicsBox[
   {Thickness[0.05555555555555555], FaceForm[{#1, Opacity[1.]}], 
    FilledCurveBox[{{{1, 4, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 
      3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}}, {{0, 2, 0}, {1, 3, 3}, {0, 1, 0}, {1, 3, 
      3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 
      3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {
      1, 3, 3}, {1, 3, 3}, {1, 3, 3}, {0, 1, 0}, {1, 3, 3}, {1, 3, 3}}, {{1, 4, 3}, {1, 3, 3}, {1, 3, 
      3}, {1, 3, 3}}, {{1, 4, 3}, {1, 3, 3}, {1, 3, 3}, {1, 3, 3}}}, {CompressedData["
1:eJxTTMoPSmViYGBQBWIQzQjEDAeUHYJZF0+yeqjpUGTLdX1xAYL/9e+Vipdq
yg4rhS+43Lig6bB/vpT+3SdKDgXx7OckN2o6pKcBwTIlh3uFXX1PJsH0KznE
3nFjrsjWdAjsnZ4n5KzkAFQdeMta02Gx67bPf0WUHFQ06np2cms6/AcZ/1HR
IfCWdE3iJQ2HvSWTJViuKTqYrbYLj56o4aBy+2dd1h5FB5maRKPQAA2HcD7d
TXPXKzpEtllcO8qL4IPNO60O5595d/Kwk6+6gzcPk3Y70LzP8pfy45+rORhx
rJGJUlFyADlHeo4axP5CJYj9QWpQ9UoOIO8z6qo5PPAHeiBIGc4vEGo+cGoh
gv82cIdc62tlB6W/30of2Kg5KG0oypioq+IQvXH/m3kxag7sjVOdu3NUHKpA
HqpWc5C4ee578GIVB7Hfp9+dXKzmcEwBqOGiisOeaRP4q66pOURabjlR9k/F
wZ25gluFQ93h78qPl3yVVB3+KwItcFB3mAY07bm1qoONzpVZz2rVIeEVpuqw
fkpqR/JedYj5yaoOUiAPMWrA+TuzOX8ucEfwl7/w0Pt/UANuHlB37B01TQeb
+0APv1NxAHlnTqEm1L8qkPjbrekwHaxeBZ4+0NMPAMZ/8s8=
      "], CompressedData["
1:eJxdVA1MU1cYJQaZVGWMvpb3A/heX1fNkBj5EQlBTgFnNGgmGEeqU8KQMlYF
RcXJRIWgsqHMGKZG2MAfokQZkM4ZrIhd8Yds4lRCCGGKQogWjBpFmXN6Ly19
yW7SNCfvfd93zvnOfVJGbsq6SV5eXsnkR/+/tm0+xCbJYA2pk09s0mNty+Jp
k5yiB+ccHPk2/lcF73EuvxBSKsKRcO6rv5fr8e7utkeGjSKuro/c9ZuohynG
en1rq4DI49bo18UC6vLiVN0nBJi7hnJC5wmwkfahewVogm8Mxg/wKKlM/N5i
FpB2OurP2AM8HC9nra5IEFAQJs14MZtHuTF98JZOQGHJnOS6Dg7dZNzcKQJI
d3tmDocnlI6Txx3bQybYl0OZtufmqzs8rrVc2O/TyGJzNhFwmUd9+oqUmeks
Rt8SwnU8vqED3wSi6ig9PCidkz8r+A9/0mGpggn70cPVWjAlbR217TzItBuD
7zQYJmzOBgnwq4o4bi3QIM0vrLk6V0BPHJnwkkFDkCkz9p6A/O6A58YKBsui
y4zp64LQm+2VuzuJgR9xQ9sTBCpP5cPgxe2lGf5pwSg1EUV31RjYzjQs6g9G
ODXEqnbXh4B5buzMqlS7/BsKQTGt3zPxfIYHm7PIMYge/JjyrRJRp/r04y12
NVKpfR9J2O3dXjE3msGPtF2hBGpvfQ2DySuJoD4JRQ3nM3ZyGtg7aheej9C5
/dDgS/+0GOs+net9UYsf7GSBnW5co8VFuu8PZHd9IPbR/aTKLv2OQERGkJMv
g67bomU9WF5CNl6uYEqvYD2HvACyAEnGvVbi+AMOV8XGTdl/6Tx4OvXzqILD
yXZMmTokdGZ1DdVzeEXiZY/S4fMdhFA8h+/G86VD36G9pSY1hyMbyADVRD2L
7TRuwxKM4/UsNgy9OfPstoRfiJyeHSx4b2qQhM/+ZfO7U1gUxUetaSmT8MV/
if+MhLKodlCCkkvPNBa+lE6s5Mmfhd4/bwUXj+9T9OD5ZZSgiBFnW4ysYqHv
HSvKsYmgceo0sJ77SccHhE/wEdHU/6iyOVnBH47nU8GuPCr1pPuSwt9ZLO4n
gbsmgsarayaHRGpP78T7HAZOHXOIT0UQdc62MQ61/Jw+vY+ETHrBzDwWkNue
d0mG7u3olvs2GVuJupU3ZbReCTSkDsqYSh7Hdciw+I7VmNV6lFuIoU0yPjmj
vpU0X+/en4xVTZeHf1qtd83LU75P//9evQc62+ka
      "], {{9.000000000000002, 3.155900000000001}, {
      5.777000000000002, 3.155900000000001}, {3.1560000000000015`, 5.7769}, {3.1560000000000015`, 
      8.9999}, {3.1560000000000015`, 12.2229}, {5.777000000000002, 14.8439}, {9.000000000000002, 
      14.8439}, {12.223000000000003`, 14.8439}, {14.844000000000001`, 12.2229}, {14.844000000000001`, 
      8.9999}, {14.844000000000001`, 5.7769}, {12.223000000000003`, 3.155900000000001}, {
      9.000000000000002, 3.155900000000001}}, {{9.000000000000002, 15.9999}, {5.141000000000002, 
      15.9999}, {2.0000000000000018`, 12.8599}, {2.0000000000000018`, 8.9999}, {2.0000000000000018`, 
      5.140899999999999}, {5.141000000000002, 1.9999000000000002`}, {9.000000000000002, 
      1.9999000000000002`}, {12.859000000000002`, 1.9999000000000002`}, {16., 5.140899999999999}, {16.,
       8.9999}, {16., 12.8599}, {12.859000000000002`, 15.9999}, {9.000000000000002, 15.9999}}}]},
   AspectRatio->Automatic,
   ImageSize->#2,
   PlotRange->{{0., 18.}, {0., 18.}}] & )


}
|>

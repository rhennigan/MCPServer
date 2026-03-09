(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Graphics`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument Patterns*)
$$graphicsPattern = HoldPattern @ Alternatives[
    _System`AstroGraphics,
    _GeoGraphics,
    _Graphics,
    _Graphics3D,
    _Image,
    _Image3D,
    _Legended,
    Dynamic[ RawBoxes[ _FEPrivate`ImportImage ], ___ ]
];

$$definitelyNotGraphics = HoldPattern @ Alternatives[
    _Association,
    _CloudObject,
    _File,
    _List,
    _String,
    _URL,
    Null,
    True|False
];

$$graphicsBoxIgnoredHead = HoldPattern @ Alternatives[
    BoxData,
    Cell,
    FormBox,
    PaneBox,
    StyleBox,
    TagBox
];

$$graphicsBoxIgnoredTemplates = Alternatives[
    "Labeled",
    "Legended"
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*graphicsQ*)
graphicsQ // beginDefinition;
graphicsQ[ $$graphicsPattern       ] := True;
graphicsQ[ $$definitelyNotGraphics ] := False;
graphicsQ[ RawBoxes[ boxes_ ]      ] := graphicsBoxQ @ Unevaluated @ boxes;
graphicsQ[ Labeled[ g_, ___ ]      ] := graphicsQ @ Unevaluated @ g;
graphicsQ[ g_                      ] := MatchQ[ Quiet @ Show @ Unevaluated @ g, $$graphicsPattern ];
graphicsQ[ ___                     ] := False;
graphicsQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*graphicsBoxQ*)
graphicsBoxQ // beginDefinition;
graphicsBoxQ[ _GraphicsBox|_Graphics3DBox ] := True;
graphicsBoxQ[ $$graphicsBoxIgnoredHead[ box_, ___ ] ] := graphicsBoxQ @ Unevaluated @ box;
graphicsBoxQ[ TemplateBox[ { box_, ___ }, $$graphicsBoxIgnoredTemplates, ___ ] ] := graphicsBoxQ @ Unevaluated @ box;
graphicsBoxQ[ RowBox[ boxes_List ] ] := AnyTrue[ boxes, graphicsBoxQ ];
graphicsBoxQ[ TemplateBox[ boxes_List, "RowDefault", ___ ] ] := AnyTrue[ boxes, graphicsBoxQ ];
graphicsBoxQ[ GridBox[ boxes_List, ___ ] ] := AnyTrue[ Flatten @ boxes, graphicsBoxQ ];
graphicsBoxQ[ StyleBox[ _, "GraphicsRawBoxes", ___ ] ] := True;
graphicsBoxQ[ ___ ] := False;
graphicsBoxQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[ Null ];

End[ ];
EndPackage[ ];

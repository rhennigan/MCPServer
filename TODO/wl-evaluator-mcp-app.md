```wl
In[1]:=
$deployedNotebookRoot = "MCPServer/Notebooks";
$outputSizeLimit = 100000; (* max size in bytes before output boxes get shortened *)

In[3]:=
toOutputBoxes//ClearAll;
toOutputBoxes[(HoldForm | HoldCompleteForm)[expr_]] := Block[{$OutputSizeLimit = $outputSizeLimit}, ToBoxes[OutputSizeLimit`PrePrint[expr]]];
```

Example input string (that produces interactive content):

```wl
In[5]:= in = "ResourceData[\"Demonstration: Rotating the Hopf Fibration\"]";
```

We need both the string representation and the output expression (since we need to create formatted boxes):

```wl
In[6]:= as = Wolfram`Chatbook`WolframLanguageToolEvaluate[in, {"String", "Result"}];

In[8]:= string = as["String"]

Out[8]= "Out[1]= ![Embedded Interactive Content](dynamic://content-30zyd)"
```

Get cell labels:

```wl
In[9]:= outLabel = Last[StringCases[string, "Out[" ~~ DigitCharacter.. ~~ "]="]]

Out[9]= "Out[1]="

In[10]:= inLabel = StringReplace[outLabel, "Out[" ~~ n : DigitCharacter.. ~~ "]=" :> "In[" <> n <> "]:="]

Out[10]= "In[1]:="
```

Create the input cell:

```wl
In[11]:= inputCell = Cell[BoxData[Wolfram`Chatbook`StringToBoxes[in, "WL"]], "Input", CellLabel -> inLabel]

Out[11]= Cell[BoxData[RowBox[{"ResourceData", "[", "\"Demonstration: Rotating the Hopf Fibration\"", "]"}]], "Input", CellLabel -> "In[1]:="]
```

Create the output cell:

```wl
In[12]:= outputCell = Cell[BoxData[toOutputBoxes[as["Result"]]], "Output", CellLabel -> outLabel]

Out[12]= Cell[BoxData[TagBox[StyleBox[ <<1>> ], Manipulate`InterpretManipulate[1]]], "Output", CellLabel -> "Out[1]="]
```

Create and deploy the notebook:

```wl
In[13]:= notebook = Notebook[{inputCell, outputCell}, CellLabelAutoDelete -> False];

In[14]:= hash = Hash[as, "Expression", "HexString"]

Out[14]= "2263e9452b8dd774"

In[15]:=
target = FileNameJoin@{
	CloudObject[$deployedNotebookRoot, Permissions -> {"All" -> {"Read", "Interact"}}],
	"WolframLanguageEvaluator",
	StringTake[hash, 3],
	hash <> ".nb"
	}

Out[15]=
CloudObject["https://www.wolframcloud.com/obj/rhennigan/MCPServer/Notebooks/WolframLanguageEvaluator/226/2263e9452b8dd774.nb", Permissions -> {"All" -> {"Read", "Interact"}}]

In[16]:= obj = CloudDeploy[notebook, target, Permissions -> {"All" -> {"Read", "Interact"}}, AutoRemove -> True, IconRules -> {}]

Out[16]=
CloudObject["https://www.wolframcloud.com/obj/rhennigan/MCPServer/Notebooks/WolframLanguageEvaluator/226/2263e9452b8dd774.nb"]
```
BeginPackage[ "Wolfram`MCPServer`Common`" ];

`$aliasToCanonicalName;
`$catching;
`$catchTopTag;
`$cloudNotebooks;
`$debug;
`$defaultMCPServer;
`$deploymentsPath;
`$imagePath;
`$mcpEvaluation;
`$objectVersion;
`$pacletVersion;
`$rootPath;
`$serverVersion;
`$storagePath;
`$supportedMCPClients;
`$thisPaclet;
`addToMXInitialization;
`beginDefinition;
`catchAlways;
`catchMine;
`catchTop;
`catchTopAs;
`chatbookVersionCheck;
`defaultEnvironment;
`directoryQ;
`endDefinition;
`endExportedDefinition;
`ensureDirectory;
`ensureFilePath;
`ensureMCPServerExists;
`fileNameJoin;
`fileQ;
`getLLMKitInfo;
`getWolframCommand;
`importResourceFunction;
`initializeVectorDatabases;
`llmKitSubscribedQ;
`makeDeploymentBoxes;
`makeMCPServerObjectBoxes;
`mcpServerDirectory;
`mcpServerFile;
`mcpServerInstallations;
`mcpServerLogFile;
`messageFailure;
`messagePrint;
`readRawJSONFile;
`readWXFFile;
`relatedDocumentation;
`relatedWolframAlphaResults;
`relatedWolframContext;
`throwFailure;
`throwInternalFailure;
`throwTop;
`validateMCPServerObjectData;
`writeRawJSONFile;
`writeWXFFile;

(* TOML support for Codex: *)
`getMCPServers;
`readTOMLFile;
`removeMCPServer;
`setMCPServer;
`writeTOMLFile;

(* Shared symbols with Tools subcontexts: *)
`exportMarkdownString;

(* Shared symbols with DeployAgentTools: *)
`guessClientName;
`installLocation;
`projectInstallLocation;
`toInstallName;

(* Graphics detection and conversion: *)
`graphicsQ;
`graphicsToImageContent;

(* WolframAlpha image extraction: *)
`extractWolframAlphaImages;

(* Internal failure formatting: *)
`$internalFailureLogPath;
`extractFailureTag;
`formatInternalFailureForMCP;
`generateUniqueFailureFileName;
`cleanupOldFailureLogs;

(* Output logging: *)
`$outputLogDirectory;
`outputLogFile;
`cleanupOldOutputLogs;

(* Logging utilities: *)
`debugPrint;
`writeError;

(* MCP Apps / UI resources: *)
`$clientSupportsUI;
`$uiResourceRegistry;
`$toolUIAssociations;
`clientSupportsUIQ;
`mcpAppsEnabledQ;
`initializeUIResources;
`listUIResources;
`loadUIResource;
`readUIResource;
`toolUIMetadata;
`withToolUIMetadata;

(* Tool options: *)
`$toolOptions;
`$defaultToolOptions;
`toolOptionValue;

(* Paclet extension support: *)
`clearPacletDefinitionCache;
`ensurePacletForInstall;
`findAgentToolsPaclets;
`findInstalledPaclet;
`findRemoteAgentToolsPaclets;
`getAgentToolsDeclaredItems;
`getAgentToolsExtension;
`getAgentToolsExtensionData;
`getAgentToolsExtensionDirectory;
`loadPacletDefinitionFile;
`pacletQualifiedNameQ;
`parsePacletQualifiedName;
`resolvePacletPrompt;
`resolvePacletServer;
`resolvePacletTool;

EndPackage[ ];
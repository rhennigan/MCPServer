BeginPackage[ "Wolfram`MCPServer`Common`" ];

`$catching;
`$catchTopTag;
`$cloudNotebooks;
`$debug;
`$defaultMCPServer;
`$imagePath;
`$objectVersion;
`$pacletVersion;
`$rootPath;
`$serverVersion;
`$storagePath;
`$thisPaclet;
`addToMXInitialization;
`beginDefinition;
`catchAlways;
`catchMine;
`catchTop;
`catchTopAs;
`chatbookVersionCheck;
`directoryQ;
`endDefinition;
`endExportedDefinition;
`ensureDirectory;
`ensureFilePath;
`ensureMCPServerExists;
`fileNameJoin;
`fileQ;
`getLLMKitInfo;
`defaultEnvironment;
`getWolframCommand;
`importResourceFunction;
`initializeVectorDatabases;
`llmKitSubscribedQ;
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

EndPackage[ ];
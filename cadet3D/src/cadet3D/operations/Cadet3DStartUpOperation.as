// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

// For use when loading CadetScenes outside of the CadetEditor, e.g. in a Flash Builder project.
package cadet3D.operations
{
	import cadet.core.ICadetScene;
	import cadet.operations.CadetStartUpOperationBase;
	import cadet.operations.ReadCadetFileAndDeserializeOperation;
	
	import cadet3D.resources.ExternalAway3DResourceParser;
	
	import flash.events.Event;
	
	import flox.app.FloxApp;
	import flox.app.controllers.ExternalResourceController;
	import flox.app.entities.URI;
	import flox.app.managers.fileSystemProviders.url.URLFileSystemProvider;
	import flox.app.operations.CompoundOperation;
	import flox.app.operations.LoadManifestsOperation;
	import flox.app.resources.ExternalResourceParserFactory;
	
	public class Cadet3DStartUpOperation extends CadetStartUpOperationBase
	{	
		public function Cadet3DStartUpOperation( cadetFileURL:String)
		{
			super(cadetFileURL);
			
			addManifest( baseManifestURL + "Flox.xml");
			addManifest( baseManifestURL + "Cadet.xml");
			addManifest( baseManifestURL + "Cadet3D.xml");
		}
		
		override public function execute():void
		{
			// Initialise the FloxApp (resourceManager, fileSystemProvider)
			FloxApp.init();
			
			// Register a URLFileSystemProvider with the FloxApp
			FloxApp.fileSystemProvider.registerFileSystemProvider( new URLFileSystemProvider( fspID, fspID, baseURL ) );
			
			// Create an ExternalResourceController to monitor external resources
			new ExternalResourceController( FloxApp.resourceManager, new URI(fspID+"/"+assetsURL), FloxApp.fileSystemProvider );

			// Add ExternalAway3DResourceParser to handle .3ds & .obj files.
			FloxApp.resourceManager.addResource( new ExternalResourceParserFactory( ExternalAway3DResourceParser, "External Away3D Resource Parser", ["obj", "3ds"] ) );
			
			// Specify which manifests to load
			var config:XML = createConfigXML();
			
			// Load manifests
			var loadManifestsOperation:LoadManifestsOperation = new LoadManifestsOperation(config.manifest);
			addOperation(loadManifestsOperation);
			
			// Read and deserialize the Cadet XML into a CadetScene
			var uri:URI = new URI(fspID+cadetFileURL);
			readAndDeserializeOperation = new ReadCadetFileAndDeserializeOperation( uri, FloxApp.fileSystemProvider, FloxApp.resourceManager );
			addOperation(readAndDeserializeOperation);
			
			super.execute();
		}
	}
}











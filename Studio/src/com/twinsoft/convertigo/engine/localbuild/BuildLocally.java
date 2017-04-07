/*
 * Copyright (c) 2001-2011 Convertigo SA.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Affero General Public License
 * as published by the Free Software Foundation; either version 3
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see<http://www.gnu.org/licenses/>.
 *
 * $URL: http://sourceus/svn/convertigo/CEMS_opensource/branches/6.3.x/Studio/src/com/twinsoft/convertigo/eclipse/popup/actions/TestCaseExecuteSelectedAction.java $
 * $Author: maximeh $
 * $Revision: 33944 $
 * $Date: 2013-04-05 18:29:40 +0200 (ven., 05 avr. 2013) $
 */

package com.twinsoft.convertigo.engine.localbuild;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.io.FileUtils;
import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.traversal.NodeIterator;

import com.twinsoft.convertigo.beans.core.MobileApplication;
import com.twinsoft.convertigo.beans.core.MobilePlatform;
import com.twinsoft.convertigo.beans.mobileplatforms.Android;
import com.twinsoft.convertigo.beans.mobileplatforms.IOs;
import com.twinsoft.convertigo.beans.mobileplatforms.Windows;
import com.twinsoft.convertigo.beans.mobileplatforms.WindowsPhone8;
import com.twinsoft.convertigo.engine.Engine;
import com.twinsoft.convertigo.engine.admin.services.mobiles.MobileResourceHelper;
import com.twinsoft.convertigo.engine.util.ProcessUtils;
import com.twinsoft.convertigo.engine.util.TwsCachedXPathAPI;
import com.twinsoft.convertigo.engine.util.XMLUtils;

public abstract class BuildLocally {

	private static final String cordovaDir = "cordova";
	/** know which icon goes with which name on ios platform in function of height and width */
	// private static final Map<String, String> iOSIconsCorrespondences;
	/** know which splash goes with which name on ios platform in function of height and width */
	// private static final Map<String, String> iOSSplashCorrespondences;
	
	/** Mobile platform */
	private MobilePlatform mobilePlatform = null;
	
	// For minimal version of cordova required 3.4.x
	private final int versionMinimalRequiredDecimalPart = 3;
	private final int versionMinimalRequiredFractionalPart = 4;
	
	private String cmdOutput;
	private String cordovaVersion = null;
	private String errorLines = null;
	
	private boolean processCanceled = false;
	private Process process;
    
	private OS osLocal = null;
	
	private final static String cordovaInstallsPath = Engine.USER_WORKSPACE_PATH + File.separator + "cordovas";
	private String cordovaBinPath;
	
	private enum OS {
		generic,
		linux,
		mac,
		win32,
		solaris;
	}
	
	public BuildLocally(MobilePlatform mobilePlatform) {
		this.mobilePlatform = mobilePlatform;
		this.cordovaBinPath = null;
		File cordovaInstallsDir = new File(BuildLocally.cordovaInstallsPath);
		if (!cordovaInstallsDir.exists()) {
			cordovaInstallsDir.mkdir();
		}
	}

	private String runCommand(File launchDir, String command, List<String> parameters, boolean mergeError) throws Throwable {
		if (command.equals("cordova") && Engine.isWindows()) {
			command += ".cmd";
		}
		parameters.add(0, command);
		ProcessBuilder pb = command.equals("npm") ?
				ProcessUtils.getNpmProcessBuilder(getLocalBuildAdditionalPath(), parameters)
				: ProcessUtils.getProcessBuilder(getLocalBuildAdditionalPath(), parameters);
		// Set the directory from where the command will be executed
		pb.directory(launchDir.getCanonicalFile());
		
		pb.redirectErrorStream(mergeError);
		
		Engine.logEngine.info("Executing command : " + parameters);
		
		process = pb.start();
		
		cmdOutput = "";
		// Logs the output
		Engine.execute(new Runnable() {
			@Override
	        public void run() {
				try {
					String line;
					processCanceled = false;
					
					BufferedReader bis = new BufferedReader(new InputStreamReader(process.getInputStream()));
					while ((line = bis.readLine()) != null) {
						Engine.logEngine.info(line);
						BuildLocally.this.cmdOutput += line;
					}
				} catch (IOException e) {
					Engine.logEngine.error("Error while executing command", e);
				}
			}
		});
		
		if (!mergeError) {
			// Logs the error output
			new Thread(new Runnable() {
				@Override
		        public void run() {
					try {
						String line;
						processCanceled = false;
						
						BufferedReader bis = new BufferedReader(new InputStreamReader(process.getErrorStream()));
						while ((line = bis.readLine()) != null) {
							Engine.logEngine.error(line);
							errorLines += line;
						}
					} catch (IOException e) {
						Engine.logEngine.error("Error while executing command", e);
					}
				}
			}).start();			
		}
		
		int exitCode = process.waitFor();
		
		if (exitCode != 0 && exitCode != 127) {
			throw new Exception("Exit code " + exitCode + " when running the command '" + command + 
					"' with parameters : '" + parameters + "'. The output of the command is : '" 
					 + cmdOutput + "'");
		}
		
		
		return cmdOutput;
	}
	
	/***
	 * Function which permit to run cordova command
	 * @param projectDir
	 * @param commands
	 * @return
	 * @throws Throwable
	 */
	private String runCordovaCommand(File projectDir, String... commands) throws Throwable {
		List<String> commandsList = new LinkedList<String>();
		Collections.addAll(commandsList, commands);
		return runCordovaCommand(projectDir, commandsList);
	}
	
	/***
	 * Runs a Cordova command and returns the output stream. This will wait until the command is finished. 
	 * Output stream and error stream are logged in  the console.
	 * @param Command
	 * @param projectDir
	 * @return
	 * @throws Throwable
	 */
	private String runCordovaCommand(File projectDir, List<String> cordovaCommands) throws Throwable {
		
		String command = "cordova";
		if (this.cordovaBinPath != null) {
			command = this.cordovaBinPath;
		}
		
		return this.runCommand(projectDir, command, cordovaCommands, false);
	}
		
	/***
	 * Explore "config.xml", handle plugins and copy needed resources to appropriate platforms folders.
	 * @param wwwDir
	 * @param platform
	 * @param cordovaDir
	 */
	private void processConfigXMLResources(File wwwDir, File cordovaDir) throws Throwable {
		try {
			
			File configFile = new File(cordovaDir, "config.xml");
			Document doc = XMLUtils.loadXml(configFile);
			
			TwsCachedXPathAPI xpathApi = new TwsCachedXPathAPI();
			
			Element singleElement = (Element) xpathApi.selectSingleNode(doc, "/widget/preference[@name='phonegap-version']");
			
			// Changes icons and splashs src in config.xml file because it was moved to the parent folder
			NodeIterator nodeIterator = xpathApi.selectNodeIterator(doc, "//*[local-name()='splash' or local-name()='icon']");
			singleElement = (Element) nodeIterator.nextNode();
			while (singleElement != null) {
				String src = singleElement.getAttribute("src");
				src = "www/" + src;
				File file = new File(cordovaDir, src);
				if (file.exists()) {
					singleElement.setAttribute("src", src);
				}
				
				singleElement = (Element) nodeIterator.nextNode();
			}

			//ANDROID
			if (mobilePlatform instanceof Android) {
				singleElement = (Element) xpathApi.selectSingleNode(doc, "/widget/name");
				if (singleElement != null) {
					String name = singleElement.getTextContent();
					name = name.replace("\\", "\\\\");
					name = name.replace("'", "\\'");
					name = name.replace("\"", "\\\"");
					singleElement.setTextContent(name);
				}
			}
			
			//iOS
//			if (mobilePlatform instanceof  IOs) {			
//			}
			
			//WINPHONE
			if (mobilePlatform instanceof WindowsPhone8) {				

				// Without these width and height the local build doesn't work but with these the remote build doesn't work
				singleElement = (Element) xpathApi.selectSingleNode(doc, "/widget/platform[@name='wp8']/icon[not(@role)]");
				if (singleElement != null) {
					singleElement.setAttribute("width", "99");
					singleElement.setAttribute("height", "99");	
				}
				
				singleElement = (Element) xpathApi.selectSingleNode(doc, "/widget/platform[@name='wp8']/icon[@role='background']");
				if (singleElement != null) {
					singleElement.setAttribute("width", "159");
					singleElement.setAttribute("height", "159");
				}	
				
				// /widget/platform[@name='wp8']/splash
				singleElement = (Element) xpathApi.selectSingleNode(doc, "/widget/platform/splash");
				if (singleElement != null) {
					singleElement.setAttribute("width", "768");
					singleElement.setAttribute("height", "1280");
				}
				
				singleElement = (Element) xpathApi.selectSingleNode(doc, "/widget/plugin[@name='phonegap-plugin-push']/param[@name='SENDER_ID']");
				if (singleElement != null) {
					// Remote build needs a node named 'param' and local build needs a node named 'variable'
					singleElement.getParentNode().appendChild(cloneNode(singleElement, "variable"));
					singleElement.getParentNode().removeChild(singleElement);
				}
			}

//			if (mobilePlatform instanceof Windows) {
				// TODO : Add platform Windows 8
//			}

			// XMLUtils.saveXml(doc, configFile.getAbsolutePath());
			
			// We have to add the root config.xml all our app's config.xml preferences.
			// Cordova will use this file to generates the platform specific config.xml
			
			// Get preferences from current config.xml
			NodeIterator preferences = xpathApi.selectNodeIterator(doc, "//preference");
			// File configFile = new File(cordovaDir, "config.xml");
			
			// doc = XMLUtils.loadXml(configFile);  // The root config.xml
			
			NodeList preferencesList = doc.getElementsByTagName("preference");
			
			// Remove old preferences
			while ( preferencesList.getLength() > 0 ) { 
	            Element pathNode = (Element) preferencesList.item(0);
	            // Remove empty lines
	            Node prev = pathNode.getPreviousSibling();
	            if (prev != null && prev.getNodeType() == Node.TEXT_NODE &&
	                prev.getNodeValue().trim().length() == 0) {
	            		doc.getDocumentElement().removeChild(prev);
	            }
	            doc.getDocumentElement().removeChild(pathNode);
	        }
			
			for (Element preference = (Element) preferences.nextNode(); preference != null; preference = (Element) preferences.nextNode()) {
				String name = preference.getAttribute("name");
				String value = preference.getAttribute("value");
				
				Element elt = doc.createElement("preference");
				elt.setAttribute("name", name);
				elt.setAttribute("value", value);
				
				Engine.logEngine.info("Adding preference'" + name + "' with value '" + value + "'");
				
				doc.getDocumentElement().appendChild(elt);
			}	
			
			Engine.logEngine.trace("New config.xml is: " + XMLUtils.prettyPrintDOM(doc));
			File resXmlFile = new File(cordovaDir, "config.xml");
			// FileUtils.deleteQuietly(resXmlFile);
			XMLUtils.saveXml(doc, resXmlFile.getAbsolutePath());
			
			// Last part, as all resources has been copied to the correct location, we can remove
			// our "www/res" directory before packaging to save build time and size...
			// FileUtils.deleteDirectory(new File(wwwDir, "res"));
			
		} catch (Exception e) {
			logException(e, "Unable to process config.xml in your project, check the file's validity");
		}
	}
	
	private static Element cloneNode(Node node, String newNodeName) {
		
		Element newElement = node.getOwnerDocument().createElement(newNodeName);
		
		NamedNodeMap attrs = node.getAttributes();
	    for (int i = 0; i < attrs.getLength(); i++) {
	    	Attr attr = (Attr) attrs.item(i);
	    	newElement.setAttribute(attr.getName(), attr.getValue());
	    }
	    
	    return newElement;
		
	}
	
	/**
	 * Check is the current os can build the specified platform.
	 * @param platform
	 * @return
	 * @throws Throwable 
	 */
	public boolean checkPlatformCompatibility() throws Throwable {	    
		// Implement Compatibility matrix
		// Step 1: Check cordova version, compatibility over 3.4.x
		String version = getCordovaVersion();
		
		Pattern pattern = Pattern.compile("^(\\d)+\\.(\\d)+\\.");
		Matcher matcher = pattern.matcher(version);
		
		if (matcher.find()){
			// We check first just the decimal part
			if (Integer.parseInt(matcher.group(1)) < versionMinimalRequiredDecimalPart) {
				return false;
			// Next we check the fractional part
			} else if (Integer.parseInt(matcher.group(1)) == versionMinimalRequiredDecimalPart && 
					Integer.parseInt(matcher.group(2)) < versionMinimalRequiredFractionalPart) {
				return false;
			}
			
		} else {
			return false;
		}

		// Step 2: Check build local platform with mobile platform
		if (mobilePlatform instanceof Android) {
			return true;
		} else if (mobilePlatform instanceof IOs) {
			return is(OS.mac);
		} else if (mobilePlatform.getType().startsWith("Windows")) {
			return is(OS.win32);
		}
		
		return false;
	}
	
	/***
	 * Return the cordova version
	 * @return String
	 * @throws Throwable
	 */
	private String getCordovaVersion() throws Throwable {
		if (cordovaVersion == null) {
			cordovaVersion = runCordovaCommand(getPrivateDir(), "-v");
		}
		return cordovaVersion;
	}
	
	/***
	 * Return the absolute path of builded application file
	 * @param mobilePlatform
	 * @param buildMode
	 * @return
	 */
	protected File getAbsolutePathOfBuiltFile(MobilePlatform mobilePlatform, String buildMode) {
		String cordovaPlatform = mobilePlatform.getCordovaPlatform();
		String builtPath = File.separator + "platforms" + File.separator + cordovaPlatform + File.separator;
		String buildMd = buildMode.equals("debug") ? "Debug" : "Release";
		
		String extension = "";
		File f = new File(getCordovaDir(), builtPath);		
		
		if (f.exists()) {
		
			// Android
			if (mobilePlatform instanceof Android) {
				builtPath = builtPath + "ant-build" + File.separator;
				File f2 = new File(getCordovaDir(), builtPath);
				if (!f2.exists()) {
					builtPath = File.separator + "platforms" + File.separator + cordovaPlatform + 
							File.separator + "build" + File.separator + "outputs" + File.separator + "apk" + File.separator;
				}
				extension = "apk";
				
			// iOS
			} else if (mobilePlatform instanceof IOs){
				extension = "xcodeproj";
				
			// Windows Phone 8
			} else if (mobilePlatform instanceof WindowsPhone8) {
				builtPath = builtPath + "Bin" + File.separator + buildMd + File.separator;
				extension = "xap";
				
			// Windows 8
			} else if (mobilePlatform instanceof Windows){
				//TODO : Handle Windows 8
				
			} else {
				return null;
			}
		}

		f = new File(getCordovaDir(), builtPath);
		if (f.exists()) {
			String[] filesNames = f.list();
			int i = filesNames.length - 1;
			boolean find = false;
			while (i > 0 && !find && !extension.isEmpty()) {
				String fileName = filesNames[i];
				if (fileName.endsWith(extension)) {
					builtPath += fileName;
					find = true;
				}
				i--;
			}
		} else {
			builtPath = File.separator + "platforms" + File.separator + cordovaPlatform + File.separator;
		}
		
		return new File (getCordovaDir(), builtPath);
	}
	
	/***
	 * Dialog yes/no which ask to user if we want
	 * remove the cordova directory present into "_private" directory
	 * We also explain, what we do and how to recreate the cordova environment
	 */
	public void removeCordovaDirectory() {
		String mobilePlatformName = mobilePlatform.getName();
		
		//Step 1: Recover the "cordova" directory	
        final File cordovaDirectory = getCordovaDir();
		
		//Step 2: Remove the "cordova" directory
        if (cordovaDirectory.exists()) {
        	if (FileUtils.deleteQuietly(cordovaDirectory)){
				Engine.logEngine.info("The Cordova environment of \"" + mobilePlatformName + "\" has been successfull removed.");
				return;
			}      		        	
        	Engine.logEngine.warn("The Cordova environment of \"" + mobilePlatformName + "\" has been partially removed.");			
        } else {
			Engine.logEngine.error("The Cordova environment of \"" + mobilePlatformName + "\" not removed because doesn't exist.");
			return;
        }
	}
	
	/***
	 * Return the Cordova directory
	 * @return File
	 */
	public File getCordovaDir() {
		return new File(getPrivateDir(), 
				"localbuild" + File.separator + 
				mobilePlatform.getName() + File.separator + BuildLocally.cordovaDir);
	}
	
	/***
	 * Return the Private directory
	 * @return File
	 */
	private File getPrivateDir() {
		return new File(mobilePlatform.getProject().getDirPath() + "/_private");
	}

	/***
	 * Return the local Operating System
	 * @return
	 */
	private OS getOsLocal() {
		if (osLocal == null) {
			String osname = System.getProperty("os.name", "generic").toLowerCase();
			
			if (osname.startsWith("windows")) {
				osLocal = OS.win32;
			} else if (osname.startsWith("linux")) {
				osLocal = OS.linux;
			} else if (osname.startsWith("sunos")) {
				osLocal = OS.solaris;
			} else if (osname.startsWith("mac") || osname.startsWith("darwin")) {
				osLocal = OS.mac;
			} else {
				osLocal = OS.generic;
			}
		}
		return osLocal;
	}
	
	/***
	 * Compare two Operating System
	 * @param os
	 * @return
	 */
	private boolean is(OS os) {
		return getOsLocal() == os;
	}
	
	public enum Status {
		OK,
		CANCEL
	}
	
	public Status runBuild(String option, boolean run, String target) {
		try {		
			
			File cordovaDir = getCordovaDir();
			// Cordova environment is already created, we have to build
			// Step 1: Call Mobile packager to prepare the source package
			MobileResourceHelper mobileResourceHelper = new MobileResourceHelper(mobilePlatform, 
					"_private" + File.separator + "localbuild" + File.separator + mobilePlatform.getName() + 
					File.separator + BuildLocally.cordovaDir + File.separator + "www");
			
			File wwwDir = mobileResourceHelper.preparePackage();

			// Step 2: Add platform and read config.xml to copy needed icons and splash resources
			
			String cordovaPlatform = mobilePlatform.getCordovaPlatform();
			
			//
			FileUtils.copyFile(new File(wwwDir, "config.xml"), new File(cordovaDir, "config.xml"));
			FileUtils.deleteQuietly(new File(wwwDir, "config.xml"));

			processConfigXMLResources(wwwDir, cordovaDir);
			
			List<String> commandsList = new LinkedList<String>();
			
			if (mobilePlatform instanceof Windows) {
				File configFile = new File(cordovaDir, "config.xml");
				Document doc = XMLUtils.loadXml(configFile);
				
				TwsCachedXPathAPI xpathApi = new TwsCachedXPathAPI();
				
				Element singleElement = (Element) xpathApi.selectSingleNode(doc, "/widget/engine[@name='windows']");
				
				if (singleElement == null) {
					throw new Exception("The tag 'engine' is not specified in the file config.xml.");
				}
				
				String appx = singleElement.getAttribute("appx");
				String archs = singleElement.getAttribute("archs");
				
				if (appx == null || archs == null || appx.isEmpty() || archs.isEmpty()) {
					throw new Exception("The attributes 'appx' and 'archs' are not specified in the tag engine.");
				}
				
				commandsList.add("--");
				commandsList.add("--appx=" + appx);
				commandsList.add("--archs=" + archs);
			}
			
			runCordovaCommand(cordovaDir, "prepare", cordovaPlatform);

			// Step 3: Build or Run using Cordova the specific platform.
			if (run) {
				commandsList.add(0, "run");
				commandsList.add(1, cordovaPlatform);
				commandsList.add(2, "--" + option);
				commandsList.add(3, "--" + target);
				
				runCordovaCommand(cordovaDir, commandsList);
			} else {
				
				commandsList.add(0, "build");
				commandsList.add(1, cordovaPlatform);
				commandsList.add(2, "--" + option);
				
				runCordovaCommand(cordovaDir, commandsList);

				// Step 4: Show dialog with path to apk/ipa/xap
				if (!processCanceled) {
					showLocationInstallFile(mobilePlatform, process.exitValue(), errorLines, option);
				}
			}
			
			return Status.OK;
		} catch (Throwable e) {
			logException(e, "Error when processing Cordova build");
			
			return Status.CANCEL;
		}
	}
	
	public void cancelBuild(boolean run){
		//Only for the "Run On Device" action
		if (run) {
			if (is(OS.win32) && (mobilePlatform instanceof WindowsPhone8) ) {
				//kill the CordovaDeploy.exe program only for Windows Phone 7 & 8 build platform
				try {
					Runtime.getRuntime().exec("taskkill /IM CordovaDeploy.exe").waitFor();
				} catch (Exception e) {
					Engine.logEngine.error("Error during kill of process \"CordovaDeploy\"\n" + e.getMessage(), e);
				}
			} else if (mobilePlatform instanceof IOs) {
				//kill the lldb process only for ios build platform
				try {
					Runtime.getRuntime().exec("pkill lldb").waitFor();
				} catch (Exception e) {
					Engine.logEngine.error("Error during kill of process \"lldb\"\n" + e.getMessage(), e);
				}
			}
		}
		
		processCanceled = true;

		// Others OS
		process.destroy();
	}
	
	public Status installCordova() {

		try {

			Engine.logEngine.info("Checking if node.js is installed.");
			File resourceFolder = mobilePlatform.getResourceFolder();
			List<String> parameters = new LinkedList<String>();
			parameters.add("--version");
			String npmVersion = runCommand(resourceFolder, "npm", parameters, false);
			Pattern pattern = Pattern.compile("^([0-9])+\\.([0-9])+\\.([0-9])+$");
			Matcher matcher = pattern.matcher(npmVersion);			
			if (!matcher.find()){
				throw new Exception("node.js is not installed ('npm --version' returned '" + npmVersion + "')\nYou must download nodes.js from https://nodejs.org/en/download/");
			}
			Engine.logEngine.info("OK, node.js is installed.");
			
			Engine.logEngine.info("Checking if this cordova version is already installed.");
			File configFile = new File(resourceFolder, "config.xml");
			Document doc = XMLUtils.loadXml(configFile);
			TwsCachedXPathAPI xpathApi = new TwsCachedXPathAPI();
			
			Element singleElement = (Element) xpathApi.selectSingleNode(doc, "/widget/preference[@name='phonegap-version']");
			if (singleElement != null) {
				String cliVersion = singleElement.getAttribute("value");
				if (cliVersion != null) {
					
					pattern = Pattern.compile("^cli-[0-9]+\\.[0-9]+\\.[0-9]+$");
					matcher = pattern.matcher(cliVersion);			
					if (!matcher.find()){
						throw new Exception("The cordova version is specified but its value has not the right format.");
					}
					
					// Remove 'cli-' from 'cli-x.x.x'
					cliVersion = cliVersion.substring(4);
					String cordovaInstallPath = BuildLocally.cordovaInstallsPath + File.separator + 
							"cordova" + cliVersion;
					File cordovaBinFile = new File(cordovaInstallPath + File.separator + 
							"node_modules" + File.separator + 
							"cordova" + File.separator + 
							"bin" + File.separator + "cordova"
							);
					// If cordova is not installed
					if (!cordovaBinFile.exists()) {
						
						Engine.logEngine.info("Installing cordova " + cliVersion + " This can take some time....");
						
						File cordovaInstallDir = new File(cordovaInstallPath);
						cordovaInstallDir.mkdir();
						
						parameters = new LinkedList<String>();
						parameters.add("--prefix");
						parameters.add(cordovaInstallDir.getAbsolutePath());
						parameters.add("install");
						parameters.add("cordova@" + cliVersion);
						
						this.runCommand(cordovaInstallDir, "npm", parameters, true);	
					}
					
					Engine.logEngine.info("Cordova is now installed.");
					
					this.cordovaBinPath = cordovaBinFile.getAbsolutePath();
				} else {
					throw new Exception("The cordova version is not specified in config.xml.");
				}
			} else {
				throw new Exception("The cordova version is not specified in config.xml.");
			}
		
		} catch (Throwable e) {
			logException(e, "Error when installing Cordova");			
			return Status.CANCEL;
		}
		
		return Status.OK;
	}
	
	public boolean isProcessCanceled() {
		return this.processCanceled;
	}

	public Status createCordovaEnvironment(File mobilePlatformDir) {
		
		MobileApplication mobileApplication = mobilePlatform.getParent();
		
		try {
			runCordovaCommand(mobilePlatformDir, "create", 
					cordovaDir, 
					mobileApplication.getComputedApplicationId(),
//					mobileApplication.getComputedEscapededApplicationName(mobilePlatform) );
					"cordova");
		} catch (Throwable e) {
			Engine.logEngine.error("Error when creating the cordova environment.", e);
			return Status.CANCEL;
		}
		return Status.OK;
	}
	
	/** 
     * Removes the CordovaPlatform...  
     * Used to clean a broken cordova environment. 
     */ 
    public Status runRemoveCordovaPlatform (String platformName) { 
    	try {
			runCordovaCommand(getCordovaDir(), "platform", "rm", platformName);
			return Status.OK;

		} catch (Throwable thr) {
			Engine.logEngine.error("Error when removing the required mobile platform!", thr);
			return Status.CANCEL;
		}
    } 
    
    
    public void cancelRemoveCordovaPlatform(){
    	process.destroy();
    }
    
    abstract protected String getLocalBuildAdditionalPath();
    abstract protected void logException(Throwable e, String message);
    /***
	 * Show the dialog with builded application file 
	 * @param mobilePlatform
	 * @param exitValue
	 * @param errorLines
	 * @param buildOption
	 */
    abstract protected void showLocationInstallFile(final MobilePlatform mobilePlatform, 
			final int exitValue, final String errorLines, final String buildOption);
}

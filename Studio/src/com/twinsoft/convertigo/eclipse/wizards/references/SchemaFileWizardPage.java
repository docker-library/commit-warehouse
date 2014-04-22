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
 * $URL: $
 * $Author: $
 * $Revision: $
 * $Date: $
 */

package com.twinsoft.convertigo.eclipse.wizards.references;

import java.io.File;
import java.net.URL;

import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.jface.wizard.IWizardPage;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;

import com.twinsoft.convertigo.beans.core.DatabaseObject;
import com.twinsoft.convertigo.beans.core.Project;
import com.twinsoft.convertigo.eclipse.dialogs.WsReferenceAuthenticatedComposite;
import com.twinsoft.convertigo.eclipse.wizards.new_object.ObjectExplorerWizardPage;
import com.twinsoft.convertigo.eclipse.wizards.util.FileFieldEditor;
import com.twinsoft.convertigo.engine.Engine;

public abstract class SchemaFileWizardPage extends WizardPage {
	private String[] filterExtension = new String[]{"*.xsd"};
	private String[] filterNames = new String[]{"XSD files"};
	private Object parentObject = null;
	private WsReferenceAuthenticatedComposite wsRefAuthenticated = null;
	public Button useAuthentication = null;
	public Text loginText = null, passwordText = null;
	
	private FileFieldEditor editor = null;
	private String filePath = "";
	private Text url = null;
	private String urlPath = "";
	
	public SchemaFileWizardPage(Object parentObject, String pageName) {
		super(pageName);
		this.parentObject = parentObject;
		setTitle("Schema File");
		setDescription("Please enter an url OR choose a file.");
	}

	public String[] getFilterExtension() {
		return filterExtension;
	}

	public void setFilterExtension(String[] filterExtension) {
		this.filterExtension = filterExtension;
	}
	
	public String[] getFilterNames() {
		return filterNames;
	}

	public void setFilterNames(String[] filterNames) {
		this.filterNames = filterNames;
	}

	public void createControl(Composite parent) {
		Composite container = new Composite(parent, SWT.NULL);
		GridLayout layout = new GridLayout();
		container.setLayout(layout);
		layout.numColumns = 3;
		layout.horizontalSpacing = 15;
		layout.verticalSpacing = 9;

		Label label1 = new Label(container, SWT.NULL);
		label1.setText("&Enter URL:");
		
		GridData data = new GridData ();
		data.horizontalAlignment = GridData.FILL;
		data.horizontalSpan = 2;
		data.grabExcessHorizontalSpace = true;
		url = new Text (container, SWT.BORDER);
		url.setLayoutData (data);
		url.addModifyListener(new ModifyListener(){
			public void modifyText(ModifyEvent e) {
				urlPath = SchemaFileWizardPage.this.url.getText();
				dialogChanged();
			}
		});
		
		
		Composite fileSelectionArea = new Composite(container, SWT.NONE);
		GridData fileSelectionData = new GridData(GridData.GRAB_HORIZONTAL | GridData.FILL_HORIZONTAL);
		fileSelectionData.horizontalSpan = 3;
		fileSelectionArea.setLayoutData(fileSelectionData);

		editor = new FileFieldEditor("fileSelect","Select File: ",fileSelectionArea);
		editor.setFilterExtensions(filterExtension);
		editor.setFilterNames(filterNames);
		editor.setFilterPath(Engine.PROJECTS_PATH +"/"+ getProjectName());
		editor.getTextControl(fileSelectionArea).setEnabled(false);
		editor.getTextControl(fileSelectionArea).addModifyListener(new ModifyListener(){
			public void modifyText(ModifyEvent e) {
				IPath path = new Path(SchemaFileWizardPage.this.editor.getStringValue());
				filePath = path.toString();
				dialogChanged();
			}
		});
		
		/* Authenticated Composite for import WS Reference */
		GridData data2 = new GridData ();
		data2.horizontalAlignment = GridData.FILL;
		data2.horizontalSpan = 3;
		data2.grabExcessHorizontalSpace = true;
		
		wsRefAuthenticated = new WsReferenceAuthenticatedComposite(container, SWT.NONE, data2);
		
		useAuthentication = wsRefAuthenticated.useAuthentication;
		loginText = wsRefAuthenticated.loginText;
		passwordText = wsRefAuthenticated.passwordText;
		
		dialogChanged();
		setControl(container);
	}

	protected DatabaseObject getDbo() {
		return ((ObjectExplorerWizardPage)getWizard().getPage("ObjectExplorerWizardPage")).getCreatedBean();
	}
	
	private String getProjectName() {
		if (parentObject instanceof Project) {
			return ((Project)parentObject).getName();
		}
		return "";
	}
	
	private void dialogChanged() {
		String message = null;
		if (!urlPath.equals("")) {
			try {
				new URL(urlPath);
				try {
					setDboUrlPath(urlPath);
				} catch (NullPointerException e) {
					message = "New Bean has not been instantiated";
				}
			}
			catch (Exception e) {
				message = "Please enter a valid URL";
			}
		}
		else if (!filePath.equals("")) {
			File file = new File(filePath);
			if (!file.exists()) {
				message = "Please select an existing file";
			}
			else {
				String[] filterExtensions = filterExtension[0].split(";");
				for (String fileFilter: filterExtensions) {
					String fileExtension = fileFilter.substring(fileFilter.lastIndexOf("."));
					if (filePath.endsWith(fileExtension)) {
						try {
							String xsdFilePath = new File(filePath).getCanonicalPath();
							String projectPath = (new File(Engine.PROJECTS_PATH +"/"+ getProjectName())).getCanonicalPath();
							String workspacePath = (new File(Engine.USER_WORKSPACE_PATH)).getCanonicalPath();
							
							boolean isExternal = !xsdFilePath.startsWith(projectPath) && !xsdFilePath.startsWith(workspacePath);
							
							if (isExternal) {
								SchemaFileWizardPage.this.url.setText(file.toURI().toURL().toString());
							}
							else {
								if (xsdFilePath.startsWith(projectPath))
									xsdFilePath = "./" + xsdFilePath.substring(projectPath.length());
								else if (xsdFilePath.startsWith(workspacePath))
									xsdFilePath = "." + xsdFilePath.substring(workspacePath.length());
								xsdFilePath = xsdFilePath.replaceAll("\\\\", "/");
								
								try {
									setDboFilePath(xsdFilePath);
								} catch (NullPointerException e) {
									message = "New Bean has not been instantiated";
								}
							}
						} catch (Exception e) {
							message = e.getMessage();
						}
					}
					else {
						message = "Please select a compatible file";
					}
				}
			}
		} 
		else if (useAuthentication.getSelection() && 
				(loginText.getText().equals("") || passwordText.getText().equals("")) ) {
			message = "Please enter login and password";
		}
		else {
			message = "Please enter an url OR choose a file";
		}
		

		
		updateStatus(message);
	}
	
	protected abstract void setDboFilePath(String filepath);
	protected abstract void setDboUrlPath(String urlpath);
	
	private void updateStatus(String message) {
		setErrorMessage(message);
		setPageComplete(message == null);
	}
	
	@Override
	public void performHelp() {
		getPreviousPage().performHelp();
	}

	@Override
	public IWizardPage getNextPage() {
		return null;
	}
}

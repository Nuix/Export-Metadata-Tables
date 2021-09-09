# Menu Title: Export Metadata PDF & HTML
# Needs Case: true
# Needs Selected Items: true

script_directory = File.dirname(__FILE__)

# Bootstrap Nx
require File.join(script_directory,"Nx.jar")
java_import "com.nuix.nx.NuixConnection"
java_import "com.nuix.nx.LookAndFeelHelper"
java_import "com.nuix.nx.dialogs.ChoiceDialog"
java_import "com.nuix.nx.dialogs.TabbedCustomDialog"
java_import "com.nuix.nx.dialogs.CommonDialogs"
java_import "com.nuix.nx.dialogs.ProgressDialog"
java_import "com.nuix.nx.misc.PlaceholderResolver"
java_import "com.nuix.nx.digest.DigestHelper"
java_import "com.nuix.nx.controls.models.Choice"

LookAndFeelHelper.setWindowsIfMetal
NuixConnection.setUtilities($utilities)
NuixConnection.setCurrentNuixVersion(NUIX_VERSION)

# Bootstrap SuperUtilities
require File.join(script_directory,"SuperUtilities.jar")
java_import com.nuix.superutilities.SuperUtilities
$su = SuperUtilities.init($utilities,NUIX_VERSION)

pdf_template_file = File.join(script_directory,"Templates","PdfTemplate.erb")
pdf_te = $su.createTemplateExporter(pdf_template_file)

html_template_file = File.join(script_directory,"Templates","HtmlTemplate.erb")
html_te = $su.createTemplateExporter(html_template_file)

txt_template_file = File.join(script_directory,"Templates","TxtTemplate.erb")
txt_te = $su.createTemplateExporter(txt_template_file)

items = $current_selected_items

profile_choices = $utilities.getMetadataProfileStore.getMetadataProfiles.map{|p|p.getName}

# Get list of custom metadata field names
custom_field_names = $current_case.getCustomMetadataFields("user")

dialog = TabbedCustomDialog.new("Export Metadata Tables")
dialog.enableStickySettings(File.join(script_directory,"RecentSettings.json"))
dialog.setHelpFile(File.join(script_directory,"Help.html"))
dialog.setHelpUrl("https://github.com/Nuix/Export-Metadata-Tables")

main_tab = dialog.addTab("main_tab","Main")
main_tab.appendComboBox("metadata_profile_name","Metadata Profile",profile_choices)
main_tab.appendDirectoryChooser("export_directory","Export Directory")

main_tab.appendCheckBox("export_pdf","Export PDF files",true)
main_tab.appendTextField("pdf_template","PDF Path Template","{export_directory}\\PDF\\{box_major}\\{box}\\{name}.pdf")
main_tab.enabledOnlyWhenChecked("pdf_template","export_pdf")

main_tab.appendCheckBox("export_html","Export HTML files",false)
main_tab.appendTextField("html_template","HTML Path Template","{export_directory}\\HTML\\{box_major}\\{box}\\{name}.html")
main_tab.enabledOnlyWhenChecked("html_template","export_html")

main_tab.appendCheckBox("export_txt","Export TXT files",false)
main_tab.appendTextField("txt_template","Text Path Template","{export_directory}\\TEXT\\{box_major}\\{box}\\{name}.txt")
main_tab.enabledOnlyWhenChecked("txt_template","export_txt")

main_tab.appendSpinner("base_font_size","Base Font Size (HTML/PDF)",11,8,32)

# Placeholder settings tab
placeholders_tab = dialog.addTab("placeholders_tab","Placeholders")

placeholders_tab.appendSpinner("max_item_path_segment_length","Maximum {item_path} segment length",0,0,10000000,1)

placeholders_tab.appendSeparator("Box Minor Settings")
placeholders_tab.appendSpinner("box_start","{box} starting number",0,0,99999999)
placeholders_tab.appendSpinner("box_width","{box} zero fill width",4,1,8)
placeholders_tab.appendSpinner("box_step","Items per {box} increment",1000,1,10000000,10)

placeholders_tab.appendSeparator("Box Major Settings")
placeholders_tab.appendSpinner("box_major_width","{box_major} zero fill width",4,1,8)

# These are to allow the user to provide fixed placeholders.  Use case is when there is a standard
# structure but pehaps each export has one value change.  User can include a user value placeholder
# wherever its needed but they will only need to change the value here on subsequent runs.
placeholders_tab.appendSeparator("User Placeholders")
placeholders_tab.appendTextField("user_value_1","{user_1} = ","")
placeholders_tab.appendTextField("user_value_2","{user_2} = ","")
placeholders_tab.appendTextField("user_value_3","{user_3} = ","")
placeholders_tab.appendTextField("user_value_4","{user_4} = ","")
placeholders_tab.appendTextField("user_value_5","{user_5} = ","")

# Only have option for custom field names if the case actually has some
# custom metadata fields present
placeholders_tab.appendSeparator("Custom Metadata")
if custom_field_names.size > 0
	placeholders_tab.appendCheckBox("use_custom_placeholders","Use custom metadata placeholders",false)
	placeholders_tab.appendComboBox("custom_field_1","{custom_1} = ",custom_field_names)
	placeholders_tab.appendComboBox("custom_field_2","{custom_2} = ",custom_field_names)
	placeholders_tab.appendComboBox("custom_field_3","{custom_3} = ",custom_field_names)
	placeholders_tab.appendComboBox("custom_field_4","{custom_4} = ",custom_field_names)
	placeholders_tab.appendComboBox("custom_field_5","{custom_5} = ",custom_field_names)
	placeholders_tab.enabledOnlyWhenChecked("custom_field_1","use_custom_placeholders")
	placeholders_tab.enabledOnlyWhenChecked("custom_field_2","use_custom_placeholders")
	placeholders_tab.enabledOnlyWhenChecked("custom_field_3","use_custom_placeholders")
	placeholders_tab.enabledOnlyWhenChecked("custom_field_4","use_custom_placeholders")
	placeholders_tab.enabledOnlyWhenChecked("custom_field_5","use_custom_placeholders")
else
	placeholders_tab.appendHeader("Current case has no custom metadata fields defined.")
end

dialog.validateBeforeClosing do |values|
	if values["export_directory"].strip.empty?
		CommonDialogs.showWarning("Please select an export directory.")
		next false
	end

	if !values["export_pdf"] && !values["export_html"] && !values["export_txt"]
		CommonDialogs.showWarning("Please choose something to export (PDF,HTML,TXT)")
		next false
	end

	if values["export_pdf"] && values["pdf_template"].strip.empty?
		CommonDialogs.showWarning("Please provide a value for 'PDF Path Template'")
		next false
	end

	if values["export_html"] && values["html_template"].strip.empty?
		CommonDialogs.showWarning("Please provide a value for 'HTML Path Template'")
		next false
	end

	if values["export_txt"] && values["txt_template"].strip.empty?
		CommonDialogs.showWarning("Please provide a value for 'Text Path Template'")
		next false
	end

	next true
end

dialog.display
if dialog.getDialogResult == true
	values = dialog.toMap
	
	metadata_profile_name = values["metadata_profile_name"]
	export_directory = values["export_directory"]
	profile = $utilities.getMetadataProfileStore.getMetadataProfile(metadata_profile_name)
	
	export_pdf = values["export_pdf"]
	pdf_template = values["pdf_template"]

	export_html = values["export_html"]
	html_template = values["html_template"]

	export_txt = values["export_txt"]
	txt_template = values["txt_template"]

	box_start = values["box_start"]
	box_width = values["box_width"]
	box_step = values["box_step"]
	box_major_width = values["box_major_width"]

	max_item_path_segment_length = values["max_item_path_segment_length"]
	use_custom_placeholders = values["use_custom_placeholders"]
	custom_field_1 = values["custom_field_1"]
	custom_field_2 = values["custom_field_2"]
	custom_field_3 = values["custom_field_3"]
	custom_field_4 = values["custom_field_4"]
	custom_field_5 = values["custom_field_5"]
	user_value_1 = values["user_value_1"]
	user_value_2 = values["user_value_2"]
	user_value_3 = values["user_value_3"]
	user_value_4 = values["user_value_4"]
	user_value_5 = values["user_value_5"]
	enable_docid = values["enable_docid"]

	data = {
		"font_size" => values["base_font_size"]
	}
	
	java.io.File.new(export_directory).mkdirs

	resolver = PlaceholderResolver.new

	ProgressDialog.forBlock do |pd|
		pd.setTitle("Export Metadata Tables")
		pd.setAbortButtonVisible(true)

		pd.setMainProgress(0,items.size)

		pd.logMessage("Rendering files...")
		items.each_with_index do |item,item_index|
			break if pd.abortWasRequested

			record_number = item_index + 1

			# Here we are generating a box number.  Essentially we calculate the box number
			# as incrementing every N items.  When then convert the number to a string zero padded
			# to the total length of box width and box major width.  Box gets the right half, box major
			# gets the left half.  Some additional formatting manipulations are then performed to ensure
			# 0 fill is correct in each piece while allowing box major to overflow its fill width if necessary.
			box_number = ((record_number.to_f / box_step.to_f).floor + box_start).to_i
			box_whole_string = box_number.to_s.rjust(box_width+box_major_width,"0")
			box_len = box_whole_string.size
			box_min = box_len - box_width
			box_max = box_len - 1
			box = box_whole_string[box_min..box_max].to_i.to_s.rjust(box_width,"0")
			box_major_min = 0
			box_major_max = box_len - box_width - 1
			box_major = box_whole_string[box_major_min..box_major_max].to_i.to_s.rjust(box_major_width,"0")

			# Setup placeholders
			resolver.clear
			resolver.setPath("export_directory",export_directory)

			# User "static" placeholders, evaluated earlier on so that
			# they should be able to contain other placeholders
			resolver.setPath("user_1",user_value_1)
			resolver.setPath("user_2",user_value_2)
			resolver.setPath("user_3",user_value_3)
			resolver.setPath("user_4",user_value_4)
			resolver.setPath("user_5",user_value_5)

			# Placeholders which are based on custom metadata
			if use_custom_placeholders
				cm = item.getCustomMetadata
				# Coalesce will make sure nil or empty values get a value
				# of "NO_VALUE" since an empty value could break path strings
				cmv1 = coalesce("#{cm[custom_field_1]}")
				cmv2 = coalesce("#{cm[custom_field_2]}")
				cmv3 = coalesce("#{cm[custom_field_3]}")
				cmv4 = coalesce("#{cm[custom_field_4]}")
				cmv5 = coalesce("#{cm[custom_field_5]}")

				# Furthermore, we need to remove illegal path characters from these
				# values while still allowing path separators to get through in case
				# someone is using the field to specify varying pathing
				cmv1 = PlaceholderResolver.cleanPathString(cmv1)
				cmv2 = PlaceholderResolver.cleanPathString(cmv2)
				cmv3 = PlaceholderResolver.cleanPathString(cmv3)
				cmv4 = PlaceholderResolver.cleanPathString(cmv4)
				cmv5 = PlaceholderResolver.cleanPathString(cmv5)

				resolver.setPath("custom_1",cmv1)
				resolver.setPath("custom_2",cmv2)
				resolver.setPath("custom_3",cmv3)
				resolver.setPath("custom_4",cmv4)
				resolver.setPath("custom_5",cmv5)
			end

			# General placeholders
			resolver.set("box",box)
			resolver.set("box_major",box_major)
			current_item_localised_name = item.getLocalisedName.gsub(/[\\\/\n\r\t]/,"_")
			if current_item_localised_name =~ /\./
				resolver.set("name",File.basename(current_item_localised_name,File.extname(current_item_localised_name)))
			else
				resolver.set("name",current_item_localised_name)
			end
			resolver.set("fullname",current_item_localised_name)
			resolver.set("guid",item.getGuid)
			resolver.set("sub_guid",item.getGuid[0..2])
			resolver.set("md5",item.getDigests.getMd5 || "NO_MD5")
			resolver.set("type",item.getType.getLocalisedName)
			resolver.set("mime_type",item.getType.getName)
			resolver.set("kind",item.getType.getKind.getName)
			resolver.set("custodian",item.getCustodian || "NO_CUSTODIAN")
			resolver.set("evidence_name",item.getRoot.getLocalisedName)
			resolver.set("case_name",$current_case.getName)

			# Resolve an item date value for placeholder
			current_item_date = item.getDate
			if !current_item_date.nil?
				resolver.set("item_date",current_item_date.toString("YYYYMMdd"))
			else
				resolver.set("item_date","00000000")
			end
			if !current_item_date.nil?
				resolver.set("item_date_time",current_item_date.toString("YYYYMMdd-HHmmss"))
			else
				resolver.set("item_date_time","00000000-000000")
			end

			# Resolve an item path value that is able to be used in file system path
			current_item_path = item.getLocalisedPathNames.to_a
			current_item_path.pop
			current_item_path = current_item_path.map do |localised_path_name|
				# Replace some characters with underscores
				segment = localised_path_name.gsub(/[\\\/\.\n\r\t]+/,"_")

				# If user specified max segment length, enforce that here
				if max_item_path_segment_length > 0 && segment.size > max_item_path_segment_length
					segment = segment[0..max_item_path_segment_length-1]
				end

				# Its possible for leading or trailing whitespace characters at this
				# point which wont work so we need to strip them off
				segment = segment.strip

				# Finally, there is a small chance the somehow we have a segment of length 0
				# so we will just make sure something gets through for this segment
				if segment.size == 0
					segment = "_"
				end

				next segment
			end
			resolver.set("item_path",current_item_path.join("\\"))

			# Placeholder which are based on top level item (or current item if above top level)
			top_level_item = item.getTopLevelItem || item
			resolver.set("top_level_guid",top_level_item.getGuid)
			resolver.set("top_level_sub_guid",top_level_item.getGuid[0..2])
			resolver.set("top_level_name",File.basename(top_level_item.getLocalisedName,File.extname(top_level_item.getLocalisedName)))
			resolver.set("top_level_fullname",top_level_item.getLocalisedName)
			top_level_item_path = top_level_item.getPath.to_a
			top_level_item_path.pop
			resolver.set("top_level_item_path",top_level_item_path.map{|i|i.getLocalisedName.gsub(/[\\\/\.\n\r\t]/,"_")}.join("\\"))

			pd.setMainProgress(item_index+1)
			profile_values = {}
			profile.getMetadata.each do |field|
				profile_values[field.getName] = field.evaluate(item)
			end
			
			data["profile"] = profile_values
			guid = item.getGuid

			if export_pdf
				pdf_file_name = resolver.resolveTemplatePath(pdf_template)
				j_pdf_file = java.io.File.new(pdf_file_name)
				j_pdf_file.getParentFile.mkdirs
				pd.logMessage("Exporting PDF: #{pdf_file_name}")
				pdf_te.renderToPdf(item,j_pdf_file,data)
			end

			if export_html
				html_file_name = resolver.resolveTemplatePath(html_template)
				j_html_file = java.io.File.new(html_file_name)
				j_html_file.getParentFile.mkdirs
				pd.logMessage("Exporting HTML: #{html_file_name}")
				html_te.renderToFile(item,j_html_file,data)
			end

			if export_txt
				txt_file_name = resolver.resolveTemplatePath(txt_template)
				j_txt_file = java.io.File.new(txt_file_name)
				j_txt_file.getParentFile.mkdirs
				pd.logMessage("Exporting TXT: #{txt_file_name}")
				txt_te.renderToFile(item,j_txt_file,data)
			end

		end

		if pd.abortWasRequested
			pd.logMessage("User Aborted")
		else
			pd.setCompleted
		end
	end
end
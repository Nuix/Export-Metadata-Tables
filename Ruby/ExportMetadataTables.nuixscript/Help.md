Export Metadata Tables
======================

# Overview

**Written By:** Jason Wells

# Settings Dialog

When the script is ran a settings dialog will be shown allowing you to configure various aspects of the export customization the script will perform.

## Placeholders Tab

Some placeholders are dependent on settings you provide.  These placeholders are configured on the placeholders tab.

### Box Placeholder Configuration

Allows you to configure the starting number and 0 pad width of the `{box}` placeholder.  See [General Placeholders](#general-placeholders) for more info.

### Custom Metadata Placeholder Configuration

This series of combo boxes allow you to configure what custom metadata fields will be used when resolving the [Custom Metadata Placeholders](#custom-metadata-placeholders).

**Note:** These will only show up if the current case contains at least once custom metadata field.

### User Placeholder Configuration

Allows you to define [User Placeholders](#user-placeholders), which are values of your choosing.  May contain most of the other placeholders.

# Placeholders

Placeholders allow you define dynamic pathing and naming based on placeholder values which will be replaced at runtime.  The most basic of which is the placeholder `{export_directory}` which will be replaced with the export directory value specified in the [Main Tab](#main-tab) of the [Settings Dialog](#settings-dialog).

## User Placeholders

These 5 placeholders allow you to specify static values to be replaced when running the script.  The value of these placeholders are specified in the [Placeholders Tab](#palceholders-tab).  These placeholders are evaluated first and may contain any of the other placeholders except `{export_directory}`.

These placeholders are useful if you have defined a common set of settings but have particular values you wish to manually change each time.

- `{user_1}`
- `{user_2}`
- `{user_3}`
- `{user_4}`
- `{user_5}`

**Tip**: These values may contain `\`.

## Custom Metadata Placeholders

These 5 placeholders allow you to select custom metadata fields to be replaced when running the script.  The value of these placeholders are specified in the [Placeholders Tab](#palceholders-tab).  These placeholders are evaluated second and the custom metadata values they point to may contain any of the other placeholders except the [User Placeholders](#user-placeholders).

These placeholders are useful in generating export pathing and naming based on values recorded in custom metadata fields.

- `{custom_1}`
- `{custom_2}`
- `{custom_3}`
- `{custom_4}`
- `{custom_5}`

**Tip**: These values may contain `\`.

## General Placeholders

These placeholders are evaluated after [User Placeholders](#user-placeholders) and [Custom Metadata Placeholders](#custom-metadata-placeholders).  These placeholders mostly represent data about a given item.

**Note:** Since some of these values may contain characters which are illegal file path characters the following characters are replaced with underscores: `<>:"|?*[]`

- `{box}`: This will be replaced with a sequential number which is incremented every `step` items.  `step` being a number you specify in the settings (default is `1000`).  The starting number, `0` pad width and `step` can be defined in the [Placeholders Tab](#palceholders-tab).  **Note:** When the number exceeds the specified width it restarts at `0`!  For example, a width of `4` will roll over to `0` after `9999`.  This placeholder is intended to be used in conjunction with `{box_major}`.
- `{box_major}`: This number increments whenever `{box}` rolls over to `0`.  So for example, if the current item number is `23579` and `{box}` is configured to a width of `4`, `{box_major}` will be `2` (zero padded based on settings) and `{box}` will be `3579`.  Unlike the `{box}` placeholder, if this value exceeds the specified width it does not roll over to `0`.  Therefore it is possible for this number to exceed the width specified if the value contains more digits than the specified width.
- `{name}`: This will be replaced with the item's name, with the extension stripped if present.
- `{fullname}`: Similar to `{name}` this will be replaced with the item's name, but no extension stripping is performed.
- `{guid}`: This will be replaced with the item's GUID.
- `{sub_guid}`: This will be replaced with the first three characters of the item's GUID.  This is useful for creating a GUID based foldering scheme.
- `{md5}`: Replaced with the item's MD5, or `NO_MD5` if the item has no MD5 value.
- `{type}`: Replaced with the item's type name.
- `{mime_type}`: Replaced with the item's mime type.
- `{kind}`: Replaced with the item's kind name.
- `{extension}`: Replaced with the item's type's preferred extension.
- `{custodian}`: Replaced with the item's custodian value if it has one.  If the item does not have a custodian value assigned, this will be replaced with `NO_CUSTODIAN`.
- `{evidence_name}`: Replaced with the name of the evidence item to which the given item belongs.
- `{case_name}`: Replaced with the name of the current case.
- `{item_date}`: Replaced with the item date (without time) formatted using `YYMMDD` such as `20160208`.  If for some reason an item does not have an item date (Item.getDate returns nil) then this will be replaced with the value `00000000`.
- `{item_date_time}`: Replaced with the item date (without time) formatted using `YYMMDD-HHmmss` such as `20170202-130705`.  If for some reason an item does not have an item date (Item.getDate returns nil) then this will be replaced with the value `00000000-000000`.
- `{item_path}`: Replaced with a series of directories based on item path names (ex: `Bob_pst\Sent Items\FW_ Some Email`).  If setting **Maximum {item_path} segment length** is set to a number greater than 0 then any given segment longer than that value will be truncated to that value.  If **Maximum {item_path} segment length** is set to 0 (the default) then the script does not enforce any segment length maximum.

## Relational Placeholders

These placeholders depend on relationships with other items.  These placeholders can be useful to organize exported items based on some relationship, such as grouping items in a directory based on their top level item.

**Note:** When the noted relationship cannot be resolved, the given item will be used instead.

An example of this would be when attempting to resolve the top level item's value for a given item, but the item is above top level.  In this instance the item's value will be used since there is no top level item to resolve against. 

- `{top_level_guid}`: Replaced with the GUID of the item's top level item.
- `{top_level_sub_guid}`: Similar to `{sub_guid}` in [General Placeholders](#general-placeholders), this will be replaced with the first three characters of the top level item's GUID.
- `{top_level_name}`: Similar to `{name}` in [General Placeholders](#general-placeholders), this will be replaced with the name of the top level item, with the extension stripped off if present.
- `{top_level_fullname}`: Similar to `{fullname}` in [General Placeholders](#general-placeholders), this will be replaced with the name of the top level item without the extension stripped off.
- `{top_level_item_path}`: Similar to `{item_path}` in [General Placeholders](#general_placeholders), this will be replaced with a series of directory based on item path names (ex: `Bob_pst\Sent Items\FW_ Some Email`).  The difference is this will be based on the item path of a given item's top level item.
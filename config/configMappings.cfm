<cfset this.mappings[ "/Slatwall" ] = left(getDirectoryFromPath(getCurrentTemplatePath()), len(getDirectoryFromPath(getCurrentTemplatePath()))-8) />
<cfset this.mappings[ "/ValidateThis" ] = this.mappings[ "/Slatwall" ] & "/org/ValidateThis" />
<cfset this.mappings[ "/coldspring" ] = this.mappings[ "/Slatwall" ] & "/org/coldspring" />
<cfset this.mappings[ "/SlatwallVFSRoot" ] = "ram:///" & this.name />
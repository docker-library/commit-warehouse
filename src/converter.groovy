def properties = [
  'openoffice.port': settings.CONVERTER_PORT != null ? settings.CONVERTER_PORT : '8100', 
  'openoffice.host': settings.CONVERTER_HOST != null ? settings.CONVERTER_HOST : '']

service.updateProperties(
  "${settings.SILVERPEAS_HOME}/properties/org/silverpeas/converter/openoffice.properties",
  properties)


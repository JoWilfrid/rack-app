module Rack::App::SingletonMethods::Extensions

  protected

  def applied_extensions
    @applied_extensions ||= []
  end

  def apply_extensions(*extension_names)
    Rack::App::Extension.apply_extensions(self,applied_extensions,extension_names)
  end

  alias apply_extension apply_extensions
  Rack::App::Utils.deprecate(self, :apply_extension, :apply_extensions, 2017, 01)

  def extensions(*extensions_names)
    apply_extensions(*extensions_names)
    applied_extensions
  end

end

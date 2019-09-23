begin
  require 'gpgme'
rescue LoadError
  begin
    require 'ruby_gpg'
  rescue LoadError
    fail "hiera-eyaml-gpg requires either the 'gpgme' or 'ruby_gpg' gem"
  end
end

require 'yaml'


Puppet::Functions.create_function(:pass_data) do
  dispatch :pass_data do
    param 'Struct[{path=>String[1]}]', :options
    param 'Puppet::LookupContext', :context
  end

  argument_mismatch :missing_path do
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end

  def pass_data(options, context)
    path = options['path']
    context.cached_file_data(path) do |content|
      begin
        content = decrypt(path)
        lines = content.split("\n")
        #passwd = lines[0]
        body = lines[1..-1].join("\n")
        data = Puppet::Util::Yaml.safe_load(body, [Symbol], path)
        if data.is_a?(Hash)
          Puppet::Pops::Lookup::HieraConfig.symkeys_to_string(data)
        else
          msg = _("%{path}: file does not contain a valid yaml hash" % { path: path })
          raise Puppet::DataBinding::LookupError, msg if Puppet[:strict] == :error && data != false
          Puppet.warning(msg)
          {}
        end
      rescue Puppet::Util::Yaml::YamlLoadError => ex
        # YamlLoadErrors include the absolute path to the file, so no need to add that
        raise Puppet::DataBinding::LookupError, _("Unable to parse %{message}") % { message: ex.message }
      end
    end
  end

  def decrypt(file)
    content = File.read(file)
    if defined?(GPGME)
      ctx = GPGME::Ctx.new
      raw = GPGME::Data.new(content)

      # TODO: catch exceptions
      txt = ctx.decrypt(raw)
      txt.seek(0)
      txt.read
    else
      RubyGpg.decrypt_string(content)
    end
  end

  def missing_path(options, context)
    "one of 'path', 'paths' 'glob', 'globs' or 'mapped_paths' must be declared in hiera.yaml when using this data_hash function"
  end
end

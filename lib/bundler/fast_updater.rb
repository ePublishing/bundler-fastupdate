require 'bundler/environment'

module Bundler
  class FastUpdater < Environment

    def initialize(root, definition, name, options={})
      super(root, definition)
      @name = name                                              or raise CanNotFastUpdate.new('missing name')
      @dependency = dependencies.detect { |d| d.name == @name } or raise CanNotFastUpdate.new("can't find depdenency")
      @locked_version = specs.detect { |d| d.name == @name }    or raise CanNotFastUpdate.new("can't find locked_version")
      @source = @locked_version.source                          or raise CanNotFastUpdate.new("can't find source")
      @installed_specs = @source.send(:installed_specs)         or raise CanNotFastUpdate.new("can't find installed_specs")
      (@latest_version, @latest_version_uri = fetch_latest_version_from_first_source) or raise CanNotFastUpdate.new("can't find latest_version")
    rescue GemNotFound => e
      raise CanNotFastUpdate.new("#{e.message} (#{e.class})")
    end

    def fastupdate
      Bundler.bundle_path.exist? or raise CanNotFastUpdate.new('Bundle path does not exist')
      dependencies_match?        or raise CanNotFastUpdate.new('Dependencies mismatch')
      meets_all_dependencies?    or raise CanNotFastUpdate.new('Dependencies not met')

      if latest_version_installed?
        Bundler.ui.info "Using #{@latest_version.name} (#{@latest_version.version}) "
      else
        install_latest_version
      end
      Bundler.ui.info ""

      update_resolve!
      lock
    end

    CanNotFastUpdate = Class.new(StandardError)

    private

    def fetch_latest_version_from_first_source
      old = Bundler.rubygems.sources
      @source.remotes.each do |uri|
        Gem.sources = [uri.to_s]
        spec = Gem::SpecFetcher.fetcher.fetch(@dependency).first
        return spec if spec
      end
      nil
    ensure
      Bundler.rubygems.sources = old
    end

    def latest_version_installed?
      @installed_specs[@name].include? @latest_version
    end

    def install_latest_version
      Bundler.rubygems.with_build_args [Bundler.settings["build.#{@name}"]] do
        rem_spec = RemoteSpecification.new(@latest_version.name, @latest_version.version, @latest_version.platform, @latest_version_uri)
        @source.send(:download_gem_from_uri, rem_spec, @latest_version_uri)
        @source.install(@latest_version)
      end
      FileUtils.rm_rf(Bundler.tmp)
    end

    def dependencies_match?
      @locked_version.dependencies == @latest_version.dependencies
    end

    def meets_all_dependencies?
      @latest_version.dependencies.none? do |dep|
        @installed_specs[dep].empty?
      end
    end

    def update_resolve!
      # NOTE:  This is a nasty little hack.  Surely there is a better way to ask Bundler
      # to just re-resolve itself.  Alas, I had little luck ...
      @definition.resolve[@name].first.instance_variable_set(:@version, @latest_version.version)
    end

  end
end

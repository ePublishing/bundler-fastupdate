require 'bundler/vendored_thor'
require 'bundler/cli'
require 'bundler/fast_updater'

module Bundler
  class CLI < Thor
    include Thor::Actions

    desc "fastupdate", "update a given gem much, much faster"
    long_desc <<-D
      Update is slow, very slow.  This is a faster alternative when you don't
      care about upgrading dependencies that still meet the requirements.
    D
    def fastupdate(name)
      Bundler::FastUpdater.new(Bundler.root, Bundler.definition, name, options).fastupdate
    rescue Bundler::FastUpdater::CanNotFastUpdate => e
      Bundler.ui.info "Can not fast update: #{e.message}"
      update(name)
    end

  end
end

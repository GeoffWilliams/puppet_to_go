require "fpm"
require 'fileutils'

module Puppetbox
  module Packaging

    def self.create

      tmpdir = Dir.mktmpdir + '/'

      FileUtils.cp_r Dir.pwd + '/.', tmpdir, :verbose => true
      FileUtils.rm_rf "#{tmpdir}/.git"
      # g = Git.open(Dir.pwd, :log => Logger.new(STDOUT))
      # #g.with_temp_working(dir) do
      #   # git checkout-index -af --prefix /tmp/bar/
      # g.checkout_index(:prefix => tmpdir, :all => true, :force => true)
      Dir.chdir(tmpdir) do
        puts "puppetfile!!!!!!"
        puppetfile
        puts "packaging!!!!"
        run_packaging
      end
        #end

    end

    def self.puppetfile
      # librarian basically useless because of multiple conflicting metadata.json
      # files on the forge - presumably because everyone now uses r10k and doesn't
      # update them :(
      #system("librarian-puppet install --verbose")
      system("RUBYLIB= GEMHOME= RUBYOPT= r10k puppetfile install --verbose")
    end


    def self.run_packaging
      # enable logging
      FPM::Util.send :module_function, :logger
      FPM::Util.logger.level = :info
      FPM::Util.logger.subscribe STDERR

      package = FPM::Package::Dir.new
      # ARGV.each do |gem|
      #   name, version = gem.split(/[=]/, 2)
      #   package.version = version  # Allow specifying a specific version
      #   package.input(gem)
      # end

      rpm = package.convert(FPM::Package::RPM)
      rpm.name = "puppet-control"
      rpm.version = "1.0"
      begin
        output = "NAME-VERSION.ARCH.rpm"
        rpm.output(rpm.to_s(output))
      ensure
        rpm.cleanup
      end
    end
  end
end

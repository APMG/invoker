require "spec_helper"

describe Invoker::Power::OsxSetup, fakefs: true do
  before do
    FileUtils.mkdir_p(inv_conf_dir)
    FileUtils.mkdir_p(Invoker::Power::OsxSetup::RESOLVER_DIR)
  end

  describe "when no setup exists" do
    it "should create a config file with port etc" do
      setup = Invoker::Power::OsxSetup.new('dev')
      setup.expects(:install_resolver).returns(true)
      setup.expects(:drop_to_normal_user).returns(true)
      setup.expects(:install_firewall).once

      setup.setup_invoker

      config = Invoker::Power::Config.load_config
      expect(config.http_port).not_to be_nil
      expect(config.dns_port).not_to be_nil
      expect(config.https_port).not_to be_nil
    end
  end

  describe "when a setup file exists" do
    it "should throw error about existing file" do
      File.open(Invoker::Power::Config.config_file, "w") {|fl|
        fl.write("foo test")
      }
      Invoker::Power::Setup.any_instance.expects(:setup_invoker).never
      Invoker::Power::Setup.install('dev')
    end
  end

  describe "when pow like setup exists" do
    before {
      File.open(File.join(Invoker::Power::OsxSetup::RESOLVER_DIR, "dev"), "w") { |fl|
        fl.write("hello")
      }
      @setup = Invoker::Power::OsxSetup.new('dev')
    }

    describe "when user selects to overwrite it" do
      it "should run setup normally" do
        @setup.expects(:setup_resolver_file).returns(true)
        @setup.expects(:drop_to_normal_user).returns(true)
        @setup.expects(:install_resolver).returns(true)
        @setup.expects(:install_firewall).once()

        @setup.setup_invoker
      end
    end

    describe "when user chose not to overwrite it" do
      it "should abort the setup process" do
        @setup.expects(:setup_resolver_file).returns(false)

        @setup.expects(:install_resolver).never
        @setup.expects(:install_firewall).never

        @setup.setup_invoker
      end
    end
  end

  describe "uninstalling firewall rules" do
    it "should uninstall firewall rules and remove all files created by setup" do
      setup = Invoker::Power::OsxSetup.new('dev')

      Invoker::CLI::Question.expects(:agree).returns(true)
      setup.expects(:remove_resolver_file).once
      setup.expects(:unload_firewall_rule).with(true).once
      Invoker::Power::Config.expects(:delete).once

      setup.uninstall_invoker
    end
  end

  describe "setup on fresh osx install" do
    context "when resolver directory does not exist" do
      before do
        @setup = Invoker::Power::OsxSetup.new('dev')
        FileUtils.rm_rf(Invoker::Power::OsxSetup::RESOLVER_DIR)
      end

      it "should create the directory and install" do
        @setup.expects(:setup_resolver_file).returns(true)
        @setup.expects(:drop_to_normal_user).returns(true)
        @setup.expects(:install_firewall).once()

        @setup.setup_invoker
        expect(Dir.exist?(Invoker::Power::OsxSetup::RESOLVER_DIR)).to be_truthy
      end
    end
  end

  describe '.resolver_file' do
    context 'user sets up a custom top level domain' do
      it 'should create the correct resolver file' do
        setup = Invoker::Power::OsxSetup.new('local')
        expect(setup.resolver_file).to eq('/etc/resolver/local')
      end
    end
  end
end

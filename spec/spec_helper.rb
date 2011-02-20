begin
  require 'rspec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  require 'rspec'
end

dir = File.dirname(__FILE__)

$:.unshift(File.join(dir, '..', 'lib'))
require 'rupy'

module TestConstants
  # REDEFINE THESE SO THEY ARE VISIBILE
  AString = "STRING"
  AnInt = 1
  AChar = 'a'
  AFloat = 1.0
  AnArray = [AnInt, AChar, AFloat, AString]
  ASym = :sym
  AHash = {
    AnInt => AnInt,
    AChar.to_sym => AChar,
    ASym => AFloat,
    AString => AString
  }
  AConvertedHash = Hash[*AHash.map do |k, v|
    key = k.is_a?(Symbol) ? k.to_s : k
    [key, v]
  end.flatten]
  AProc = Proc.new { |a1, a2| a1 + a2 }
  def self.a_method(a1, a2)
    a1 + a2
  end
  AMethod = method(:a_method)
end

def run_python_command(cmd)
  %x(python -c '#{cmd}').chomp
end

RSpec.configure do |config|
  config.before(:all) do
    Rupy.start

    class Rupy::RubyPyProxy
      [:should, :should_not, :class].each { |m| reveal(m) }
    end

    @sys = Rupy.import 'sys'
    @sys.path.append File.join(dir, 'python_helpers')
    @objects = Rupy.import 'objects'
  end

  config.after(:all) do
    Rupy.stop
  end
end

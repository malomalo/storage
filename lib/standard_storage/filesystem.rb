require 'fileutils'
require File.expand_path('../../standard_storage', __FILE__)

class StandardStorage::Filesystem < StandardStorage

  attr_reader :host, :path, :prefix
  
  def initialize(configs={})
    super
    @host = configs[:host]
    @path = configs[:path]
    @prefix = configs[:prefix]
  end
  
  def local?
    true
  end

  def url(key)
    File.join([@host, path(key)].compact)
  end
  
  def path(key)
    File.join(['/', @prefix, partition(key)].compact)
  end

  def destination(key)
    File.join([@path, partition(key)].compact)
  end

  def exists?(key)
    File.exist?(destination(key))
  end

  def write(key, file, options={})
    key = destination(key)
    FileUtils.mkdir_p(File.dirname(key))
    FileUtils.cp(file.path, key)
  end

  def cp(source, destination)
    source = destination(source)
    FileUtils.cp(source, destination)
  end

  def read(key, &block)
    File.read(destination(key), &block)
  end

  def delete(key)
    FileUtils.rm(destination(key), force: true)
  end
  
  def last_modified(key)
    File.mtime(destination(key))
  end
  
  def mime_type(key)
    command = Terrapin::CommandLine.new("file", '-b --mime-type :file')
    command.run({ file: destination(key) }).strip
  end
  
end
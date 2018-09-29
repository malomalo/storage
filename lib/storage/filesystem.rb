require 'fileutils'
require File.expand_path('../../storage', __FILE__)

class Storage::Filesystem < Storage

  attr_reader :host, :path, :prefix
  
  def initialize(configs={})
    @host = configs[:host]
    @path = configs[:path]
    @prefix = configs[:prefix] || 'blobs'
  end
  
  def local?
    true
  end

  def url(key)
    File.join([@host, path(key)].compact)
  end
  
  def path(key)
    File.join([@prefix, partition(key)].compact)
  end

  def destination(key)
    File.join([@path, @prefix, partition(key)].compact)
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
  
  def last_modified(path)
    File.mtime(destination(path))
  end
  
  def mime_type(path)
    command = Terrapin::CommandLine.new("file", '-b --mime-type :file')
    command.run({ file: destination(path) }).strip
  end
  
end
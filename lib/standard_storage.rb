class StandardStorage
  autoload(:B2, File.expand_path('../standard_storage/b2', __FILE__))
  autoload(:Filesystem, File.expand_path('../standard_storage/filesystem', __FILE__))
  autoload(:S3, File.expand_path('../standard_storage/s3', __FILE__))

  attr_reader :partition, :partition_depth
  
  def initialize(configs={})
    @partition = configs.has_key?(:partition) || configs.has_key?(:partition_depth)
    @partition_depth = if configs[:partition].is_a?(Integer)
      configs[:partition]
    else
      configs[:partition_depth] || 3
    end
  end

  def copy_to_tempfile(key, basename: nil)
    basename ||= [File.basename(key), File.extname(key)]
    
    tmpfile = Tempfile.new(basename, binmode: true)
    cp(key, tmpfile.path)
    if block_given?
      begin
        yield(tmpfile)
      ensure
        tmpfile.close!
      end
    else
      tmpfile
    end
  end
  
  private
  
  def partition(value)
    return value unless @partition
    
    split = value.scan(/.{1,4}/)
    split.shift(@partition_depth).join("/") + split.join("")
  end
  
end

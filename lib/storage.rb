class Storage
  
  def copy_to_tempfile(key)
    tmpfile = Tempfile.new([File.basename(key), File.extname(key)], binmode: true)
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
    return value unless @configs[:partition]
    
    partition_depth = if @configs[:partition].is_a?(Integer)
      @configs[:partition]
    else
      @configs[:partition_depth] || 3
    end
    split = value.scan(/.{1,4}/)
    split.shift(partition_depth).join("/") + split.join("")
  end
  
end
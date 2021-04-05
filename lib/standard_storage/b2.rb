require 'b2'
require File.expand_path('../../standard_storage', __FILE__)

class StandardStorage::B2 < StandardStorage

  attr_reader :key_id, :bucket, :prefix
  
  def initialize(configs={})
    super
    @bucket = configs[:bucket]
    @prefix = configs[:prefix]
    @key_id = configs[:key_id]

    @client = ::B2.new({
      key_id: @key_id,
      secret: configs[:secret]
    }).bucket(@bucket)
  end
  
  def local?
    false
  end

  def url(key, **options)
    @client.get_download_url(destination(key), **options)
  end

  def destination(key)
    [@prefix, partition(key)].compact.join('/').gsub(/^\//, '')
  end

  def exists?(key)
    @client.has_key?(destination(key))
  end

  def write(key, file, meta_info={})
    file = file.tempfile if file.class.name == "ActionDispatch::Http::UploadedFile"
    file = File.open(file) if file.is_a?(String)
    
    @client.upload_file(destination(key), file, {
      mime_type: meta_info[:content_type],
      sha1: meta_info[:sha1],
      content_disposition: meta_info[:filename] ? "inline; filename=\"#{::B2.encode(meta_info[:filename])}\"" : nil
    })
  end
  
  def cp(key, to)
    @client.download(destination(key), to)
  rescue ::B2::NotFound => e
    raise Errno::ENOENT.new(e.message)
  end

  def read(key, &block)
    @client.download(destination(key), &block)
  rescue ::B2::NotFound => e
    raise Errno::ENOENT.new(e.message)
  end

  def delete(key)
    @client.delete!(destination(key))
  end
  
  def sha1(key)
    @client.file(destination(key)).sha1
  rescue ::B2::NotFound => e
    raise Errno::ENOENT.new(e.message)
  end

  def last_modified(key)
    @client.file(destination(key)).uploaded_at
  rescue ::B2::NotFound => e
    raise Errno::ENOENT.new(e.message)
  end
  
  def mime_type(key)
    @client.file(destination(key)).mime_type
  rescue ::B2::NotFound => e
    raise Errno::ENOENT.new(e.message)
  end
  
end
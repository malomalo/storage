require 'b2'
require File.expand_path('../../storage', __FILE__)

class Storage::B2 < Storage

  attr_reader :account_id, :bucket, :prefix
  
  def initialize(configs={})
    super
    @bucket = configs[:bucket]
    @prefix = configs[:prefix]
    @account_id = configs[:account_id]

    @client = ::B2.new({
      account_id: @account_id,
      application_key: configs[:application_key]
    }).buckets.find { |b| b.name == @bucket }
  end
  
  def local?
    false
  end

  def url(key, expires_in: 3_600)
    @client.get_download_url(@bucket, destination(key), options)
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
      content_disposition: meta_info[:filename] ? "inline; filename=\"#{meta_info[:filename]}\"" : nil
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